#include "Audio.h"
#include <SuperpoweredSimple.h>
#include <SuperpoweredCPU.h>
#include <SuperpoweredDecoder.h>
#include <SuperpoweredRecorder.h>
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <android/log.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

#define log_print __android_log_print

static void playerEventCallbackA (
	void *clientData,
	SuperpoweredAdvancedAudioPlayerEvent event,
	void * __unused value
) {

    SuperpoweredAdvancedAudioPlayer *playerA = *((SuperpoweredAdvancedAudioPlayer **)clientData);
    switch(event) {

        case SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess:
            playerA->setPosition(playerA->firstBeatMs, false, false);

            break;
        case SuperpoweredAdvancedAudioPlayerEvent_EOF:
            playerA->pause();

            break;
        default:
            break;
    }
}

static bool audioProcessing (
    void *clientData,
    short int *audioIO,
    int numFrames,
    int __unused sampleRate
) {
    return ((Audio *)clientData)->audioProcess(audioIO, (unsigned int)numFrames);
}

Audio::Audio(
    unsigned int sampleRate,
    unsigned int bufferSize
) : echoMix(0) {
    stereoBuffer = (float *)memalign(16, bufferSize * sizeof(float) * 2);

    echo = new SuperpoweredEcho(sampleRate);

    playerA = NULL;
    audioSystem = new SuperpoweredAndroidAudioIO(
        sampleRate,
        bufferSize,
        false,
        true,
        audioProcessing,
        this,
        -1,
        SL_ANDROID_STREAM_MEDIA
    );

    this->sampleRate = sampleRate;
}

Audio::~Audio() {
    delete audioSystem;
    delete playerA;
    delete echo;
    free(stereoBuffer);
}

bool Audio::audioProcess (
    short int *output,
    unsigned int numFrames
) {
    if(playerA->process(stereoBuffer, false, numFrames)) {
        if(echoMix) echo->process(stereoBuffer, stereoBuffer, numFrames);
        SuperpoweredFloatToShortInt(stereoBuffer, output, numFrames);
        return true;
    } else {
        return false;
    }
}

void Audio::loadFile(const char *filePath, int offset, long fileLength) {
    if(playerA != NULL) {
        delete playerA;
    }

    playerA = new SuperpoweredAdvancedAudioPlayer(&playerA, playerEventCallbackA, this->sampleRate, 0);
    playerA->open(filePath, 0, fileLength);

    loadedFile = strdup(filePath);
}

void Audio::play() {
    playerA->play(false);
}

void Audio::pause() {
    playerA->pause();
}

void Audio::setPosition(double ms) {
    playerA->setPosition(ms, false, false);
}

void Audio::setEcho(float mix) {
    if(mix) {
        if(!echoMix) {
            echo->enable(true);
        }
    } else {
        echo->enable(false);
	}

	echo->setMix(mix > 0 ? mix : 0);
	echoMix = mix;
}

void Audio::setPitchShift(int pitchShift) {
    playerA->setPitchShift(pitchShift);
}

bool Audio::process(const char *filePath) {
    SuperpoweredDecoder *decoder = new SuperpoweredDecoder();
    const char *openError = decoder->open(loadedFile, false, 0, 0);
    
    float progress;

    if(openError) {
        delete decoder;
        return false;
    }
    
    FILE *fd = createWAV(filePath, decoder->samplerate, 2);
    
    if (!fd) {
        delete decoder;
        return false;
    }
    
    short int *intBuffer = (short int *)malloc(decoder->samplesPerFrame * 2 * sizeof(short int) + 32768);
    float *floatBuffer = (float *)malloc(decoder->samplesPerFrame * 2 * sizeof(float) + 32768);
    
    while (true) {
        unsigned int samplesDecoded = decoder->samplesPerFrame;
        
        if (decoder->decode(intBuffer, &samplesDecoded) == SUPERPOWEREDDECODER_ERROR) break;
        if (samplesDecoded < 1) break;
        
        SuperpoweredShortIntToFloat(intBuffer, floatBuffer, samplesDecoded);
        
        if(echoMix) {
            echo->process(floatBuffer, floatBuffer, samplesDecoded);
        }
        
        SuperpoweredFloatToShortInt(floatBuffer, intBuffer, samplesDecoded);
        
        fwrite(intBuffer, 1, samplesDecoded * 4, fd);
        
        progress = (double)decoder->samplePosition / (double)decoder->durationSamples;
    }
    
    delete decoder;
    free(intBuffer);
    free(floatBuffer);
    
    return true;
}

static Audio *audio = NULL;

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_initializeAudio(
    JNIEnv *env,
    jobject __unused obj,
    jint sampleRate,
    jint bufferSize
) {
    if(audio != NULL) {
        delete audio;
    }

    audio = new Audio((unsigned int)sampleRate, (unsigned int)bufferSize);
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_loadFile(
    JNIEnv *env,
    jobject __unused obj,
    jstring filePath,
    jlong fileLength
) {
    const char *path = env->GetStringUTFChars(filePath, JNI_FALSE);

	audio->loadFile(path, 0, fileLength);

    env->ReleaseStringUTFChars(filePath, path);
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_play(
    JNIEnv * __unused env,
    jobject __unused obj
) {
    audio->play();
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_pause(
    JNIEnv * __unused env,
    jobject __unused obj
) {
    audio->pause();
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_setPosition(
	JNIEnv * env,
	jobject __unused obj,
    double ms
) {
    audio->setPosition(ms);
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_setEcho(
	JNIEnv * __unused env,
	jobject __unused obj,
	jfloat mix
) {
	audio->setEcho(mix);
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_setPitchShift(
	JNIEnv * __unused env,
	jobject __unused obj,
	jint pitchShift
) {
	audio->setPitchShift(pitchShift);
}

extern "C"
JNIEXPORT jboolean Java_com_x86kernel_rnsuperpowered_Audio_process(
	JNIEnv * env,
	jobject __unused obj,
	jstring filePath
) {
    const char *path = env->GetStringUTFChars(filePath, JNI_FALSE);

    return audio->process(path);

    env->ReleaseStringUTFChars(filePath, path);
}

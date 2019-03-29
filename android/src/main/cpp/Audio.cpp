#include "Audio.h"
#include <SuperpoweredSimple.h>
#include <SuperpoweredCPU.h>
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <android/log.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

#define log_print __android_log_print

static void playerEventCallbackA (
	void *clientData,   // &playerA
	SuperpoweredAdvancedAudioPlayerEvent event,
	void * __unused value
) {
    if(event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
    	SuperpoweredAdvancedAudioPlayer *playerA = *((SuperpoweredAdvancedAudioPlayer **)clientData);
    	playerA->setPosition(playerA->firstBeatMs, false, false);
    };
}

static bool audioProcessing (
    void *clientdata,
    short int *audioIO,
    int numFrames,
    int __unused samplerate
) {
    return ((Audio *)clientdata)->process(audioIO, (unsigned int)numFrames);
}

Audio::Audio(
    unsigned int sampleRate,
    unsigned int bufferSize,
    const char *filePath,
    int fileLength
) : echoMix(0) {
    stereoBuffer = (float *)memalign(16, bufferSize * sizeof(float) * 2);
    playerA = new SuperpoweredAdvancedAudioPlayer(&playerA, playerEventCallbackA, sampleRate, 0);
    playerA->open(filePath, 0, fileLength);

    echo = new SuperpoweredEcho(sampleRate);

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
}

Audio::~Audio() {
    delete audioSystem;
    delete playerA;
    delete echo;
    free(stereoBuffer);
}

bool Audio::process (
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

void Audio::play() {
    playerA->play(false);
}

void Audio::pause() {
    playerA->pause();
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

static Audio *audio = NULL;

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_Audio(
    JNIEnv *env,
    jobject __unused obj,
    jint sampleRate,
    jint bufferSize,
    jstring filePath,
    jlong fileLength
) {
    const char *path = env->GetStringUTFChars(filePath, JNI_FALSE);

    audio = new Audio((unsigned int)sampleRate, (unsigned int)bufferSize, path, fileLength);
    env->ReleaseStringUTFChars(filePath, path);
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_Play(
    JNIEnv * __unused env,
    jobject __unused obj
) {
    audio->play();
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_Pause(
    JNIEnv * __unused env,
    jobject __unused obj
) {
    audio->pause();
}

extern "C"
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Audio_SetEcho(
	JNIEnv * __unused env,
	jobject __unused obj,
	jfloat mix
) {
	audio->setEcho(mix);
}

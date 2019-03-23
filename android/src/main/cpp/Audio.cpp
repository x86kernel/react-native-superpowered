#include "Audio.h"
#include <SuperpoweredSimple.h>
#include <SuperpoweredCPU.h>
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

static void playerEventCallbackA (
	void *clientData,   // &playerA
	SuperpoweredAdvancedAudioPlayerEvent event,
	void * __unused value
) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
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
) {
    stereoBuffer = (float *)memalign(16, bufferSize * sizeof(float) * 2);
    playerA = new SuperpoweredAdvancedAudioPlayer(&playerA, playerEventCallbackA, sampleRate, 0);
    playerA->open(filePath, 0, fileLength);

    echo = new SuperpoweredEcho(sampleRate);
    echo->enable(true);
    echo->setMix(1);

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
        echo->process(stereoBuffer, stereoBuffer, numFrames);
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

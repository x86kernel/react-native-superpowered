#include <jni.h>
#include <string>
#include <SuperpoweredRecorder.h>
#include <SuperpoweredSimple.h>
#include <AndroidIO/SuperpoweredAndroidAudioIO.h>
#include <malloc.h>
#include <android/log.h>

#include "Recorder.h"

#define log_print __android_log_print

static bool audioProcessing (
        void * __unused clientData,
        short int *audioIO,
        int numberOfFrames,
        int __unused sampleRate
) {
    return ((Recorder *)clientData)->process(audioIO, (unsigned int)numberOfFrames);
}

Recorder::Recorder(const char *tempPath, int bufferSize, int sampleRate, int minSeconds, int numChannels, bool applyFade) {
    recorder = new SuperpoweredRecorder(
        tempPath, 
        (unsigned int)sampleRate,
        minSeconds,
        numChannels,
        applyFade
    );

    floatBuffer = (float *)malloc(sizeof(float) * 2 * bufferSize);

    audioIO = new SuperpoweredAndroidAudioIO(
        sampleRate,
        bufferSize,
        true,
        false,
        audioProcessing,
        this
    );
}

bool Recorder::process(short int *audioIO, unsigned int numberOfFrames) {
    SuperpoweredShortIntToFloat(audioIO, floatBuffer, (unsigned int)numberOfFrames);
    recorder->process(floatBuffer, (unsigned int)numberOfFrames);

    return false;
}

void Recorder::start(const char *destPath) {
    recorder->start(destPath);
    audioIO->start();
}

void Recorder::stop() {
    audioIO->stop();
    recorder->stop();
}

static Recorder *recorder = NULL;

extern "C" 
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Recorder_initializeRecorder (
    JNIEnv* env,
    jobject  __unused obj,
    jstring tempPath,
    jint bufferSize,
    jint sampleRate,
    jint minSeconds,
    jint numChannels,
    jboolean applyFade
) {
    const char *temp = env->GetStringUTFChars(tempPath, 0);

    recorder = new Recorder(temp, bufferSize, sampleRate, minSeconds, numChannels, applyFade);

    env->ReleaseStringUTFChars(tempPath, temp);
}

extern "C" 
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Recorder_startRecord (
    JNIEnv* env,
    jobject  __unused obj,
    jstring destPath
) {
    const char *dest = env->GetStringUTFChars(destPath, 0);

    recorder->start(dest);

    env->ReleaseStringUTFChars(destPath, dest);
}

extern "C" 
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_Recorder_stopRecord (
    JNIEnv* __unused env,
    jobject  __unused obj
) {
	recorder->stop();
}

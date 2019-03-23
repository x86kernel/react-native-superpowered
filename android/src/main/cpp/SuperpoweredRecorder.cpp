#include <jni.h>
#include <string>
#include <SuperpoweredRecorder.h>
#include <SuperpoweredSimple.h>
#include <AndroidIO/SuperpoweredAndroidAudioIO.h>
#include <malloc.h>

static SuperpoweredAndroidAudioIO *audioIO;
static SuperpoweredRecorder *recorder;
float *floatBuffer;

static bool audioProcessing (
        void * __unused clientdata,
        short int *audio,
        int numberOfFrames,
        int __unused samplerate
) {
    SuperpoweredShortIntToFloat(audio, floatBuffer, (unsigned int)numberOfFrames);
    recorder->process(floatBuffer, (unsigned int)numberOfFrames);
    return false;
}

extern "C" 
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_SuperpoweredRecorder_StartRecord (
    JNIEnv* env,
    jobject  __unused obj,
    jstring tempPath,
    jstring destPath,
    jint buffersize,
    jint samplerate,
    jint minSeconds,
    jint numChannels,
    jboolean applyFade
) {
    const char *temp = env->GetStringUTFChars(tempPath, 0);
    const char *dest = env->GetStringUTFChars(destPath, 0);

    recorder = new SuperpoweredRecorder(
        temp, 
        (unsigned int)samplerate,
        minSeconds,
        numChannels,
        applyFade
    );

    recorder->start(dest);

    env->ReleaseStringUTFChars(tempPath, temp);
    env->ReleaseStringUTFChars(destPath, dest);

    floatBuffer = (float *)malloc(sizeof(float) * 2 * buffersize);

    audioIO = new SuperpoweredAndroidAudioIO(
        samplerate,
        buffersize,
        true,
        false,
        audioProcessing,
        NULL
    );
}

extern "C" 
JNIEXPORT void Java_com_x86kernel_rnsuperpowered_SuperpoweredRecorder_StopRecord (
    JNIEnv* __unused env,
    jobject  __unused obj
) {
    recorder->stop();
    delete audioIO;
    free(floatBuffer);
}

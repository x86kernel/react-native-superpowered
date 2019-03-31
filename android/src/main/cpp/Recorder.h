#ifndef RECORDER
#define RECORDER

#include <SuperpoweredRecorder.h>
#include <SuperpoweredSimple.h>
#include <AndroidIO/SuperpoweredAndroidAudioIO.h>

class Recorder {
	public:
        Recorder(const char *tempPath, int bufferSize, int sampleRate, int minSeconds, int numChannels, bool applyFade);
        ~Recorder();

        void start(const char *destPath);
        void stop();

        bool process(short int *audioIO, unsigned int numberOfSamples);

	private:
        SuperpoweredAndroidAudioIO *audioIO;
        SuperpoweredRecorder *recorder;

        float *floatBuffer;
};

#endif

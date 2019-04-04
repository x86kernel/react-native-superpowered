#ifndef AUDIO
#define AUDIO

#include <SuperpoweredAdvancedAudioPlayer.h>
#include <SuperpoweredReverb.h>
#include <SuperpoweredEcho.h>
#include <AndroidIO/SuperpoweredAndroidAudioIO.h>

class Audio {
    public:
        Audio(unsigned int sampleRate, unsigned int bufferSize);
        ~Audio();

        void loadFile(const char *filePath, int offset, long fileLength);
        bool audioProcess(short int *output, unsigned int numberOfSamples);

        void play();
        void pause();

        void setEcho(float mix);
        void setPitchShift(int pitchShift);
        void setPosition(double ms);

        bool process(const char *filePath);

    private:
        SuperpoweredAndroidAudioIO *audioSystem;
        SuperpoweredAdvancedAudioPlayer *playerA;
        SuperpoweredEcho *echo;

        char *loadedFile;

        unsigned int sampleRate;
        float *stereoBuffer, echoMix;
        int pitchShift;
};

#endif

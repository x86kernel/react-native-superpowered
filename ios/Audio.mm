#import "Audio.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredEcho.h"
#import "SuperpoweredSimple.h"


@implementation Audio {
    SuperpoweredAdvancedAudioPlayer *playerA;
    SuperpoweredIOSAudioIO *output;
    SuperpoweredEcho *echo;
    
    float *stereoBuffer;
}

static Audio *instance = nil;

+ (instancetype) createInstance:(unsigned int)sampleRate {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(!instance) {
            instance = [[Audio alloc] initPrivate: sampleRate];
        }
    });
    
    return instance;
}

+ (instancetype) getInstance {
    return instance;
}

void playerEventCallbackA(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        Audio *self = (__bridge Audio *)clientData;
        self->playerA->setPosition(self->playerA->firstBeatMs, false, false);
    }
}

static bool audioProcessing(void *clientData, float **inputBuffers, unsigned int inputChannels, float **outputBuffers, unsigned int outputChannels, unsigned int numberOfSamples, unsigned int sampleRate, uint64_t hotTime) {
    __unsafe_unretained Audio *self = (__bridge Audio *)clientData;
    
    bool silence = !self->playerA->process(self->stereoBuffer, false, numberOfSamples);
    
    if(!silence) {
        self->echo->process(self->stereoBuffer, self->stereoBuffer, numberOfSamples);
        SuperpoweredDeInterleave(self->stereoBuffer, outputBuffers[0], outputBuffers[1], numberOfSamples);
    }
    
    return !silence;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"Singleton Error" reason: @"" userInfo: nil];
}

- (instancetype) initPrivate:(unsigned int)sampleRate {
    if(posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort();
    
    self = [super init];
    
    self->sampleRate = sampleRate;
    self->playerA = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackA, sampleRate, 0);
    
    output = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:sampleRate audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
    
    self->echo = new SuperpoweredEcho(sampleRate);
    
    return self;
}

- (void) loadFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]) {
        @throw [NSException exceptionWithName:@"Audio file not exists" reason: @"" userInfo: nil];
    }
    
    if(playerA) {
        delete playerA;
    }

    playerA = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackA, sampleRate, 0);
    playerA->open([filePath UTF8String]);
}

- (void) play {
    [output start];
    playerA->play(false);
}

- (void) pause {
    [output stop];
    playerA->pause();
}

- (void) setEcho:(float)mix {
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

- (void) setPitchShift:(int)pitchShift {
    playerA->setPitchShift(pitchShift);
}

- (void) interruptionStarted {}
- (void) recordPermissionRefused {}
- (void) mapChannels:(multiOutputChannelMap *)outputMap inputMap:(multiInputChannelMap *)inputMap externalAudioDeviceName:(NSString *)externalAudioDeviceName outputsAndInputs:(NSString *)outputsAndInputs {}

@end

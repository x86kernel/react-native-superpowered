#import "Audio.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredEcho.h"
#import "SuperpoweredSimple.h"


@implementation Audio {
    SuperpoweredAdvancedAudioPlayer *playerA;
    SuperpoweredIOSAudioIO *output;
    
    float *stereoBuffer;
}

static Audio *instance = nil;

+ (instancetype) createInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(!instance) {
            instance = [[Audio alloc] initPrivate];
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
        SuperpoweredDeInterleave(self->stereoBuffer, outputBuffers[0], outputBuffers[1], numberOfSamples);
    }
    
    return !silence;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"Singleton Error" reason: @"" userInfo: nil];
}

- (instancetype) initPrivate {
    if(posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort();
    
    return [super init];
}

- (void) loadFile:(NSString *)filePath sampleRate:(unsigned int)sampleRate {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        @throw [NSException exceptionWithName:@"Audio file not exists" reason: @"" userInfo: nil];
    }
    
    NSInteger fileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    
    playerA = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackA, sampleRate, 0);
    playerA->open([filePath UTF8String], 0, fileSize);
    
    output = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:sampleRate audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
}

- (void) play {
    [output start];
    playerA->play(false);
}

- (void) pause {
    [output stop];
    playerA->pause();
}

- (void) interruptionStarted {}
- (void) recordPermissionRefused {}
- (void) mapChannels:(multiOutputChannelMap *)outputMap inputMap:(multiInputChannelMap *)inputMap externalAudioDeviceName:(NSString *)externalAudioDeviceName outputsAndInputs:(NSString *)outputsAndInputs {}

@end

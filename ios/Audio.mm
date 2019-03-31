#import "Audio.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredEcho.h"
#import "SuperpoweredSimple.h"
#import "SuperpoweredDecoder.h"
#import "SuperpoweredRecorder.h"


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
    Audio *self = (__bridge Audio *)clientData;
    
    switch(event) {
        case SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess:
            self->playerA->setPosition(self->playerA->firstBeatMs, false, false);
            break;
        case SuperpoweredAdvancedAudioPlayerEvent_EOF:
            self->playerA->pause();
            break;
        default:
            break;
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
    
    loadedFile = filePath;
}

- (void) play {
    [output start];
    playerA->togglePlayback();
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

- (NSString *) process:(NSString *)fileName {
    SuperpoweredDecoder *decoder = new SuperpoweredDecoder();
    const char *openError = decoder->open([loadedFile UTF8String], false, 0, 0);
    
    float progress;
    
    if(openError) {
        delete decoder;
        @throw [NSException exceptionWithName:@"FAILED_OPEN_AUDIO_FILE" reason: @"Cannot open audio file" userInfo: nil];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@".wav"]];
    
    [self deleteFileAtPath:filePath];
    FILE *fd = createWAV([filePath UTF8String], decoder->samplerate, 2);
    
    if (!fd) {
        delete decoder;
        @throw [NSException exceptionWithName:@"FAILED_CREATE_AUDIO_FILE" reason: @"Failed to create audio file" userInfo: nil];
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
    
    return filePath;
}

- (void) deleteFileAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error: nil];
    }
}

- (void) interruptionStarted {}
- (void) recordPermissionRefused {}
- (void) mapChannels:(multiOutputChannelMap *)outputMap inputMap:(multiInputChannelMap *)inputMap externalAudioDeviceName:(NSString *)externalAudioDeviceName outputsAndInputs:(NSString *)outputsAndInputs {}

@end

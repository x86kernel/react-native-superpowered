#import "Recorder.h"
#import "SuperpoweredRecorder.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredSimple.h"


@implementation Recorder {
    SuperpoweredRecorder *recorder;
    SuperpoweredIOSAudioIO *audioIO;
}

static Recorder *instance = nil;
static dispatch_once_t onceToken;

+ (instancetype) createInstance:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade {

    dispatch_once(&onceToken, ^{
        if(!instance) {
            instance = [[Recorder alloc] initPrivate:sampleRate minSeconds:minSeconds numChannels:numChannels applyFade:applyFade];
        }
    });
    
    return instance;
}

+ (instancetype) getInstance {
    return instance;
}

static bool audioProcessing(void *clientData, float **inputBuffers, unsigned int inputChannels, float **outputBuffers, unsigned int outputChannels, unsigned int numberOfSamples, unsigned int sampleRate, uint64_t hostTime) {
    __unsafe_unretained Recorder *self = (__bridge Recorder *)clientData;
    
    self->recorder->process(inputBuffers[0], inputBuffers[1], numberOfSamples);
    return false;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"Singleton Error" reason: @"" userInfo: nil];
}

- (instancetype) initPrivate:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade {
    self = [super init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *tempPath = [documentsDirectory stringByAppendingPathComponent:@"temp.wav"];
    [self deleteFileAtPath:tempPath];
    
    const char *temp = [tempPath UTF8String];
    
    recorder = new SuperpoweredRecorder(temp, sampleRate, minSeconds, numChannels, applyFade);
    
    audioIO = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:sampleRate audioSessionCategory:AVAudioSessionCategoryRecord channels:numChannels audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
    
    return self;
}

- (void) deleteFileAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error: nil];
    }
}

- (void) startRecord:(NSString *)destName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    destPath = [documentsDirectory stringByAppendingPathComponent:destName];
    [self deleteFileAtPath:[self getRecordFileName]];

    const char *dest = [destPath UTF8String];
    
    recorder->start(dest);
    [audioIO start];
}

- (NSString *) stopRecord {
    [audioIO stop];
    recorder->stop();
    
    return [self getRecordFileName];
}

- (NSString *) getRecordFileName { return [destPath stringByAppendingString:@".wav"]; };

- (void) interuptionStarted {}
- (void) recordPermissionRefused {}
- (void) mapChannels:(multiOutputChannelMap *)outputMap inputMap:(multiInputChannelMap *)inputMap externalAudioDeviceName:(NSString *)externalAudioDeviceName outputsAndInputs:(NSString *)outputsAndInputs {}

@end


#import "RNSuperpowered.h"
#import "Recorder.h"
#import "Audio.h"

@implementation RNSuperpowered

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(startRecord:(NSInteger)sampleRate minSeconds:(NSInteger)minSeconds numChannels:(NSInteger)numChannels applyFade:(BOOL)applyFade) {
    Recorder *recorder = [Recorder createInstance];
    
    [recorder startRecord: @"audio" sampleRate:sampleRate minSeconds:minSeconds numChannels:numChannels applyFade:applyFade];
}

RCT_REMAP_METHOD(stopRecord,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    Recorder *recorder = [Recorder getInstance];
    NSString *destPath = [recorder stopRecord];
    
    resolve(destPath);
}

RCT_EXPORT_METHOD(initializeAudio:(NSString *)filePath sampleRate:(NSInteger)sampleRate) {
    Audio *audio = [Audio createInstance];
    [audio loadFile:filePath sampleRate:sampleRate];
}

RCT_EXPORT_METHOD(playAudio) {
    [[Audio getInstance] play];
}

RCT_EXPORT_METHOD(pauseAudio) {
    [[Audio getInstance] pause];
}


@end

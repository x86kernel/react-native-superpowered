
#import "RNSuperpowered.h"
#import "Recorder.h"

@implementation RNSuperpowered

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(startRecord:(NSInteger)sampleRate minSeconds:(NSInteger)minSeconds numChannels:(NSInteger)numChannels applyFade:(BOOL)applyFade)
{
    Recorder *recorder = [Recorder createInstance: 480 sampleRate:sampleRate minSeconds:minSeconds numChannels:numChannels applyFade:applyFade];
    
    return;
}

RCT_REMAP_METHOD(stopRecord,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    Recorder *recorder = [Recorder getInstance];
    NSString *destPath = [recorder stopRecord];
    
    resolve(destPath);
}


@end

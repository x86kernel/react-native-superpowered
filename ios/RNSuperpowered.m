
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
    Recorder *recorder = [Recorder createInstance: sampleRate minSeconds:minSeconds numChannels:numChannels applyFade:applyFade];
    
    [recorder startRecord: @"audio"];
}

RCT_REMAP_METHOD(stopRecord,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    Recorder *recorder = [Recorder getInstance];
    NSString *destPath = [recorder stopRecord];
    
    resolve(destPath);
}

RCT_EXPORT_METHOD(initializeAudio:(NSString *)filePath sampleRate:(NSInteger)sampleRate) {
    Audio *audio = [Audio createInstance:sampleRate];
    [audio loadFile:filePath];
}

RCT_EXPORT_METHOD(loadFile:(NSString *)filePath) {
    [[Audio getInstance] loadFile:filePath];
}

RCT_EXPORT_METHOD(playAudio) {
    [[Audio getInstance] play];
}

RCT_EXPORT_METHOD(pauseAudio) {
    [[Audio getInstance] pause];
}

RCT_EXPORT_METHOD(setEcho:(float)mix) {
    [[Audio getInstance] setEcho:mix];
}

RCT_EXPORT_METHOD(setPitchShift:(int)pitchShift) {
    [[Audio getInstance] setPitchShift:pitchShift];
}

RCT_REMAP_METHOD(process,
                 filePath:(NSString *)fileName
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    Audio *audio = [Audio getInstance];
    
    @try {
        NSString *filePath = [audio process:fileName];
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"uri"] = filePath;
        response[@"isSuccess"] = @YES;
            
        resolve(response);
        
    } @catch (NSException *exception) {
        reject(exception.name, exception.reason, nil);
    }
}

@end

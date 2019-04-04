#ifndef Recorder_h
#define Recorder_h

#import <Foundation/Foundation.h>

@interface Recorder : NSObject {
@private
    NSString *destPath;
}

+ (instancetype) createInstance:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade;
+ (instancetype) getInstance;

- (instancetype) init;
- (instancetype) initPrivate:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade;

- (void) startRecord:(NSString *)destName;
- (NSString *) stopRecord;

@end

#endif /* Recorder_h */

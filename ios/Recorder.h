#ifndef Recorder_h
#define Recorder_h

#import <Foundation/Foundation.h>

@interface Recorder : NSObject {
@private
    NSString *destPath;
}

+ (instancetype) createInstance;
+ (instancetype) getInstance;

- (instancetype) init;
- (instancetype) initPrivate;

- (void) startRecord:(NSString *)destName sampleRate:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade;
- (NSString *) stopRecord;

@end

#endif /* Recorder_h */

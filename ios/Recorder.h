#ifndef Recorder_h
#define Recorder_h

#import <Foundation/Foundation.h>

@interface Recorder : NSObject {
@private
    NSString *destPath;
    float *floatBuffer;
}

+ (instancetype) createInstance:(int)bufferSize sampleRate:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade;

+ (instancetype) getInstance;

- (void) startRecord:(NSString *)destName;
- (NSString *) stopRecord;

@end

#endif /* Recorder_h */

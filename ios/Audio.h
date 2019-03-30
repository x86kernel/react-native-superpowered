#ifndef Audio_h
#define Audio_h

#import <Foundation/Foundation.h>

@interface Audio : NSObject {
    int pitchShift;
    float echoMix;
}

+ (instancetype) createInstance;
+ (instancetype) getInstance;

- (instancetype) init;
- (instancetype) initPrivate;

- (void) loadFile:(NSString *)filePath sampleRate:(unsigned int)sampleRate;
- (void) play;
- (void) pause;

@end

#endif /* Audio_h */

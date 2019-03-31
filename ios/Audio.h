#ifndef Audio_h
#define Audio_h

#import <Foundation/Foundation.h>

@interface Audio : NSObject {
    NSString *loadedFile;
    
    unsigned int sampleRate;
    int pitchShift;
    float echoMix;
}

+ (instancetype) createInstance:(unsigned int)sampleRate;
+ (instancetype) getInstance;

- (instancetype) init;
- (instancetype) initPrivate:(unsigned int)sampleRate;

- (void) loadFile:(NSString *)filePath;

- (void) play;
- (void) pause;

- (void) setEcho:(float)mix;
- (void) setPitchShift:(int)pitchShift;

- (NSString *) process:(NSString *)fileName;

@end

#endif /* Audio_h */

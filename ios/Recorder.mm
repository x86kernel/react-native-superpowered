//
//  Recorder.m
//  RNSuperpowered
//
//  Created by Alice Tsang on 29/3/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "Recorder.h"
#import "SuperpoweredRecorder.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredSimple.h"

@implementation Recorder {
    SuperpoweredRecorder *recorder;
    SuperpoweredIOSAudioIO *audioIO;
}

static Recorder *instance = nil;

static bool audioProcessing(void *clientData, float **inputBuffers, unsigned int inputChannels, float **outputBuffers, unsigned int outputChannels, unsigned int numberOfSamples, unsigned int sampleRate, uint64_t hostTime) {

    return false;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"Singleton Error" reason: @"" userInfo: nil];
}

- (instancetype) initPrivate:(int)bufferSize sampleRate:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade {
    self = [super init];

    if(posix_memalign((void **)&floatBuffer, 16, bufferSize) != 0) abort();
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempPath = [[documentsDirectory lastPathComponent] stringByAppendingPathComponent:@"temp.wav"];
    
    const char *temp = [tempPath UTF8String];
    
    self->recorder = new SuperpoweredRecorder(temp, (unsigned int)sampleRate, minSeconds, numChannels, applyFade);
    
    self->audioIO = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:sampleRate audioSessionCategory:AVAudioSessionCategoryRecord channels:0 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
    
    return self;
}

- (void) startRecord:(NSString *)destName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destPath = [[documentsDirectory lastPathComponent] stringByAppendingPathComponent:destName];
    
    self->destPath = [destPath stringByAppendingPathComponent:@".wav"];
    
    const char *dest = [destPath UTF8String];
    self->recorder->start(dest);
}

- (NSString *) stopRecord {
    self->recorder->stop();
    return self->destPath;
}

+ (instancetype) createInstance:(int)bufferSize sampleRate:(int)sampleRate minSeconds:(int)minSeconds numChannels:(int)numChannels applyFade:(bool)applyFade {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(!instance) {
            instance = [[Recorder alloc] initPrivate: bufferSize sampleRate:sampleRate minSeconds:minSeconds numChannels:numChannels applyFade:applyFade];
        }
    });
    
    return instance;
}

+ (instancetype) getInstance {
    return instance;
}

@end

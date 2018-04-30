//
//  ToneGenerator.h
//  Tone Generator
//
//  Created by Miguel Vanhove on 2018/04/21.
//  Copyright (c) 2018 Miguel Vanhove. All rights reserved.
//
//  Based upon work by Anthony Picciano on 6/12/13.
//  Copyright (c) 2013 Anthony Picciano. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define TG_FREQUENCY_DEFAULT 440.0f

#define TG_SAMPLE_RATE_DEFAULT 44100.0f

#define TG_AMPLITUDE_LOW 0.01f
#define TG_AMPLITUDE_MEDIUM 0.02f
#define TG_AMPLITUDE_HIGH 0.03f
#define TG_AMPLITUDE_FULL 0.25f
#define TG_AMPLITUDE_DEFAULT TG_AMPLITUDE_FULL


typedef NS_ENUM(NSUInteger, GeneratorType)
{
    GeneratorTypeSine,
    GeneratorTypeSquare,
    GeneratorTypeTriangle,
    GeneratorTypeSawtooth,
    GeneratorTypeNoise,
};

@interface ToneGenerator : NSObject

- (id)initWithChannels:(UInt32)size;
- (void)play;
- (void)stop;

- (void)playFrequency:(double)frequency withAmplitude:(double)amplitude;


@end

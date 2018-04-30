#import "ToneGenerator.h"
#import <AudioToolbox/AudioToolbox.h>

typedef struct {
    double frequency;
    double amplitude;
    double theta;
} TGChannelInfo;


@interface ToneGenerator() {
    @public
        AudioComponentInstance _toneUnit;
        double _sampleRate;
        TGChannelInfo *_channels;
        UInt32 _numChannels;
        NSUInteger type;

}

@end

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags   *ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
//    NSLog(@"rendertone sound");
    
    // Get the tone parameters out of the object
    ToneGenerator *toneGenerator = (__bridge ToneGenerator *)inRefCon;
    assert(ioData->mNumberBuffers == toneGenerator->_numChannels);
    
    for (size_t chan = 0; chan < toneGenerator->_numChannels; chan++) {
        double theta = toneGenerator->_channels[chan].theta;
        double amplitude = toneGenerator->_channels[chan].amplitude;
        double theta_increment = 2.0 * M_PI * toneGenerator->_channels[chan].frequency / toneGenerator->_sampleRate;
        
        Float32 *buffer = (Float32 *)ioData->mBuffers[chan].mData;
        // Generate the samples
        for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
            
            if (toneGenerator->type == GeneratorTypeSquare) {
                buffer[frame] = (theta < 0 ? -1.0f : ( theta > 0 ? 1.0f : 0.0f)) * amplitude;
                
                theta += theta_increment;
                if (theta > 2.0 * M_PI) {
                    theta -= 4.0 * M_PI;
                }
            }
            
            if (toneGenerator->type == GeneratorTypeSine) {
                buffer[frame] = sin(theta) * amplitude;
                
                theta += theta_increment;
                if (theta > 2.0 * M_PI) {
                    theta -= 2.0 * M_PI;
                }
            }
            
        }
        
        // Store the theta back in the view controller
        toneGenerator->_channels[chan].theta = theta;
    }
    
    return noErr;
}

@implementation ToneGenerator

- (id)init
{
    return [self initWithChannels:1];
}

- (id)initWithChannels:(UInt32)size {
    if (self = [super init]) {
        _numChannels = size;
        _channels = calloc(sizeof(TGChannelInfo), _numChannels);
        if (_channels == NULL) return nil;
        
        type = GeneratorTypeSquare;

        for (size_t i = 0; i < _numChannels; i++) {
            _channels[i].frequency = 440;
            _channels[i].amplitude = TG_AMPLITUDE_DEFAULT;
        }
        _sampleRate = TG_SAMPLE_RATE_DEFAULT;
        [self _setupAudioSession];
    }
    
    return self;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_channels != NULL) {
        free(_channels);
    }
}

- (void)playFrequency:(double)frequency withAmplitude:(double)amplitude {
    _channels[0].frequency = frequency;
    _channels[0].amplitude = amplitude;
}

- (void)play {
    if (!_toneUnit) {
        [self _createToneUnit];
        
        // Stop changing parameters on the unit
        OSErr err = AudioUnitInitialize(_toneUnit);
        NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
        
        // Start playback
        err = AudioOutputUnitStart(_toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    }
}

- (void)stop {
    if (_toneUnit) {
        AudioOutputUnitStop(_toneUnit);
        AudioUnitUninitialize(_toneUnit);
        AudioComponentInstanceDispose(_toneUnit);
        _toneUnit = nil;
    }
}

- (void)_setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSAssert1(ok, @"Audio error %@", setCategoryError);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:audioSession];
}

- (void)_handleInterruption:(id)sender {
    [self stop];
}

- (void)_createToneUnit {
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // Create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
    NSAssert1(_toneUnit, @"Error creating unit: %hd", err);
    
    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = (__bridge void *)(self);
    err = AudioUnitSetProperty(_toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = _sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = _numChannels;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (_toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

@end

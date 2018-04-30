#include "Arduino.h"

#include "Arduboy2.h"
#include "ArduboyPlaytune.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

extern unsigned int kkFreq;
extern uint64_t kkUntil;

static bool muted = false;

ArduboyPlaytune::ArduboyPlaytune(bool) {
    
}

char ArduboyPlaytune::playing(void) {
    return 0;
}

void ArduboyPlaytune::playScore(const byte*) {
    
}

void ArduboyPlaytune::toneMutesScore(bool mute) {
    muted = mute;
}



void ArduboyPlaytune::tone(int freq,int durMs) {
    
    static int i=0;
    
    if (Arduboy2Audio::enabled()) {
        
        printf("%03d, tone: %d\n", i++, freq);
        
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
        
        uint64_t duration = durMs * 1000000;
        
        duration = (duration * info.denom) / info.numer;
        
        kkFreq = freq;
        kkUntil = mach_absolute_time() + duration;
        
        printf("until %lld\n", kkUntil);
    }
}

void  ArduboyPlaytune::initChannel(byte pin) {
    
}

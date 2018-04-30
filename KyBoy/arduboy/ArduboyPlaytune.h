//
//  ArduboyPlaytune.h
//  KyBoy
//
//  Created by Miguel Vanhove on 2018/04/21.
//  Copyright (c) 2018 Miguel Vanhove. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#ifndef ArduboyPlaytune_h
#define ArduboyPlaytune_h

#define PIN_SPEAKER_1 1
#define PIN_SPEAKER_2 2

class ArduboyPlaytune {
    
    
public:
    
    ArduboyPlaytune(bool);

    
    char playing(void);
    void playScore(const byte*);
    
    void toneMutesScore(bool);
    
    void tone(int a,int b);
    
    void static initChannel(byte pin);

    
};

#endif /* ArduboyPlaytune_h */

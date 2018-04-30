//
//  Arduboy2.h
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

#ifndef ArduBoy2_h
#define ArduBoy2_h

#include "Arduino.h"
#include "Sprites.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Main function in .ino

void setup();
void loop();

// pixel colors
#define BLACK 0  /**< Color value for an unlit pixel for draw functions. */
#define WHITE 1  /**< Color value for a lit pixel for draw functions. */

#define HEIGHT 64
#define WIDTH 128

#define _BV(bit)  (1 << (bit)) 


#define LEFT_BUTTON _BV(5)  /**< The Left button value for functions requiring a bitmask */
#define RIGHT_BUTTON _BV(6) /**< The Right button value for functions requiring a bitmask */
#define UP_BUTTON _BV(7)    /**< The Up button value for functions requiring a bitmask */
#define DOWN_BUTTON _BV(4)  /**< The Down button value for functions requiring a bitmask */
#define A_BUTTON _BV(3)     /**< The A button value for functions requiring a bitmask */
#define B_BUTTON _BV(2)     /**< The B button value for functions requiring a bitmask */


class Arduboy2Audio
{
public:
    void static on();
    void static off();
    bool static enabled();
    void static saveOnOff();

protected:
    bool static audio_enabled;
};

class Arduboy2 {
    
public:

    Arduboy2();
    
    void clear();
    void fillScreen(uint8_t color);
    
    bool everyXFrames(uint8_t frames);
    
    bool justPressed(uint8_t button);
    bool pressed(uint8_t buttons);
    void pollButtons();
    bool justReleased(uint8_t button);
    bool notPressed(uint8_t buttons);

    void setCursor(int16_t x, int16_t y);
    int16_t getCursorX();
    int16_t getCursorY();
    
    void fillRect(int16_t x, int16_t y, uint8_t w, uint8_t h, uint8_t color = WHITE);
    void drawFastVLine (int16_t x, int16_t y, uint8_t h, uint8_t color);
   void drawFastHLine (int16_t x, int16_t y, uint8_t w, uint8_t color);
    
    
    void drawPixel(int16_t x, int16_t y, uint8_t color);
    uint8_t getPixel(uint8_t x, uint8_t y);
    
    Arduboy2Audio audio;
    
    void print(const char *);
    void drawChar(int16_t x, int16_t y, unsigned char c, uint16_t color, uint16_t bg, uint8_t size);
    
    void initRandomSeed();

    void static setRGBled(uint8_t red, uint8_t green, uint8_t blue);
    
    void begin();

    void display();
    void display(bool clear);

    void paintScreen(const uint8_t *image);
    void paintScreen(const uint8_t *image, bool clear);

    
    void setFrameRate(uint8_t rate);
    void setFrameDuration(uint8_t duration);
    void setTextSize(uint8_t s);
    bool nextFrame();
    int cpuLoad();

    static uint8_t sBuffer[(HEIGHT*WIDTH)/8];

protected:
    // For button handling
    uint8_t currentButtonState;
    uint8_t previousButtonState;
    
    // For frame funcions
    uint8_t eachFrameMillis;
    uint8_t thisFrameStart;
    bool justRendered;
    uint8_t lastFrameDurationMs;
    
    int frameCount;
};



/*
class Sprites {
    
    
public:
    static void drawOverwrite(int16_t x, int16_t y, const uint8_t *bitmap, uint8_t frame);
    
    static void drawSelfMasked(int16_t x, int16_t y, const uint8_t *bitmap, uint8_t frame);
    
};
 */

// Arduino function

unsigned long micros(void);
void *memcpy_P (void *, const void *, size_t);


#define pgm_read_byte(address_short) (*address_short)

#endif /* ArduBoy2_h */

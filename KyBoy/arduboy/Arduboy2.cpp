#include <string.h>
#include <time.h>

#include "glcdfont.h"

#include "Arduino.h"


#include "Arduboy2.h"

extern unsigned char screen8[];
extern unsigned char kkButtonState;

bool Arduboy2Audio::audio_enabled = false;

void Arduboy2Audio::on() {
    audio_enabled = 1;
}
void Arduboy2Audio::off() {
    audio_enabled = 0;
}
bool Arduboy2Audio::enabled() {
    return audio_enabled;
}

void Arduboy2Audio::saveOnOff() {
    
}

// ---

Arduboy2::Arduboy2()
{
    currentButtonState = 0;
    previousButtonState = 0;
    // frame management
    setFrameDuration(16);
    frameCount = 0;
    justRendered = false;
}

uint8_t Arduboy2::sBuffer[];


void Arduboy2::clear() {
    fillScreen(BLACK);
}

void Arduboy2::fillScreen(uint8_t color)
{
     if (color != BLACK)
     {
       color = 0xFF; // all pixels on
     }
     for (int16_t i = 0; i < WIDTH * HEIGHT / 8; i++)
     {
        sBuffer[i] = color;
     }
}

bool Arduboy2::everyXFrames(uint8_t frames){
    return false;
}

// key

bool Arduboy2::pressed(uint8_t buttons)
{
    return (kkButtonState & buttons) == buttons;
}

bool Arduboy2::notPressed(uint8_t buttons)
{
    return (kkButtonState & buttons) == 0;
}

void Arduboy2::pollButtons()
{
    previousButtonState = currentButtonState;
    currentButtonState = kkButtonState;
}

bool Arduboy2::justPressed(uint8_t button)
{
    return (!(previousButtonState & button) && (currentButtonState & button));
}

bool Arduboy2::justReleased(uint8_t button)
{
    return ((previousButtonState & button) && !(currentButtonState & button));
}

// Cursor

static int cursorX, cursorY;

void Arduboy2::setCursor(int16_t x, int16_t y){
    cursorX = x;
    cursorY = y;
}

int16_t Arduboy2::getCursorX(){
    return cursorX;
}

int16_t Arduboy2::getCursorY(){
    return cursorY;
}


void Arduboy2::drawFastVLine (int16_t x, int16_t y, uint8_t h, uint8_t color)
{
    int end = y+h;
    for (int a = arduiMax(0,y); a < arduiMin(end,HEIGHT); a++)
    {
        drawPixel(x,a,color);
    }
}

void Arduboy2::drawPixel(int16_t x, int16_t y, uint8_t color)
{
    
    uint16_t row_offset;
    uint8_t bit;
    
     uint8_t row = (uint8_t)y / 8;
     row_offset = (row*WIDTH) + (uint8_t)x;
     bit = _BV((uint8_t)y % 8);
    
    if (color) {
        sBuffer[row_offset] |=   bit;
    } else {
        sBuffer[row_offset] &= ~ bit;
    }
}

uint8_t Arduboy2::getPixel(uint8_t x, uint8_t y)
{
    uint8_t row = y / 8;
    uint8_t bit_position = y % 8;
    return (sBuffer[(row*WIDTH) + x] & _BV(bit_position)) >> bit_position;
}

void Arduboy2::drawFastHLine (int16_t x, int16_t y, uint8_t w, uint8_t color)
{
    int16_t xEnd; // last x point + 1
    
    // Do y bounds checks
    if (y < 0 || y >= HEIGHT)
        return;
    
    xEnd = x + w;
    
    // Check if the entire line is not on the display
    if (xEnd <= 0 || x >= WIDTH)
        return;
    
    // Don't start before the left edge
    if (x < 0)
        x = 0;
    
    // Don't end past the right edge
    if (xEnd > WIDTH)
        xEnd = WIDTH;
    
    // calculate actual width (even if unchanged)
    w = xEnd - x;
    
    // buffer pointer plus row offset + x offset
    register uint8_t *pBuf = sBuffer + ((y / 8) * WIDTH) + x;
    
    // pixel mask
    register uint8_t mask = 1 << (y & 7);
    
    switch (color)
    {
        case WHITE:
            while (w--)
            {
                *pBuf++ |= mask;
            }
            break;
            
        case BLACK:
            mask = ~mask;
            while (w--)
            {
                *pBuf++ &= mask;
            }
            break;
    }
}
void Arduboy2::fillRect(int16_t x, int16_t y, uint8_t w, uint8_t h, uint8_t color ){
    for (int16_t i=x; i<x+w; i++)
    {
        drawFastVLine(i, y, h, color);
    }
}

void Arduboy2::drawChar(int16_t x, int16_t y, unsigned char c, uint16_t color, uint16_t bg, uint8_t size)
{
    if((x >= WIDTH)        || // Clip right
       (y >= HEIGHT)        || // Clip bottom
       ((x + 6 * size - 1) < 0)    || // Clip left
       ((y + 8 * size - 1) < 0))     // Clip top
        return;
    
    for (int8_t i=0; i<6; i++ ) {
        uint8_t line;
        if (i == 5)
            line = 0x0;
        else
            line = font[c*5+i];
        
        for (int8_t j = 0; j<8; j++) {
            if (line & 0x1) {
                if (size == 1) // default size
                    drawPixel(x+i, y+j, color);
                else {  // big size
                    fillRect(x+(i*size), y+(j*size), size, size, color);
                }
            } else if (bg != color) {
                if (size == 1) // default size
                    drawPixel(x+i, y+j, bg);
                else {  // big size
                    fillRect(x+i*size, y+j*size, size, size, bg);
                }
            }
            line >>= 1;
        }
    }
}

static int arduSize = 1;

void Arduboy2::print(const char *string){
    int x = 0;
    
    while(string[x]!=0) {
        drawChar(cursorX+x*6, cursorY, string[x], WHITE, BLACK, arduSize);
        x++;
    }
    
}

void Arduboy2::initRandomSeed(){
    srand((unsigned int)time(NULL));
}

void Arduboy2::setRGBled(uint8_t red, uint8_t green, uint8_t blue){
    
}

void Arduboy2::begin() {
    
}
void Arduboy2::display()
{
    paintScreen(sBuffer);
}

void Arduboy2::display(bool clear)
{
    paintScreen(sBuffer, clear);
}

void Arduboy2::paintScreen(const uint8_t *image)
{
//    printf("[%p]", screen8);
    memcpy(screen8, image, 128*8);
}

void Arduboy2::paintScreen(const uint8_t *image, bool clear)
{
    for (int i = 0; i < (HEIGHT*WIDTH)/8; i++)
    {
        screen8[i] = image[i];
        //        SPItransfer(pgm_read_byte(image + i));
    }
}

void Arduboy2::setFrameRate(uint8_t rate) {
    
}

void Arduboy2::setFrameDuration(uint8_t duration) {
    
}

void Arduboy2::setTextSize(uint8_t s) {
    arduSize = s;
}

bool Arduboy2::nextFrame() {
    return true;
}

int Arduboy2::cpuLoad(){
    return 0;
}

/*
void Sprites::drawOverwrite(int16_t x, int16_t y, const uint8_t *bitmap, uint8_t frame) {
}

void Sprites::drawSelfMasked(int16_t x, int16_t y, const uint8_t *bitmap, uint8_t frame) {
    
}
*/

// Returns the number of microseconds
unsigned long micros(void) {
    return (unsigned long)(rand() * RAND_MAX);
}

void *memcpy_P (void *dst, const void *src, size_t len) {
    return memcpy(dst, src, len);
}


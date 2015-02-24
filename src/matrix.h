#ifndef __MATRIX_H__
#define __MATRIX_H__

#include <FastLED.h>

const bool    kMatrixSerpentineLayout = true;
const uint8_t kMatrixWidth = 16;
const uint8_t kMatrixHeight = 16;
#define NUM_LEDS (kMatrixWidth * kMatrixHeight)

namespace Matrix {
    // The leds
    extern CRGB frameBufferWithSafetyPixel[];
    extern CRGB* frameBuffer;
}

uint16_t XY( uint8_t x, uint8_t y);
uint16_t XYsafe( uint8_t x, uint8_t y);

#endif

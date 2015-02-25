#include <FastLED.h>
#include "matrix.h"

void draw(int, int);

const int drawDelayMs = 500;
uint32_t lastDraw = 0;

const int kBorderWidth = 2;

int main() {
    delay(100);
    pinMode(13, OUTPUT);
    LEDS.addLeds<WS2811, 2, GRB>(Matrix::frameBuffer, NUM_LEDS);
    LEDS.setBrightness(255);
    set_max_power_in_volts_and_milliamps(5, 800);
    set_max_power_indicator_LED(13);

    int xOffset = 0;
    while(1) {
        // Apply some blurring to whatever's already on the matrix
        // Note that we never actually clear the matrix, we just constantly
        // blur it repeatedly. Since the blurring is 'lossy', there's
        // an automatic trend toward black -- by design.
        uint8_t blurAmount = beatsin8(2,20,255);
        blur2d(Matrix::frameBuffer, kMatrixWidth, kMatrixHeight, blurAmount);
        
        // Use two out-of-sync sine waves
        uint8_t i = beatsin8( 27, kBorderWidth, kMatrixHeight-kBorderWidth);
        uint8_t j = beatsin8( 41, kBorderWidth, kMatrixWidth-kBorderWidth);
        // Also calculate some reflections
        uint8_t ni = (kMatrixWidth-1)-i;
        uint8_t nj = (kMatrixWidth-1)-j;
        // The color of each point shifts over time, each at a different speed.
        uint16_t ms = millis();
        Matrix::frameBuffer[XYsafe( i, j)] += CHSV( ms / 11, 200, 255);
        Matrix::frameBuffer[XYsafe( j, i)] += CHSV( ms / 13, 200, 255);
        Matrix::frameBuffer[XYsafe(ni,nj)] += CHSV( ms / 17, 200, 255);
        Matrix::frameBuffer[XYsafe(nj,ni)] += CHSV( ms / 29, 200, 255);
        Matrix::frameBuffer[XYsafe( i,nj)] += CHSV( ms / 37, 200, 255);
        Matrix::frameBuffer[XYsafe(ni, j)] += CHSV( ms / 41, 200, 255); 
        
        show_at_max_brightness_for_power();
        delay_at_max_brightness_for_power(30);
    }
}

#include <FastLED.h>
#include "matrix.h"

void draw(int, int);

const int drawDelayMs = 500;
uint32_t lastDraw = 0;

int main() {
    delay(100);
    pinMode(13, OUTPUT);
    LEDS.addLeds<WS2811, 2, GRB>(Matrix::frameBuffer, NUM_LEDS);
    LEDS.setBrightness(16);
    set_max_power_in_volts_and_milliamps(5, 1000);
    set_max_power_indicator_LED(13);

    int xOffset = 0;
    while(1) {
        uint32_t now = millis();
        if (now > lastDraw + drawDelayMs) {
            lastDraw = now;
            draw(xOffset, 0);
            xOffset += 1;
            if (xOffset > 28) xOffset = -3;
        }
        
        blur2d(Matrix::frameBuffer, kMatrixWidth, kMatrixHeight, 32);

        show_at_max_brightness_for_power();
        delay_at_max_brightness_for_power(30);
    }
}

bool isCellBright(int xCoord, int yCoord, int iteration) {
    
    int threshold = (1 << iteration);
    
    if (xCoord >= threshold && yCoord >= threshold)
        return false;
    else if (xCoord < 0 || yCoord < 0)
        return false;
    else if (xCoord == 0 || yCoord == 0)
        return true;
    else
        return isCellBright(xCoord % threshold, yCoord % threshold, iteration - 1);
}

const int maxIterations = 4;

void draw(int xOffset, int yOffset) {
    for(int xCoord = 0; xCoord < 16; xCoord++) {
        for(int yCoord = 0; yCoord < 16; yCoord++) {
            
            CRGB color = isCellBright(xCoord + xOffset, yCoord + yOffset, maxIterations) ? 0xFFFFFF : 0x000000;
            Matrix::frameBuffer[XYsafe(xCoord, yCoord)] = color;
        }
    }
}
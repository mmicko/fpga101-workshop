#include <stdint.h>
#include <stdio.h>
#include "board.h"

#define reg_leds (*(volatile uint32_t*)0x03000000)

uint8_t leds[3] = { 0, 0, 0};

void led_init(void) {
    leds[0] = 0;
    leds[1] = 0;
    leds[2] = 0;
    reg_leds = 0;
}

void led_state(int led, int state) {
    leds[led-1] = state ? 1 : 0;
    reg_leds = ((leds[2] & 1) << 2) + ((leds[1] & 1) << 1) + ((leds[0] & 1) << 0);
}

void led_toggle(int led) {
    leds[led-1] = ~leds[led-1];
    reg_leds = ((leds[2] & 1) << 2) + ((leds[1] & 1) << 1) + ((leds[0] & 1) << 0);
}


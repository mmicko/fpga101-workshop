#include <stdint.h>
#include <stdio.h>
#include "board.h"

#define reg_io   ((volatile uint32_t*)0x03000000)
#define reg_text ((volatile uint32_t*)0x04000000)
#define reg_attr ((volatile uint32_t*)0x05000000)

uint8_t leds[3] = { 0, 0, 0};

void led_init(void) {
    leds[0] = 0;
    leds[1] = 0;
    leds[2] = 0;
    reg_io[0] = 0;
}

void led_state(int led, int state) {
    leds[led-1] = state ? 1 : 0;
    reg_io[0] = ((leds[2] & 1) << 2) + ((leds[1] & 1) << 1) + ((leds[0] & 1) << 0);
}

void led_toggle(int led) {
    leds[led-1] = ~leds[led-1];
    reg_io[0] = ((leds[2] & 1) << 2) + ((leds[1] & 1) << 1) + ((leds[0] & 1) << 0);
}

int switch_get(int sw) 
{
	return ((reg_io[0] >> (sw-1)) & 1) == 1;
}

#define LCD_WIDTH  40
#define LCD_HEIGHT 15


static int cursor_x = 0;
static int cursor_y = 0;
static int cursor_addr = 0;

int lcd_pos_x()
{
	return cursor_x;
}

int lcd_pos_y()
{
	return cursor_y;
}

void lcd_newline() {
	if(cursor_y < LCD_HEIGHT) {
		cursor_x = 0;
		cursor_y++;
		cursor_addr = cursor_y * LCD_WIDTH;

	} else {
		lcd_clear();
		cursor_y = 0;
		cursor_x = 0;
		cursor_addr = 0;
	}
}

void lcd_putch(char c) {
	if (c == '\n') 
	{
		lcd_newline();
		return;
	}
	if (cursor_x >= (LCD_WIDTH - 1)) 
	{
		lcd_newline();
	}

	reg_text[cursor_addr++] = c;
	cursor_x++;	
}

void lcd_write(const char *data, int len)
{
	while (*data)
		lcd_putch(*(data++));
}

void lcd_clear()
{
	cursor_x = 0;
	cursor_y = 0;
	cursor_addr = 0;
	
	for(int i = 0; i < 1024; i++)
		reg_text[i] = 0x20;
	for(int i = 0; i < 1024; i++)
		reg_attr[i] = 0x0f;
}

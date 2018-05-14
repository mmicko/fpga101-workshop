#ifndef MICROPY_INCLUDED_UPDUINO_BOARD_H
#define MICROPY_INCLUDED_UPDUINO_BOARD_H

int switch_get(int sw);

void led_init(void);
void led_state(int led, int state);
void led_toggle(int led);

int lcd_pos_x();
int lcd_pos_y();
void lcd_write(const char *data, int len);
void lcd_clear();
void lcd_move(int xpos, int ypos);

#endif // MICROPY_INCLUDED_UPDUINO_BOARD_H

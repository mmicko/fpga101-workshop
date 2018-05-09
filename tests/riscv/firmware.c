#include <stdint.h>
#include <stdbool.h>

#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

#define reg_io   ((volatile uint32_t*)0x03000000)
#define reg_text ((volatile uint32_t*)0x04000000)
#define reg_attr ((volatile uint32_t*)0x05000000)
#define reg_tone ((volatile uint32_t*)0x06000000)

#define LCD_WIDTH  40
#define LCD_HEIGHT 15


static int cursor_x = 0;
static int cursor_y = 0;
static int cursor_addr = 0;


void lcd_clear() 
{
	cursor_x = 0;
	cursor_y = 0;
	cursor_addr = 0;
	
	for(int i = 0; i < 600; i++)
		reg_text[i] = 0x20;
	for(int i = 0; i < 600; i++)
		reg_attr[i] = 0x1f;
}

// --------------------------------------------------------
void lcd_newline() {
	if(cursor_y < (LCD_HEIGHT - 1)) {
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
	if((c == '\n') || (cursor_x >= (LCD_WIDTH - 1))) {
		lcd_newline();
	} else {
		reg_text[cursor_addr++] = c;
		cursor_x++;
	}
}


// --------------------------------------------------------
void putchar(char c)
{
	if (c == '\n')
		putchar('\r');
	if (c != '\r')
		lcd_putch(c);		
	reg_uart_data = c;
}

void print(const char *p)
{
	while (*p)
		putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
	for (int i = 7; i >= 0; i--) {
		char c = "0123456789abcdef"[(v >> (4*i)) & 15];
		if (c == '0' && i >= digits) continue;
		putchar(c);
		digits = i;
	}
}

void delay_cyc(uint32_t cycles) {
	uint32_t cycles_begin, cycles_now;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
	do {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
	} while((cycles_now - cycles_begin) < cycles);
	
}

void delay_ms(uint32_t ms)
{
	delay_cyc(12050*ms);
}

char getchar_prompt(char *prompt)
{
	int32_t c = -1;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	if (prompt)
		print(prompt);

	while (c == -1) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000) {
			if (prompt)
				print(prompt);
			cycles_begin = cycles_now;
		}
		c = reg_uart_data;
	}
	return c;
}

char getchar()
{
	return getchar_prompt(0);
}

#define TONE_A4 12000000/440/2
#define TONE_B4 12000000/494/2
#define TONE_C5 12000000/523/2
#define TONE_D5 12000000/587/2
#define TONE_E5 12000000/659/2
#define TONE_F5 12000000/698/2
#define TONE_G5 12000000/783/2

void play_tone(int tone, int lenght,int delay)
{
	reg_tone[0] = tone;
	if (lenght>0) delay_ms(lenght);
	reg_tone[0] = 0;
	if (delay>0) delay_ms(delay);	
}

// --------------------------------------------------------
void main()
{
	reg_uart_clkdiv = 1250;
	
	lcd_clear();

	print("\n");
	print("  ____  _          ____         ____\n");
	print(" |  _ \\(_) ___ ___/ ___|  ___  / ___|\n");
	print(" | |_) | |/ __/ _ \\___ \\ / _ \\| |\n");
	print(" |  __/| | (_| (_) |__) | (_) | |___\n");
	print(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
	print("\n");
	print("    FPGA 101 Workshop Badge \n");
	print("    26th May - Belgrade - Hackaday\n");

	
	for(int i=0;i<10;i++)
	{
		play_tone(TONE_A4,200,10);
		play_tone(TONE_F5,200,10);
	}
}


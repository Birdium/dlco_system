#ifndef __MYSYS_H__
#define __MYSYS_H__

#include <limits.h>

#define VGA_START    0x00200000
#define VGA_MAXLINE  30
#define VGA_MAXCOL   70

#define KEY_REG      0x00300000

#define CLK_ADDR     0x00400000
#define LINE_ADDR    0x00500000
#define COLOR_ADDR   0x00500004

#define GMEM_ADDR    0x00600000

#define SW_ADDR      0x00700000
#define BUTTON_ADDR  0x00800000
#define LEDR_ADDR    0x00900000
#define HEX_ADDR     0x00a00000

#define KEY_LEFT 180
#define KEY_RIGH 182
#define KEY_UP   184
#define KEY_DW   178
#define BACKSPACE 8
#define ENTER 13

void putstr(const char* str);
void putch(char ch);
unsigned gettimeofday(); 

char readkey();
void vga_roll();

void blink();

void vga_init(void);
void swtch();
void draw(int x, int y, unsigned pixel);
void draw_rect(int x, int y, unsigned buf[], int w, int h);

void sleep(unsigned tm);

int get_sw(int index);
int get_button(int index);

void set_ledr(int status); 
void set_hex(int index, int status);

#endif
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

void sleep(int tm);

#endif
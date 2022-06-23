#include "sys.h"
#include "stdarg.h"

#define INT32_MIN -2147483648
#define panic(x)

#define bool int
#define true  1
#define false 0

#define VGA_CUR vga_start[(((*start_line) + vga_line) << 7) + vga_ch]

#define VGA(line, ch) vga_start[(((*start_line) + line) << 7) + (ch)]

#define BACKSPACE 8
#define ENTER 10

char* vga_start = (char*) VGA_START;
int*  time = (int*) CLK_ADDR;
int*  start_line = (int*) LINE_ADDR;
int*  key  = (int*) KEY_REG;
int   vga_line=0;
int   vga_ch=0;

int gettimeofday(){
  return *time;
}

void vga_init(){
  vga_line = 0;
  vga_ch =0;
  for(int i=0;i<VGA_MAXLINE;i++)
    for(int j=0;j<VGA_MAXCOL;j++)
      VGA(i, j) = 0;
}

void vga_roll(){
  (*start_line)++;
  for(int j=0;j<VGA_MAXCOL;j++){
    VGA(VGA_MAXLINE-1, j) = 0;
  }
}

void putch(char ch) {
  switch (ch){
    case BACKSPACE:
      if (vga_line || vga_ch) {
        VGA_CUR = 0;
        if (vga_ch == 0) {
                vga_line--;
                vga_ch = VGA_MAXCOL - 1;
        }
        else vga_ch--;
      }
      break;
    case ENTER:
      vga_line++;
      if (vga_line>=VGA_MAXLINE) {
        vga_roll();
        vga_line = VGA_MAXLINE - 1;
      } 
      vga_ch = 0;
      break;
    default:
      VGA_CUR = ch;
      vga_ch++;
      if(vga_ch>=VGA_MAXCOL){
        vga_line++; 
        if(vga_line>=VGA_MAXLINE){
          vga_roll();
          vga_line = VGA_MAXLINE - 1;
        } 
        vga_ch = 0;
      }
      break;
  }
  return;
}

void putstr(const char *str){
  for(char* p=str;*p!=0;p++)
    putch(*p);
}

int readkey() {
  return *key;
}

static void putu_(unsigned x) {
  if (x == 0) return ;
  putu_(x / 10);
  putch('0' + x % 10);
}

void putu(unsigned x) {
  if (x == 0) putch('0');
  else putu_(x);
}

void puti(int x) {
  if (x < 0) {
    x = -x;
    putch('-');
  }
  putu(x);
}

void printf(const char *fmt, ...) {
  va_list ap; va_start(ap, fmt);
  for (const char *s = fmt; *s != '\0'; s ++) {
    if (*s != '%') {
      putch(*s);
      continue;
    }
    s ++;
    switch (*s) {
      case '%': putch('%');                       break;
      case 'c': putch(va_arg(ap, int));           break;
      case 'u': putu(va_arg(ap, unsigned));       break;
      case 'd': puti(va_arg(ap, int));            break;
      case 's': putstr(va_arg(ap, const char *)); break;
    }
  }
  va_end(ap);
}

void puts(const char *str) {
  putstr(str);
}
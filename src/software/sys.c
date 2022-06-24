#include "sys.h"
#include "stdarg.h"

#define VGA_CUR vga_start[(((*start_line) + vga_line) << 7) + vga_ch]

#define VGA(line, ch) vga_start[(((*start_line) + line) << 7) + (ch)]

char* vga_start = (char*) VGA_START;
unsigned*  time = (unsigned*) CLK_ADDR;
int*  start_line = (int*) LINE_ADDR;
int*  key  = (int*) KEY_REG;
int   vga_line=0;
int   vga_ch=0;

unsigned gettimeofday(){
  return *time;
}

void sleep(int tm) {
    int cnt = 0;
    tm *= 10000;
    while (cnt < tm) cnt ++;
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

void blink() {
  static char ch = 0;
  ch = (!ch) ? 0x5F : 0;
  VGA_CUR = ch;
}

void putch(char ch) {
  if (ch == '\n') {
    ch = ENTER;
  }
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
      VGA_CUR = 0;
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
  for (const char *p = str; *p; p ++) {
    putch(*p);
  }
}

char readkey() {
  return (char)(*key);
}

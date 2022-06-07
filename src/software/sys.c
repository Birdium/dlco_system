#include "sys.h"

#define VGA_CUR vga_start[(vga_line << 7) + vga_ch]

#define VGA(line, ch) vga_start[((line) << 7) + (ch)]

#define BACKSPACE 8
#define ENTER 10

char* vga_start = (char*) VGA_START;
int*  time = (int*) CLK_ADDR;
int*  start_line = (int*) LINE_ADDR;
int   vga_line=0;
int   vga_ch=0;

void vga_init(){
    vga_line = 0;
    vga_ch =0;
    for(int i=0;i<VGA_MAXLINE;i++)
        for(int j=0;j<VGA_MAXCOL;j++)
            VGA(i, j) = 0;
}

void vga_roll(){
    *start_line++;
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

void putstr(char *str){
    for(char* p=str;*p!=0;p++)
      putch(*p);
}

int gettimeofday(){
    return *time;
}
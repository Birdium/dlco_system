#define VGA_START    0x00200000
#define VGA_MAXLINE  30
#define VGA_MAXCOL   70

#define CLK_ADDR     0x00400000
#define LINE_ADDR    0x00500000
#define COLOR_ADDR   0x00500004


void putstr(char* str);
void putch(char ch);
int gettimeofday();

void vga_init(void);
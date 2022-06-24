#define VGA_START    0x00200000
#define VGA_MAXLINE  30
#define VGA_MAXCOL   70

#define KEY_REG      0x00300000

#define CLK_ADDR     0x00400000
#define LINE_ADDR    0x00500000
#define COLOR_ADDR   0x00500004

#define BACKSPACE 8
#define ENTER 10

void putstr(const char* str);
void putch(char ch);
int gettimeofday(); 

int readkey();

void vga_init(void);

void printf (const char *format, ...);
void puts(const char *str);

void sleep(int tm);
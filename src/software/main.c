#include "sys.h"
char hello[]="Hello World!\n\0";
char nyan[]="Nyan!\n\0";
char nunhehheh[]="Nunhehhehaaaaaaaaaahhh!\n\0";
int main();
//setup the entry point
void entry()
{
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}
int main()
{
    vga_init();
    putstr(hello);
    putstr(nyan);
    putstr(nunhehheh);
    while (1)
    {
        putstr(hello);
        putstr(nyan);
        putstr(nunhehheh);
    };
    return 0;
}
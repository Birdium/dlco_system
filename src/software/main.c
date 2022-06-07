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

// void Hello(){
//     putstr(hello);
// }

int fib(int n){
    int a = 1, b = 1;
    for(int i = 2; i <= n; i++){
        b = a + b;
        a = b - a;
    } 
    return b;
}

int main()
{
    vga_init();
    putstr(hello);
    putstr(nyan);
    putstr(nunhehheh);
    while (1)
    {
        int cnt = 0;
        while(cnt < 250000000) cnt ++;
        putstr(hello);
        putstr(nyan);
        putstr(nunhehheh);
    };
    return 0;
}
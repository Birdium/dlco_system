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

void wait(int t) {
    int cnt = 0;
    t *= 100000;
    while (cnt < t) cnt ++;
}

int main()
{
    vga_init();
    putstr(nyan);

    while (1) {
        printf("%d",readkey());
        wait(20);
    }
    return 0;
}
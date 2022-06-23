#include "sys.h"

#include "stdio.h"
#include "string.h"

char hello[]="Hello World!\n\0";
char nyan[]="Nyan!\n\0";
char nunhehheh[]="Nunhehhehaaaaaaaaaahhh!\n\0";

int main();

//setup the entry point
void entry() {
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

// + sizeof(#str) 是为了跳过命令 "cmd args" 的前缀，把 args 作为参数传入 exec_##str
#define CMD_EXEC(str) if (!strncmp(cmd, #str, sizeof(#str))) exec_##str(cmd + sizeof(#str));
#define CMD_DEF( str) void exec_##str(const char *cmd);
#define COMMANDS(_) _(echo) _(fib) _(eval)

COMMANDS(CMD_DEF)

void exec(const char *cmd) {
    COMMANDS(CMD_EXEC);
}

int main() {
    vga_init();

    static char cmd[255];
    int ncmd = 0;
    putstr(nyan);

    while (1) {
        // sleep(1);
        int key = readkey();
        cmd[ncmd ++] = key;
        putch(key);

        if (key == 10) { // \n
            exec(cmd);
        }
    }
    return 0;
}
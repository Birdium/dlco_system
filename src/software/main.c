#include "sys.h"

#include "stdio.h"
#include "string.h"

#define PROMPT "Nyan>"

int main();

//setup the entry point
void entry() {
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

// + sizeof(#str) 是为了跳过命令 "cmd args" 的前缀，把 args 作为参数传入 exec_##str
#define CMD_EXEC(str) if (!strncmp(cmd, #str, sizeof(#str))) { \
    exec_##str(cmd + sizeof(#str)); \
    return 0; }
#define CMD_DEF( str) void exec_##str(const char *cmd);
#define COMMANDS(_) _(echo) _(fib) _(eval)

COMMANDS(CMD_DEF)

int exec(const char *cmd) {
    COMMANDS(CMD_EXEC);
    printf("%s: command not found\n", cmd);
    return 1;
}

int main() {
    static char cmd[255];
    int ncmd = 0, key = 0, uptime = gettimeofday();

    vga_init();
    putstr(PROMPT);

    for (; ; ) {
        if (gettimeofday() - uptime > 1000) {
            uptime = gettimeofday();
            blink();
        }
        switch (key = readkey()) {
            case 0: {
                break;
            }
            case BACKSPACE: {
                if (ncmd) {
                    putch(key);
                    ncmd --;
                }
                break;
            }
            case ENTER: {
                cmd[ncmd] = '\0';
                exec(cmd);
                ncmd = 0;
                putstr(PROMPT);
                break;
            }
            default: {
                putch(key);
                cmd[ncmd ++] = key;
                break;
            }
        }
    }
    return 0;
}
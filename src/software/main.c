#include "sys.h"

#include "kstdio.h"
#include "kstring.h"

#define PROMPT "Nyan>"
#define NR_LINE 35
#define NR_COL  55

static int next(int x) {
    return (x + 1) % NR_LINE;
}

static int prev(int x) {
    return (x + NR_LINE - 1) % NR_LINE;
}

int main();

//setup the entry point
void entry() {
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

// + sizeof(#str) 是为了跳过命令 "cmd args" 的前缀，把 args 作为参数传入 exec_##str
#define CMD_EXEC(str) if (!kstrncmp(cmd, #str, sizeof(#str) - 1)) { \
    exec_##str(cmd + sizeof(#str)); \
    return 0; }
#define CMD_DEF( str) void exec_##str(const char *cmd);
#define COMMANDS(_) _(echo) _(fib) _(eval) _(clear)

COMMANDS(CMD_DEF)

int exec(const char *cmd) {
    COMMANDS(CMD_EXEC);
    kprintf("%s: command not found\n", cmd);
    return 1;
}

int main() {
    static char cmd[NR_LINE][NR_COL];
    int ncmd = 0;
    int head = 0, tail = 0, cur = 0;
    unsigned uptime = gettimeofday();
    char key;

    vga_init();
    putstr(PROMPT);

    for (; ; ) {
        if (gettimeofday() - uptime > 1000) {
            uptime = gettimeofday();
            blink();
        }
        switch (key = readkey()) {
            case 0: break;
            case KEY_UP: {
                if (cur != head) {
                    for (; ncmd; ncmd --) {
                        putch(BACKSPACE);
                    }
                    cur = prev(cur);
                    for (; cmd[cur][ncmd]; ncmd ++) {
                        putch(cmd[cur][ncmd]);
                    }
                }
                break;
            }
            case KEY_DW: {
                break;
            }
            case BACKSPACE: {
                if (ncmd) {
                    putch(key);
                    cmd[cur][ncmd] = '\0';
                    ncmd --;
                }
                break;
            }
            case ENTER: {
                putch(ENTER);
                cmd[cur][ncmd] = '\0';
                exec(cmd[cur]);
                tail = cur = next(cur);
                if (tail == head) {
                    head = next(head);
                }
                ncmd = 0;
                cmd[cur][ncmd] = '\0';
                putstr(PROMPT);
                break;
            }
            default: {
                if (ncmd < 29) {
                    putch(key);
                    cmd[cur][ncmd ++] = (char)key;
                }
                break;
            }
        }
    }
    return 0;
}
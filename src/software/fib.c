#include "kstdio.h"

void exec_fib(const char *cmd) {
    while (*cmd == ' ') cmd ++;
    int n = 0;
    while (*cmd >= '0' && *cmd <= '9') {
        n = n * 10 + *cmd - '0';
        cmd ++;
    }
    int a = 1, b = 1;
    for(int i = 2; i <= n; i++){
        b = a + b;
        a = b - a;
    } 
    kprintf("%d\n", b);
}

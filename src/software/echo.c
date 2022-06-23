#include "sys.h"

void exec_echo(const char *cmd) {
    while (*cmd == ' ') cmd ++;
    putstr(cmd);
}
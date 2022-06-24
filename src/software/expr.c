#include "kstdio.h"
#include "kstring.h"

#define NR_TOKENS 255

typedef struct token_t {
    enum {
        TOKEN_NUM,
        TOKEN_CHAR,
    } type;
    int ch;
    int val;
} token_t;

token_t tokens[NR_TOKENS];

static int prior[] = {
    ['^'] = 5,
    ['*'] = 4,
    ['/'] = 4,
    ['+'] = 3,
    ['-'] = 3,
    [255] = 0,
} ;

int ntok = 0;

int next_bracket(int i) {
    int cnt = 1;
    for (i ++; cnt; i ++) {
        if (tokens[i].type != TOKEN_CHAR)
            continue;
        switch (tokens[i].ch) {
            case '(': cnt += 1; break;
            case ')': cnt -= 1; break;
            default: break;
        }
    }
    return i;
}

int LB(token_t tk) {
    return tk.type == TOKEN_CHAR && tk.ch == '(';
}

int RB(token_t tk) {
    return tk.type == TOKEN_CHAR && tk.ch == ')';
}

int ksm(int a, int b) {
    int res = 1;
    while (b --) {
        res *= a;
    }
    return res;
}

int eval(const int l, const int r) {
    // empty
    if (r <= l) {
        return 0;
    }
    if (l + 1 == r) {
        return tokens[l].val;
    }
    // ( expr )
    if (LB(tokens[l]) && RB(tokens[r - 1])) {
        return eval(l + 1, r - 1);
    }
    int i = l, p = -1;
    for (; i != r; i ++) {
        if (LB(tokens[i])) {
            i = next_bracket(i);
            if (i == r) {
                break;
            }
        }
        if (tokens[i].type == TOKEN_NUM) {
            continue;
        }

        if (p == -1 || prior[tokens[i].ch] < prior[tokens[p].ch]) {
            p = i;
        }

        if (p != -1 && tokens[p].ch == '-' && tokens[i].ch == '+') {
            p = i;
        }
    }
    int lexpr = eval(l, p);
    int rexpr = eval(p + 1, r);
    switch (tokens[p].ch) {
        case '^': return ksm(lexpr , rexpr);
        case '*': return     lexpr * rexpr;
        case '/': return     lexpr / rexpr;
        case '+': return     lexpr + rexpr;
        case '-': return     lexpr - rexpr;
    }
    return 0;
}

void parse(const char *expr, int len) {
    int num = 0;
    int is_num = 0;
    for (const char *p = expr; p != expr + len; p ++) {
        char ch = *p;
        if (ch >= '0' && ch <= '9') {
            num = num * 10 + ch - '0';
            is_num = 1;
        } else {
            if (is_num) {
                tokens[ntok ++] = (token_t) {
                    .type = TOKEN_NUM,
                    .val = num, .ch = -1
                };
                num = 0;
                is_num = 0;
            }
            if (ch != ' ' && ch != '\n' && ch != '\t') {
                tokens[ntok ++] = (token_t) {
                    .type = TOKEN_CHAR,
                    .val = -1, .ch = ch,
                };
            }
        }
    }
    if (is_num) {
        tokens[ntok ++] = (token_t) {
            .type = TOKEN_NUM,
            .val = num, .ch = -1
        };
    }
}

#include <stdio.h>
#include <string.h>

void exec_eval(const char *cmd) {
    while (*cmd == ' ') cmd ++;
    ntok = 0;
    parse(cmd, strlen(cmd));
    printf("%d\n", eval(0, ntok));
}

int main() {
    static char s[255];
    while (1) {
        fgets(s, sizeof(s), stdin);
        exec_eval(s);
    }
}
#ifdef DEBUG
#include <stdio.h>
#include <string.h>
#else
#include "kstdio.h"
#include "kstring.h"
#endif

#include "sys.h"

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
#include "sys.h"

void exec_echo(const char *cmd) {
    while (*cmd == ' ') cmd ++;
    putstr(cmd);
    putch('\n');
}

void exec_clear(__attribute__((unused))const char *cmd ) {
    vga_init();
}

static int next_bracket(int i) {
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

static int LB(token_t tk) {
    return tk.type == TOKEN_CHAR && tk.ch == '(';
}

static int RB(token_t tk) {
    return tk.type == TOKEN_CHAR && tk.ch == ')';
}

static int ksm(int a, int b) {
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

static void parse(const char *expr, int len) {
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

void exec_eval(const char *cmd) {
    while (*cmd == ' ') cmd ++;
    ntok = 0;
#ifdef DEBUG
    parse(cmd, strlen(cmd));
    printf("%d\n", eval(0, ntok));
#else
    parse(cmd, kstrlen(cmd));
    kprintf("%d\n", eval(0, ntok));
#endif
}

#ifdef DEBUG

int main() {
    static char s[255];
    while (1) {
        fgets(s, sizeof(s), stdin);
        exec_eval(s);
    }
}

#endif

void exec_gtest(__attribute__((unused))const char *cmd ) {
    swtch();
    char key;
    unsigned col = 0xFF0000;
    unsigned tm = gettimeofday();
    draw(0, 0, 0xF); draw(0, 1, 0xF); draw(0, 2, 0xF); draw(0, 3, 0xF);
    draw(1, 0, 0xF); draw(1, 1, 0xF); draw(1, 2, 0xF); draw(1, 3, 0xF);
    draw(2, 0, 0xF); draw(2, 1, 0xF); draw(2, 2, 0xF); draw(2, 3, 0xF);
    draw(3, 0, 0xF); draw(3, 1, 0xF); draw(3, 2, 0xF); draw(3, 3, 0xF);
    draw(4, 0, 0xF); draw(4, 1, 0xF); draw(4, 2, 0xF); draw(4, 3, 0xF);
    draw(5, 0, 0xF); draw(5, 1, 0xF); draw(5, 2, 0xF); draw(5, 3, 0xF);
    int i = 0, j = 0;
    while (1) {
        if ((key = readkey()) == 'q') {
            swtch();
            return ;
        }

        if (gettimeofday() - tm > 10000) {
            tm = gettimeofday();
            if (col == 0xF) {
                col = 0xF00;
            } else {
                col >>= 4;
            }
            j = (j + 1) & 127;
            if (!j) {
                i = (i + 1) & 127;
            }
        }
        draw(i, j, col);
    }
}

#define FPS 30
#define N   32

static inline unsigned pixel(unsigned r, unsigned g, unsigned b) {
  return (r << 16) | (g << 8) | b;
}
static inline unsigned R(unsigned p) { return p >> 16; }
static inline unsigned G(unsigned p) { return (p >> 8) & 0xFF; }
static inline unsigned B(unsigned p) { return p & 0xFF; }

static unsigned canvas[N][N];
static int used[N][N];

static unsigned color_buf[32 * 32];

static unsigned convert(unsigned pixel) {
    unsigned r = R(pixel) >> 4;
    unsigned g = G(pixel) >> 4;
    unsigned b = B(pixel) >> 4;
    return (r << 8) | (g << 4) | b;
}

static void redraw() {
    int w = 160 / N;
    int h = 128 / N;
  int block_size = w * h;

  int x, y, k;
  for (y = 0; y < N; y ++) {
    for (x = 0; x < N; x ++) {
      for (k = 0; k < block_size; k ++) {
        color_buf[k] = convert(canvas[y][x]);
      }
      draw_rect(x * w, y * h, color_buf, w, h);
    }
  }
}

static unsigned p(int tsc) {
  unsigned b = tsc & 0xff;
  return pixel(b * 6, b * 7, b);
}

static void update() {
  static int tsc = 0;
  static int dx[4] = {0, 1, 0, -1};
  static int dy[4] = {1, 0, -1, 0};

  tsc ++;

  for (int i = 0; i < N; i ++)
    for (int j = 0; j < N; j ++) {
      used[i][j] = 0;
    }

  int init = tsc * 1;
  canvas[0][0] = p(init); used[0][0] = 1;
  int x = 0, y = 0, d = 0;
  for (int step = 1; step < N * N; step ++) {
    for (int t = 0; t < 4; t ++) {
      int x1 = x + dx[d], y1 = y + dy[d];
      if (x1 >= 0 && x1 < N && y1 >= 0 && y1 < N && !used[x1][y1]) {
        x = x1; y = y1;
        used[x][y] = 1;
        canvas[x][y] = p(init + step / 2);
        break;
      }
      d = (d + 1) % 4;
    }
  }
}

void exec_vtest(__attribute__((unused)) const char *cmd) {
  swtch();
  unsigned last = 0;
  unsigned fps_last = 0;
  int fps = 0;

  while (1) {
    unsigned upt = gettimeofday() / 1000;
    if (readkey() == 'q') {
        swtch();
        return ;
    }
    if (upt - last > 1000 / FPS) {
      update();
      redraw();
      last = upt;
      fps ++;
    }
    if (upt - fps_last > 1000) {
      // display fps every 1s
    //   printf("%d: FPS = %d\n", upt, fps);
      fps_last = upt;
      fps = 0;
    }
  }
}

void exec_devtest(__attribute__((unused)) const char *cmd) {
    int status = 0;
    int cnt = 0;
    while (1) {
        int x = 0;
        switch (status) {
            case 0: x = get_sw(cnt); kprintf("Get sw No.%d: %d\n", cnt, x); break;
            case 1: x = get_button(cnt); kprintf("Get button No.%d: %d\n", cnt, x); break;
            case 2: set_ledr(cnt); kprintf("Set ledr: %d\n", cnt); break;
            case 3: set_hex(cnt, cnt); kprintf("Set Hex No.%d: %d\n", cnt, cnt); break;
            default: break;
        }
        cnt = (cnt+1) % 4;
        sleep(200000000);
        int key = readkey();
        if (key == 'q') status = 0; 
        else if (key == 'w') status = 1; 
        else if (key == 'e') status = 2; 
        else if (key == 'r') status = 3; 
        else if (key == 'z') return;
    }
}

void exec_time(const char *cmd){
    kprintf("%u\n", gettimeofday());
    return;
}
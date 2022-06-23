#include <stdarg.h>
#include "sys.h"

static void putu_(unsigned x) {
  if (x == 0) return ;
  putu_(x / 10);
  putch('0' + x % 10);
}

static void putu(unsigned x) {
  if (x == 0) putch('0');
  else putu_(x);
}

static void puti(int x) {
  if (x < 0) {
    x = -x;
    putch('-');
  }
  putu(x);
}

void printf(const char *fmt, ...) {
  va_list ap; va_start(ap, fmt);
  for (const char *s = fmt; *s != '\0'; s ++) {
    if (*s != '%') {
      putch(*s);
      continue;
    }
    s ++;
    switch (*s) {
      case '%': putch('%');                       break;
      case 'c': putch(va_arg(ap, int));           break;
      case 'u': putu(va_arg(ap, unsigned));       break;
      case 'd': puti(va_arg(ap, int));            break;
      case 's': putstr(va_arg(ap, const char *)); break;
    }
  }
  va_end(ap);
}

void puts(const char *str) {
  putstr(str);
}
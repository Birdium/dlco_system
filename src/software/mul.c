unsigned int __mulsi3(unsigned int a, unsigned int b) {
    unsigned int res = 0;
    while (a) {
        if (a & 1) res += b;
        a >>= 1;
        b <<= 1;
    }
    return res;
}

unsigned int __umodsi3(unsigned int a, unsigned int b) {
    unsigned int bit = 1;
    unsigned int res = 0;

    while (b < a && bit && !(b & (1UL << 31))) {
        b <<= 1;
        bit <<= 1;
    }
    while (bit) {
        if (a >= b) {
            a -= b;
            res |= bit;
        }
        bit >>= 1;
        b >>= 1;
    }
    return a;
}

unsigned int __udivsi3(unsigned int a, unsigned int b) {
    unsigned int bit = 1;
    unsigned int res = 0;

    while (b < a && bit && !(b & (1UL << 31))) {
        b <<= 1;
        bit <<= 1;
    }
    while (bit) {
        if (a >= b) {
            a -= b;
            res |= bit;
        }
        bit >>= 1;
        b >>= 1;
    }
    return res;
}

/*
 * 假装这是signed
 * 规定 `a%b == a - (a/b)*b`
 * 溢出是UB
 */
int __divsi3(int a, int b) {
    if (a == 0 || b == 0) return 0;
    if (a < 0 && b < 0) {
        a = -a; b = -b;
    } else if (a > 0 && b < 0) {
        b = -b;
    } else if (a < 0 && b > 0) {
        a = -a;
    }
    return (int)__udivsi3((unsigned)a, (unsigned)b);
}

int __modsi3(int a, int b) {
    int c = __divsi3(a, b);
    return a - (int)__mulsi3((unsigned)b, (unsigned)c);
}
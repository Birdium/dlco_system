
int kstrlen(const char *str) {
    int len = 0;
    while (str[len]) len ++;
    return len;
}

int kstrcmp(const char *s1, const char *s2) {
  const char *a = s1, *b = s2;
  while (*a == *b && *a != '\0' && *b != '\0')
    a ++, b ++;
  if (*a == *b) return 0;
  else if (*a > *b) return 1;
  else return -1;
}

int kstrncmp(const char *s1, const char *s2, int n) {
  int i = 0; const char *a = s1, *b = s2;
  while (*a == *b && *a != '\0' && *b != '\0' && i < n)
    a ++, b ++, i ++;
  if (*a == *b || i == n) return 0;
  else if (*a > *b) return 1;
  else return -1;
}
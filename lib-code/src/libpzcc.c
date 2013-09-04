#include <stdio.h>
#include <math.h>


void WRITE_INT(int a, int w) {
    printf("%*d", w, a);
}

void WRITE_STRING(const char *a, int w) {
    printf("%*s", w, a);
}

void WRITE_REAL(long double a, int w, int d) {
    printf("%*.*Lf", w, d, a);
}

void WRITE_CHAR(char a, int w) {
    printf("%c",a);
}

void WRITE_BOOL(int a, int w) {
    const char * res;
    if (a == 1)
        res = "true";
    else
        res = "false";
    printf("%s",res);
}

long double pi(void) {
    return M_PI;
}


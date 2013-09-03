#include <stdio.h>


void WRITE_INT(int a, int w) {
    printf("%d",a);
}

void WRITE_STRING(char * a, int w) {
    printf("%s",a);
}

void WRITE_REAL(long double a, int w, int d) {
    printf("%Lf",a);
}

void WRITE_CHAR(char a, int w) {
    printf("%c",a);
}

void WRITE_BOOL(int a, int w) {
    const char * res;
    if (a == 0)
        res = "true";
    else
        res = "false";
    printf("%s",res);
}

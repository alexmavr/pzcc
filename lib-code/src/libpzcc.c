#include <stdio.h>
#include <math.h>
#include <string.h>

int READ_INT() {
    int i;
    scanf("%d", &i);
    return i;
}

double READ_REAL() {
    double i;
    scanf("%lf", &i);
    return i;
}

void READ_STRING(int size, char * s) {
    scanf("%*[^\n]", size, &s);
}

int READ_BOOL() {
    char i[10];
    READ_STRING(10, i);
    if (!strcmp(i, "true"))
        return 1;
    else
        return 0;
}

void WRITE_INT(int a, int w) {
    printf("%*d", w, a);
}

void WRITE_STRING(const char *a, int w) {
    printf("%*s", w, a);
}

void WRITE_REAL(double a, int w, int d) {
    printf("%*.*lf", w, d, a);
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

double pi(void) {
    return M_PI;
}

double arctan(double x) {
    return atan(x);
}

double ln(double x) {
    return log(x);
}

int TRUNC(double x) {
    return (int) trunc(x);
}

int ROUND(double x) {
    return (int) round(x);
}

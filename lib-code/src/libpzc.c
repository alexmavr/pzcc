#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>

bool used_scanf = false;

int READ_INT() {
    int i;
    scanf("%d", &i);
    used_scanf = true;
    return i;
}

double READ_REAL() {
    double i;
    scanf("%lf", &i);
    used_scanf = true;
    return i;
}

void READ_STRING(int size, char * s) {
    if (used_scanf) {
        scanf("%*c");
        used_scanf = false;
    }
    fgets(s, size+1, stdin);

    /* Remove excess newline */
    int len = strlen(s);
    if (s[len-1] == '\n')
       s[len-1] = 0;
}

int READ_BOOL() {
    char i[5];
    READ_STRING(5, i);
    if (!strcmp(i, "true") || !strcmp(i, "1"))
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

%{
#include <stdlib.h>
#include <stdarg.h>

#define T_eof 0

%}

%option noyywrap
%option yylineno

%%

\n { /* empty rule for yylineno */ }

. {return 1;}

%%

int main()
{
    int token;

    do {
        token = yylex();
        printf("token=%d, line=%d, lexeme=\"%s\"\n", token, yylineno, yytext);
    } while (token != T_eof);

    return 0;
}

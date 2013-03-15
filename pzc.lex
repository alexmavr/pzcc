%{
#include <stdlib.h>
#include <stdarg.h>

#define T_eof		0
#define T_bool		256
#define T_and		257
#define T_break		258
#define T_case		259
#define T_char		260
#define T_const		261
#define T_cont		262
#define T_def		263
#define T_do		264
#define T_downto	265
#define T_false		266
#define T_else		267
#define T_for		268
#define T_form		269
#define T_func		270
#define T_if		271
#define T_int		272
#define T_mod		273
#define T_next		274
#define T_not		275
#define T_or		276
#define T_proc		277
#define T_prog		278
#define T_real		279
#define T_ret		280
#define T_step		281
#define T_switch	282
#define T_to		283
#define T_true		284
#define T_while		285
#define T_write		286
#define T_wrln		287
#define T_wrsp		288
#define T_wrspln	289
#define T_id		290
#define T_integer	291
%}

%option noyywrap
%option yylineno

W		[ \t\r]
INT		0|[1-9[0-9]*

%%


"bool"					{return T_bool;}
"and"					{return T_and;}
"break"					{return T_break;}
"case"					{return T_case;}
"char"					{return T_char;}
"const"					{return T_const;}
"continue"				{return T_cont;}
"default"				{return T_def;}
"do"					{return T_do;}
"DOWNTO"				{return T_downto;}
"else"					{return T_else;}
"false"					{return T_false;}
"FOR"					{return T_for;}
"FORM"					{return T_form;}
"FUNC"					{return T_func;}
"if"					{return T_if;}
"int"					{return T_int;}
"MOD"					{return T_mod;}
"NEXT"					{return T_next;}
"not"					{return T_not;}
"or"					{return T_or;}
"PROC"					{return T_proc;}
"PROGRAM"				{return T_prog;}
"REAL"					{return T_real;}
"return"				{return T_ret;}
"STEP"					{return T_step;}
"switch"				{return T_switch;}
"TO"					{return T_to;}
"true"					{return T_true;}
"while"					{return T_while;}
"WRITE"					{return T_write;}
"WRITELN"				{return T_wrln;}
"WRITESP"				{return T_wrsp;}
"WRITESPLN"				{return T_wrspln;}


[a-zA-Z][0-9a-zA-Z_]*	{return T_id;}
{INT}						{return T_integer;}

"\/\/"[^\n]*			{/* one-line comment */}

[&;.\(\):,\[\]\{\}+\-*/%!]	{return yytext[0];}


{W}+						{/* ignore whitespace */}
\n						{ /* lines counted at yylineno */ }
.						{return 1; /* TODO: error */}

%%

int main (void)
{
    int token;

    do {
        token = yylex();
        printf("token=%d, line=%d, lexeme=\"%s\"\n", token, yylineno, yytext);
    } while (token != T_eof);

    return 0;
}

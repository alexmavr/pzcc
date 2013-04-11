%{
#include <stdio.h>
#include <stdlib.h>

void yyerror (const char * msg);
%}

%token T_print "print"
%token T_let "let"
%token T_for "for"
%token T_do "do"
%token T_begin "begin"
%token T_end "end"
%token T_if "if"
%token T_then "then"

%token T_const
%token T_var

%left '+' '-'
%left '*'

%%

program: T_var;

%%

void yyerror (const char * msg)
{
  fprintf(stderr, "Error: %s\n", msg);
  exit(1);
}

int main ()
{
  return yyparse();
}

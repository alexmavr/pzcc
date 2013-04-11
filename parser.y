%{
#include <stdio.h>
#include <stdlib.h>

void yyerror (const char * msg);
%}

%token T_bool
%token T_and
%token T_break
%token T_case
%token T_char
%token T_const
%token T_cont
%token T_def
%token T_do
%token T_downto
%token T_false
%token T_else
%token T_for
%token T_form
%token T_func
%token T_if
%token T_int
%token T_mod
%token T_next
%token T_not
%token T_or
%token T_proc
%token T_prog
%token T_real
%token T_ret
%token T_step
%token T_switch
%token T_to
%token T_true
%token T_while
%token T_write
%token T_wrln
%token T_wrsp
%token T_wrspln
%token T_id
%token T_CONST_integer
%token T_CONST_real
%token T_CONST_char
%token T_CONST_string
%token T_eq
%token T_diff
%token T_greq
%token T_leq
%token T_logand
%token T_logor
%token T_pp
%token T_mm
%token T_inc
%token T_dec
%token T_mul
%token T_div
%token T_opmod


%left '+' '-'
%left '*'

%%


/* Tails are ()*, opts are [] */
module
    : declaration_list
    ;
declaration_list
    : /* nothing */
    | declaration declaration_list
    ;
declaration
    : const_def
    | var_def
    | routine
    | program
    ;
const_def
    : T_const type id '=' const_expr const_def_tail ';'
    ;
const_def_tail
    : /* nothing */
    | ',' id '=' const_expr const_def_tail
    ;
var_def
    : type var_init var_def_tail ';'
    ;
var_def_tail
    : /* nothing */
    | ',' var_init var_def_tail
    ;
var_init
    : id var_init_opt
    | id var_init_tail_plus
    ;
var_init_opt
    : /* nothing */
    | '=' expr 
    ;
var_init_tail_plus
    : '[' const_expr ']' var_init_tail
    ;
var_init_tail
    : /* nothing */
    | '[' const_expr ']' var_init_tail
    ;
routine_header
    : routine_header_head id '(' routine_header_opt ')'
    ;
routine_header_head
    : T_proc
    | T_func type 
    ;
routine_header_opt
    : type formal routine_header_opt_tail
    ;
routine_header_opt_tail
    : /* nothing */
    | ',' type formal routine_header_opt_tail
    ;
formal
    : id
    | '&' id
    | id '[' const_expr_opt ']' formal_tail
    ;
const_expr_opt
    : /* nothing */
    | const_expr
    ;
formal_tail
    : /* nothing */
    | '[' const_expr ']' formal_tail
    ;




%%

void yyerror (const char * msg)
{
  fprintf(stderr, "Syntax Error: %s\n", msg);
  exit(1);
}

int main ()
{
  return yyparse();
}

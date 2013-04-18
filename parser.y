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


/* Tails are ()*, opts are [], choice is (|) */
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
    : T_const type T_id '=' const_expr const_def_tail ';'
    ;
const_def_tail
    : /* nothing */
    | ',' T_id '=' const_expr const_def_tail
    ;
var_def
    : type var_init var_def_tail ';'
    ;
var_def_tail
    : /* nothing */
    | ',' var_init var_def_tail
    ;
var_init
    : T_id var_init_opt
    | T_id var_init_tail_plus
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
    : routine_header_head T_id '(' routine_header_opt ')'
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
    : T_id
    | '&' T_id
    | T_id '[' const_expr_opt ']' formal_tail
    ;
const_expr_opt
    : /* nothing */
    | const_expr
    ;
formal_tail
    : /* nothing */
    | '[' const_expr ']' formal_tail
    ;
routine
    : routine_header routine_tail
    ;
routine_tail
    : ';'
    | block
    ;
program_header
    : T_prog T_id '(' ')'
    ;
program
    : program_header block
    ;
type
    : T_int
    | T_bool
    | T_char
    | T_real
    ;
const_expr
    : expr
    ;
expr
    : T_CONST_integer
    | T_CONST_real
    | T_CONST_char
    | T_CONST_string
    | T_true
    | T_false
    | '(' expr ')'
    | l_value
    | call
    | unop expr
    | expr binop expr
    ;
l_value
    : T_id l_value_tail
    ;
l_value_tail
    : /* Nothing */
    | '[' expr ']' l_value_tail
    ;
unop
    : '+'
    | '-'
    | '!'
    | T_not
    ;
binop 
    : '+'
    | '-'
    | '*'
    | '/'
    | '%'
    | T_mod
    | T_eq
    | T_diff
    | '<'
    | '>'
    | T_leq
    | T_greq
    | T_logand
    | T_and
    | T_logor
    | T_or
    ;
call 
    : T_id '(' call_opt ')'
    ;
call_opt
    : /* Nothing */
    | expr call_opt_tail 
    ;
call_opt_tail
    : /* Nothing */
    | ',' expr call_opt_tail
    ;
block
    : '{' block_tail '}'
    ;
block_tail
    : /* Nothing */
    | local_def block_tail
    | stmt block_tail
    ;
local_def
    : const_def
    | var_def
    ;
stmt
    : ';'
    | l_value assign expr ';'
    | l_value stmt_choice ';'
    | call ';'
    | T_if '(' expr ')' stmt stmt_opt_if
    | T_while '(' expr ')' stmt
    | T_for '(' T_id ',' range ')' stmt 
    | T_do stmt T_while '(' expr ')' ';'
    | T_switch '(' expr ')' '{' stmt_tail stmt_opt_switch '}'
    | T_break ';'
    | T_cont ';'
    | T_ret stmt_opt_ret ';'
    | write '(' stmt_opt_write ')' ';'
    | block
    ;
stmt_choice
    : T_pp
    | T_mm
    ;
stmt_opt_if
    : /* Nothing */
    | T_else stmt
    ;
stmt_tail
    : /* Nothing */
    | stmt_tail_tail_plus clause stmt_tail
    ;
stmt_tail_tail_plus
    : stmt_tail_tail stmt_tail_tail_plus
    | stmt_tail_tail
    ;
stmt_tail_tail
    : T_case const_expr ':' 
    ;
stmt_opt_switch
    : /* Nothing */
    | T_def':' clause
    ;
stmt_opt_ret
    : /* Nothing */
    | expr
    ;
stmt_opt_write
    : /* Nothing */
    | format stmt_opt_write_tail
    ;
stmt_opt_write_tail
    : /* Nothing */
    | ',' format stmt_opt_write_tail
    ;
assign
    : '='
    | T_inc
    | T_dec
    | T_mul
    | T_div
    | T_opmod
    ;
range
    : expr range_choice expr range_opt
    ;
range_choice
    : T_to 
    | T_downto
    ;
range_opt
    : /* Nothing */
    | T_step expr
    ;
clause
    : clause_tail clause_choice
    ;
clause_tail
    : /* Nothing */
    | stmt clause_tail
    ;
clause_choice
    : T_break ';'
    | T_next ';'
    ;
write
    : T_write
    | T_wrln
    | T_wrsp
    | T_wrspln
    ;
format
    : expr
    | T_form '(' expr ',' expr format_opt ')'
    ;
format_opt
    : /* Nothing */
    | ',' expr
    ;


%%

void yyerror (const char * msg)
{
  fprintf(stderr, "Syntax Error: %s\n", msg);
  lex_error(1, "wow");
  exit(1);
}

int main ()
{
  return yyparse();
}

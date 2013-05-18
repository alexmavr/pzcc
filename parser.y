%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol/symbol.h"

%}

%union { 
    int i;
    long double r;
    char c; 
    const char * n; // identifiers
    struct { const char * s; int len; } str;
    Type type;   
}

%token T_bool               "bool"
%token T_and                "and"
%token T_break              "break"
%token T_case               "case"
%token T_char               "char"
%token T_const              "const"
%token T_cont               "continue"
%token T_def                "default"
%token T_do                 "do"
%token T_downto             "DOWNTO"
%token T_false              "false"
%token T_else               "else"
%token T_for                "FOR"
%token T_form               "FORM"
%token T_func               "FUNC"
%token T_if                 "if"
%token T_int                "int"
%token T_mod                "mod"
%token T_next               "next"
%token T_not                "not"
%token T_or                 "or"
%token T_proc               "PROC"
%token T_prog               "PROGRAM"
%token T_real               "REAL"
%token T_ret                "return"
%token T_step               "STEP"
%token T_switch             "switch"
%token T_to                 "TO"
%token T_true               "true"
%token T_while              "while"
%token T_write              "WRITE"
%token T_wrln               "WRITELN"
%token T_wrsp               "WRITESP"
%token T_wrspln             "WRITESPLN"
%token T_id                 "identifier"
%token<i> T_CONST_integer  "integer constant"
%token<r> T_CONST_real     "real constant"
%token<c> T_CONST_char     "char constant"
%token<str> T_CONST_string   "string constant"
%token T_eq                 "=="
%token T_diff               "!="
%token T_greq               ">="
%token T_leq                "<="
%token T_logand             "&&"
%token T_logor              "||"
%token T_pp                 "++" 
%token T_mm                 "--"
%token T_inc                "+="
%token T_dec                "-="
%token T_mul                "*="
%token T_div                "/="
%token T_opmod              "%="
%token END 0                "end of file"

%type<type> expr


%expect 1

%left T_logor T_or
%left T_logand T_and 
%left T_eq T_diff
%left '<' '>' T_leq T_greq
%left '+' '-'
%left '*' '/' '%' T_mod

%left UN


%error-verbose

%initial-action
{
    initSymbolTable(256);
    openScope();
}

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
    : T_prog T_id '(' ')' {openScope();}
    ;
program
    : program_header block {closeScope();}
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
        {
            $$ = typeInteger;
        }
    | T_CONST_real 
        { 
            $$ = typeReal;
        }
    | T_CONST_char 
        { 
            $$ = typeChar;
        }
    | T_CONST_string
        { 
            /* should be freed when appropriate */
            $$ = typeArray($1.len, typeChar);
            printf("%s %d\n", $1.s, $$->size);
        }
    | T_true
        { 
            $$ = typeBoolean;
        }
    | T_false
        { 
            $$ = typeBoolean;
        }
    | '(' expr ')'
        {
            $$ = $2;
        }
    | l_value
        {
            // $$ = $1; need to specify types for identifiers
        }
    | call
    | expr binop1 expr %prec '*' 
        {
            // $$ = binop_type_check($1, $3);
        }
    | expr binop2 expr %prec '+' 
    | expr binop3 expr %prec '<' 
    | expr binop4 expr %prec T_eq 
    | expr binop5 expr %prec T_and 
    | expr binop6 expr %prec T_or 
    | unop expr %prec UN
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

binop1:'*' | '/' | '%' | T_mod ;
binop2: '+'| '-' ;
binop3: '<'| '>'| T_leq | T_greq ;
binop4: T_eq | T_diff ;
binop5: T_logand | T_and ;
binop6: T_logor | T_or;

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
    | T_while '(' expr ')' loop_stmt
    | T_for '(' T_id ',' range ')' loop_stmt 
    | T_do loop_stmt T_while '(' expr ')' ';'
    | T_switch '(' expr ')' '{' stmt_tail stmt_opt_switch '}'
    | T_ret stmt_opt_ret ';'
    | write '(' stmt_opt_write ')' ';'
    | block
    | error 
    ;

loop_stmt
    : stmt
    | T_break ';'
    | T_cont ';'
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
    | T_def ':' clause
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


int main ()
{
    yyparse();
    closeScope();
    printf("Parsing Complete\n");
    return 0;
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "symbol/symbol.h"

Type currentType; // global type indicator for variable initializations

struct const_val {
    union {
        int i;
        char c;
        long double r;
        const char * s;
        bool b;
    } value;
    Type type;
};

%}
%union { 
    /* Constants */
    int i;
    long double r;
    char c; 
    const char * s;

    Type type;   // expr's type
    const_val const_val;
}

%token T_bool               "bool"
%token<s> T_and             "and"
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
%token<s> T_mod             "mod"
%token T_next               "next"
%token T_not                "not"
%token<s> T_or              "or"
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
%token<s> T_id              "identifier"
%token<i> T_CONST_integer   "integer constant"
%token<r> T_CONST_real      "real constant"
%token<c> T_CONST_char      "char constant"
%token<s> T_CONST_string    "string constant"
%token<s> T_eq              "=="
%token<s> T_diff            "!="
%token<s> T_greq            ">="
%token<s> T_leq             "<="
%token<s> T_logand          "&&"
%token<s> T_logor           "||"
%token<s> T_pp              "++" 
%token<s> T_mm              "--"
%token<s> T_inc             "+="
%token<s> T_dec             "-="
%token<s> T_mul             "*="
%token<s> T_div             "/="
%token<s> T_opmod           "%="
%token END 0                "end of file"
%token<s> '*'
%token<s> '/'
%token<s> '%'
%token<s> '+'
%token<s> '-'
%token<s> '<'
%token<s> '>'

%type <type> expr
%type <type> l_value
%type <type> call
%type <type> type
%type <type> var_init_opt
%type <type> var_init_tail
%type <type> var_init_tail_plus

%type <const_val> const_expr

%type <s> binop1
%type <s> binop2
%type <s> binop3
%type <s> binop4
%type <s> binop5
%type <s> binop6

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
    : type { currentType = $1; } var_init var_def_tail ';' 
    ;
var_def_tail
    : /* nothing */
    | ',' var_init {} var_def_tail
        {
        }
    ;
var_init
    : T_id var_init_opt 
        { 
            if (($2 != NULL) && ($2 != currentType)){
                type_error("Illegal assigment to \"%s\"", $1);
            } else {
                newVariable($1, currentType);
            }
        }
    | T_id var_init_tail_plus
    ;
var_init_opt
    : /* nothing */ {$$ = NULL;}
    | '=' expr  { $$ = $2; }
    ;
var_init_tail_plus
    : '[' const_expr ']' var_init_tail { $$ = typeArray($2, $4); }
    ;
var_init_tail
    : /* nothing */ { $$ = currentType; }
    | '[' const_expr ']' var_init_tail { $$ = typeArray($2, $4); }
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
    : T_int     { $$ = typeInteger; }
    | T_bool    { $$ = typeBoolean; }
    | T_char    { $$ = typeChar; }
    | T_real    { $$ = typeReal; }
    ;

const_expr
    : T_CONST_integer 
        {
            $$.type = typeInteger;
            $$.value.i = $1;
        }
    | T_CONST_real 
        { 
            $$.type = typeReal;
            $$.value.r = $1;
        }
    | T_CONST_char 
        { 
            $$.type = typeChar;
            $$.value.c = $1;
        }
    | T_CONST_string
        { 
            $$.type = typeArray(strlen($1), typeChar);
            $$.value.s = $1;
        }
    | T_true
        { 
            $$.value.b = true;
            $$ = typeBoolean;
        }
    | T_false
        { 
            $$.value.b = false;
            $$ = typeBoolean;
        }
    | const_expr binop1 const_expr %prec '*' 
        {
            if ((($1.type == typeInteger) && ($3.type == typeReal)) \
            || (($1.type == typeReal) && ($3.type == typeInteger)) \
            || (($1.type == typeReal) && ($3.type == typeReal))) {
                    $$.type = typeReal;
                    $$.value = (long double) $3.value * (long double) $1.value;
            } else if (($1.type == typeInteger) && ($3.type == typeInteger)) {
                    $$.type = typeInteger;
                    $$.value = $1.value * $3.value;
            } else {
                    type_error("Type mismatch on \"%s\" operator", $2);
            }
        }
    | const_expr binop2 const_expr %prec '+' 
    | const_expr binop3 const_expr %prec '<' 
    | const_expr binop4 const_expr %prec T_eq 
    | const_expr binop5 const_expr %prec T_and 
    | const_expr binop6 const_expr %prec T_or 
    ;
expr
    :  const_expr { $$ = $1.type; }
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
            if ($1 == $3) {
                // IR
                $$ = $1;
            } else if (($1 == typeReal) && ($3 == typeInteger)) {
                // Promote and IR
                $$ = typeReal;
            } else if (($1 == typeInteger) && ($3 == typeReal)) {
                // Promote and IR
                $$ = typeReal;
            } else {
                type_error("Type mismatch on \"%s\" operator", $2 );
            }
        }
    | expr binop2 expr %prec '+' 
            {
                if ($1 != $3) 
                    type_error("Type mismatch on \"%s\" operator", $2 );
            }
    | expr binop3 expr %prec '<' 
            {
                if ($1 != $3) 
                    type_error("Type mismatch on \"%s\" operator", $2 );
            }
    | expr binop4 expr %prec T_eq 
            {
                if ($1 != $3) 
                    type_error("Type mismatch on \"%s\" operator", $2 );
            }
    | expr binop5 expr %prec T_and 
            {
                if ($1 != $3) 
                    type_error("Type mismatch on \"%s\" operator", $2 );
            }
    | expr binop6 expr %prec T_or 
            {
                if ($1 != $3) 
                    type_error("Type mismatch on \"%s\" operator", $2 );
            }
    | unop expr %prec UN
        {
            $$ = $2;
        }
    ;
l_value
    : T_id l_value_tail {   }
        {
            // Lookup T_id on symbol table
        }
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

binop1: '*'| '/' | '%' | T_mod ;
binop2: '+'| '-' ;
binop3: '<'| '>'| T_leq | T_greq ;
binop4: T_eq | T_diff;
binop5: T_logand | T_and ;
binop6: T_logor | T_or;

call 
    : T_id '(' call_opt ')'
        {
            // return the function's call type
        }
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

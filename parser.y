%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "comp_lib.h"
#include "symbol/symbol.h"
#include "symbol/general.h"

extern int yylex();

Type currentType; // global type indicator for variable initializations

%}

%code requires {

    typedef union {
            RepInteger i;
            RepBoolean b;
            RepChar c;
            RepReal r;
            RepString s;
    } val_union;

    struct ast_node {
        val_union value;
        Type type;
    };
}

%union { 
    /* Constants */
    int i;
    long double r;
    char c; 
    const char * s;

    struct ast_node node;
}

%token T_bool               "bool"
%token <s> T_and            "and"
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
%token <s> T_mod            "mod"
%token T_next               "next"
%token T_not                "not"
%token <s> T_or             "or"
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
%token END 0                "end of file"
%token <s> T_id             "identifier"
%token <i> T_CONST_integer  "integer constant"
%token <r> T_CONST_real     "real constant"
%token <c> T_CONST_char     "char constant"
%token <s> T_CONST_string   "string constant"
%token <s> T_eq             "=="
%token <s> T_diff           "!="
%token <s> T_greq           ">="
%token <s> T_leq            "<="
%token <s> T_logand         "&&"
%token <s> T_logor          "||"
%token <s> T_pp             "++" 
%token <s> T_mm             "--"
%token <s> T_inc            "+="
%token <s> T_dec            "-="
%token <s> T_mul            "*="
%token <s> T_div            "/="
%token <s> T_opmod          "%="
%token <s> '*'
%token <s> '/'
%token <s> '%'
%token <s> '+'
%token <s> '-'
%token <s> '<'
%token <s> '>'

%type <node> expr
%type <node> l_value
%type <node> call
%type <node> type
%type <node> var_init_opt
%type <node> var_init_tail
%type <node> var_init_tail_plus
%type <node> const_expr
%type <node> const_unit

%type <i> l_value_tail

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
    : T_const type {currentType=$2.type;} T_id '=' const_expr const_def_tail ';'
        {
            SymbolEntry * con = newConstant($4, currentType);

            /* Constants can only be promoted from int to real */
            if ((currentType == typeReal) && ($6.type == typeInteger)) {
                con->u.eConstant.value.vReal = $6.value.r = (RepReal)  $6.value.i;
            } else if (currentType != $6.type) {
                type_error("Cannot assign %s to %s at variable \"%s\"", \
                            verbose_type(currentType), verbose_type($6.type), $4);
            }
            else if (currentType == typeInteger)
                con->u.eConstant.value.vInteger = $6.value.i;
            else if (currentType == typeReal)
                con->u.eConstant.value.vReal = $6.value.r;
            else if (currentType == typeBoolean)
                con->u.eConstant.value.vBoolean = $6.value.b;
            else if (currentType == typeChar)
                con->u.eConstant.value.vChar = $6.value.c;
            else
                type_error("Unexpected type %s for constant declaration", \
                                                                 currentType);
        }
    ;
const_def_tail
    : /* nothing */
    | ',' T_id '=' const_expr const_def_tail
        {
            SymbolEntry * con = newConstant($2, currentType);

            /* Constants can only be promoted from int to real */
            if ((currentType == typeReal) && ($4.type == typeInteger)) {
                con->u.eConstant.value.vReal = $4.value.r = (RepReal) $4.value.i;
            } else if (currentType != $4.type) {
                type_error("Cannot assign %s to %s at variable \"%s\"", \
                            verbose_type(currentType), verbose_type($4.type), $2);
            }
            else if (currentType == typeInteger)
                con->u.eConstant.value.vInteger = $4.value.i;
            else if (currentType == typeReal)
                con->u.eConstant.value.vReal = $4.value.r;
            else if (currentType == typeBoolean)
                con->u.eConstant.value.vBoolean = $4.value.b;
            else if (currentType == typeChar)
                con->u.eConstant.value.vChar = $4.value.c;
            else
                type_error("Unexpected type %s for constant declaration", \
                                                                 currentType);
        }
    ;
var_def
    : type { currentType = $1.type; } var_init var_def_tail ';' 
    ;
var_def_tail
    : /* nothing */
    | ',' var_init var_def_tail
    ;
var_init
    : T_id var_init_opt 
        { 
            if ($2.type != NULL) {
                /* (IR) TODO: Real Promoting - Char/Int Conversions */
                if (!compat_types(currentType, $2.type))
                    type_error("Illegal assignment from %s to %s at \"%s\"", \
                        verbose_type($2.type), verbose_type(currentType), $1);  
            }
            newVariable($1, currentType);
        }
    | T_id var_init_tail_plus
        {
            /* $2.type is of the correct array type */
            newVariable($1, $2.type);
        }
    ;
var_init_opt
    : /* nothing */ {$$.type = NULL;}
    | '=' expr  { $$.type = $2.type; }
    ;
var_init_tail_plus
    : '[' const_expr ']' { array_index_check(&($2)); } var_init_tail 
        {
            $$.type = typeArray($2.value.i, $5.type);
        }
    ;
var_init_tail
    : /* nothing */  { $$.type = currentType; }
    | '[' const_expr ']' { array_index_check(&($2)); } var_init_tail
        {
            $$.type = typeArray($2.value.i, $5.type);
        }
    ;
routine
    : routine_header routine_tail
    ;
routine_tail
    : ';'
    | block
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
        {
            array_index_check(&($1));
        }
    ;
formal_tail
    : /* nothing */
    | '[' const_expr ']' formal_tail
        {
            array_index_check(&($2));
        }
    ;
program_header
    : T_prog T_id '(' ')' {openScope();}
    ;
program
    : program_header block {closeScope();}
    ;
type
    : T_int     { $$.type = typeInteger; }
    | T_bool    { $$.type = typeBoolean; }
    | T_char    { $$.type = typeChar; }
    | T_real    { $$.type = typeReal; }
    ;

const_unit
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
            $$.type = typeBoolean;
        }
    | T_false
        { 
            $$.value.b = false;
            $$.type = typeBoolean;
        }

const_expr
        : const_unit { $$ = $1; }
        | T_id       
            {   /* constant variables only */ 
                SymbolEntry * id = lookupEntry($1, LOOKUP_ALL_SCOPES, true);

                if (id->entryType != ENTRY_CONSTANT) {
                    type_error("Non-constant identifier \"%s\" found in constant expression", $1);
                    /* Error Recovery */
                    if (id->entryType == ENTRY_VARIABLE)
                        $$.type = id->u.eVariable.type; 
                    else if (id->entryType == ENTRY_FUNCTION)
                        $$.type = id->u.eFunction.resultType; 
                    else if (id->entryType == ENTRY_TEMPORARY)
                        $$.type = id->u.eTemporary.type; 
                    else
                        exit(1);
                }
                else {
                    $$.type = id->u.eConstant.type;
                    memcpy(&($$.value), &(id->u.eConstant.value), sizeof(val_union));
                }
            }
        | const_expr binop1 const_expr %prec '*' 
        {
            eval_const_binop(&($1), &($3), $2, &($$));
        }
    | const_expr binop2 const_expr %prec '+' 
        {
            eval_const_binop(&($1), &($3), $2, &($$));
        }
    ;
expr
    :  const_unit { $$.type = $1.type; }
    | '(' expr ')'
        {
            $$ = $2;
        }
    | l_value
        {
             $$ = $1; 
        }
    | call
    | expr binop1 expr %prec '*' 
        {
            
        }
    | expr binop2 expr %prec '+' 
            {
            }
    | expr binop3 expr %prec '<' 
            {
            }
    | expr binop4 expr %prec T_eq 
            {
            }
    | expr binop5 expr %prec T_and 
            {
            }
    | expr binop6 expr %prec T_or 
            {
            }
    | unop expr %prec UN
        {
            $$ = $2;
        }
    ;
l_value
    : T_id l_value_tail
        {
            SymbolEntry * id = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
            if (id != NULL) {
                switch (id->entryType) {
                    case ENTRY_VARIABLE:
                        {
                            /* Return the appropriate type if it's an array 
                            *  $2 is the number of dimensions following the id */
                            int dims = array_dimensions(id->u.eVariable.type);
                            if ($2 > dims)
                                type_error("\"%s\" has less dimensions than specified", \
                                                                                 id->id);
                            else if ($2 < dims)
                                /* the type is that of the (dims - $2) dimension */
                                $$.type = n_dimension_type(id->u.eVariable.type, (dims-$2));
                            else
                                $$.type = id->u.eVariable.type;
                            break;
                        }
                    case ENTRY_CONSTANT:
                        if ($2)
                            type_error("Constant \"%s\" is not an Array",id->id);
                        $$.type = id->u.eConstant.type;
                        break;
                    default: ;
                }
                $$.value.s = id->id;
            }
        }
    ;
l_value_tail
    : /* Nothing */ { $$ = 0; }
    | '[' expr ']' l_value_tail 
        {
             if (($2.type != typeInteger) && ($2.type != typeChar))
                type_error("Array index cannot be %s", verbose_type($2.type));
             $$ = 1 + $4;
        }
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
        {
            if (!compat_types($1.type, $3.type)) {
                type_error("Illegal assignment from %s to %s at \"%s\"", \
                        verbose_type($3.type), verbose_type($1.type), $1.value.s);
            }
        }
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
    | error ';'
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

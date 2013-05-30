%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "comp_lib.h"
#include "symbol/symbol.h"
#include "symbol/general.h"

extern int yylex();

Type currentType = NULL;			// global type indicator for variable initializations
Type currentFunctionType = NULL;	// global type for the current function
Type currentCall = NULL;	// global type for the current function
SymbolEntry * currentFun = NULL;			// global function indicator for parameter declaration
SymbolEntry * currentParam = NULL;		 
bool functionHasReturn = false;

unsigned long long loop_counter = 0;

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
%type <node> stmt_opt_ret
%type <node> l_value
%type <node> call
%type <node> type
%type <node> var_init_opt
%type <node> var_init_tail
%type <node> var_init_tail_plus
%type <node> const_expr
%type <node> const_unit
%type <node> formal
%type <node> formal_tail
%type <node> routine_header_head
%type <node> const_expr_opt

%type <i> l_value_tail
%type <i> format_opt

%type <s> binop1
%type <s> binop2
%type <s> binop3
%type <s> binop4
%type <s> binop5
%type <s> binop6
%type <s> unop
%type <s> stmt_choice

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
            if (con == NULL)
                YYERROR;

            if ((currentType == typeReal) && ($6.type == typeInteger)) 
                con->u.eConstant.value.vReal = (RepReal) $6.value.i;
            else if ((currentType == typeReal) && ($6.type == typeChar)) 
                con->u.eConstant.value.vReal = (RepReal) $6.value.c;
            else if ((currentType == typeInteger) && ($6.type == typeChar)) 
                con->u.eConstant.value.vInteger = (RepInteger) $6.value.c;
            else if ((currentType == typeChar) && ($6.type == typeInteger)) 
                con->u.eConstant.value.vChar = int_to_char($6.value.i);
            else if (currentType != $6.type) 
                type_error("Illegal assignment from %s to %s at variable \"%s\"", \
                        verbose_type($6.type), verbose_type(currentType), $4);
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
            if (con == NULL)
                YYERROR;

            if ((currentType == typeReal) && ($4.type == typeInteger)) 
                con->u.eConstant.value.vReal = (RepReal) $4.value.i;
            else if ((currentType == typeReal) && ($4.type == typeChar)) 
                con->u.eConstant.value.vReal = (RepReal) $4.value.c;
            else if ((currentType == typeInteger) && ($4.type == typeChar)) 
                con->u.eConstant.value.vInteger = (RepInteger) $4.value.c;
            else if ((currentType == typeChar) && ($4.type == typeInteger)) 
                con->u.eConstant.value.vChar = (RepChar) $4.value.i;

            else if (currentType != $4.type)
                type_error("Illegal assignment from %s to %s at variable \"%s\"", \
                        verbose_type($4.type), verbose_type(currentType), $2);
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
        {
            closeScope();
            currentFunctionType = NULL;
            functionHasReturn = false;
        }
    ;
routine_tail
    : ';' { forwardFunction(currentFun); }
    | block
        {
            if ((currentFunctionType != typeVoid) && (!functionHasReturn))
                type_error("function without a return statement");
        }
    ;
routine_header
    : routine_header_head T_id '(' {currentFun = newFunction($2); openScope();} routine_header_opt ')' {endFunctionHeader(currentFun, $1.type);}
    ;
routine_header_head
    : T_proc       { currentFunctionType = $$.type = typeVoid; }
    | T_func type  { currentFunctionType = $$.type = $2.type; }
    ;
routine_header_opt
    : type formal routine_header_opt_tail
        {
            if (currentFun == NULL)
                YYERROR;

            if ($2.type == NULL)
                newParameter($2.value.s, $1.type, PASS_BY_REFERENCE, currentFun);
            else if ($2.type->kind >= TYPE_ARRAY) {
                Type current = $2.type;
                while (current->refType != typeVoid) 
                    current = current->refType;
                current->refType = $1.type;
                newParameter($2.value.s, $2.type, PASS_BY_REFERENCE, currentFun);   
            } else 
                newParameter($2.value.s, $1.type, PASS_BY_VALUE, currentFun);
        }
    | /* nothing */
    ;
routine_header_opt_tail
    : /* nothing */ 
    | ',' type formal routine_header_opt_tail
        {
            if (currentFun == NULL)
                YYERROR;

            if ($3.type == NULL)
                newParameter($3.value.s, $2.type, PASS_BY_REFERENCE, currentFun);
            else if ($3.type->kind >= TYPE_ARRAY) {
                Type current = $3.type;
                while (current->refType != typeVoid)
                    current = current->refType;
                current->refType = $2.type;
                newParameter($3.value.s, $3.type, PASS_BY_REFERENCE, currentFun);   
            } else
                newParameter($3.value.s, $2.type, PASS_BY_VALUE, currentFun);
        }
    ;
formal
    : T_id 
        {
            $$.value.s = $1;
            $$.type = typeVoid; // Pass by value
        }
    | '&' T_id
        {
            $$.value.s = $2;
            $$.type = NULL;  // Pass by reference
        }
    | T_id '[' const_expr_opt ']' formal_tail
        {
            $$.value.s = $1;
            if (!$3.value.i)
                $$.type = typeIArray($5.type);
            else
                $$.type = typeArray($3.value.i, $5.type); 
        }
    ;
const_expr_opt
    : /* nothing */ { $$.value.i = 0; }
    | const_expr 
        {
            array_index_check(&($1));
            $$ = $1;
        }
    ;
formal_tail
    : /* nothing */ { $$.type = typeVoid;} 
    | '[' const_expr ']' formal_tail
        {
            if (array_index_check(&($2)))
                $$.type = typeArray($2.value.i, $4.type);
            else
                $$.type = typeVoid; // error recovery 
        }
    ;
program_header
    : T_prog { currentFunctionType = typeVoid; } T_id '(' ')'
    ;
program
    : program_header block
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
	;
const_expr
        : const_unit { $$ = $1; }
        | T_id       
            {   /* constant variables only */ 
                SymbolEntry * id = lookupEntry($1, LOOKUP_ALL_SCOPES, true);

                if (id == NULL)
                    YYERROR;

                if (id->entryType != ENTRY_CONSTANT) {
                    type_error("Non-constant identifier \"%s\" found in constant expression", $1);
                    YYERROR;
                } else {
                    $$.type = id->u.eConstant.type;
                    memcpy(&($$.value), &(id->u.eConstant.value), sizeof(val_union));
                }
            }
        | '(' const_expr ')' { $$ = $2; }
        | const_expr binop1 const_expr %prec '*' 
            {
                eval_const_binop(&($1), &($3), $2, &($$));
            }
        | const_expr binop2 const_expr %prec '+' 
            {
                eval_const_binop(&($1), &($3), $2, &($$));
            }
        | const_expr binop3 const_expr %prec '<' 
            {
                eval_const_binop(&($1), &($3), $2, &($$));
            }
        | const_expr binop4 const_expr %prec T_eq
            {
                eval_const_binop(&($1), &($3), $2, &($$));
            }
        | const_expr binop5 const_expr %prec T_and
            {
                eval_const_binop(&($1), &($3), $2, &($$));
            }
        | const_expr binop6 const_expr %prec T_or
            {
                eval_const_binop(&($1), &($3), $2, &($$));
            }
        | unop const_expr %prec UN
            {
                eval_const_unop(&($2), $1, &($$));
            }

    ;
expr
    :  const_unit { $$.type = $1.type; }
    | '(' expr ')'
        {
            $$ = $2;
        }
    | '(' error ')' { $$.type = typeVoid; }
    | l_value
        {
             $$ = $1; 
        }
    | call { $$ = $1; }
    | expr binop1 expr %prec '*' 
        {
            binop_IR(&($1), &($3), $2, &($$));
        }
    | expr binop2 expr %prec '+' 
        {
            binop_IR(&($1), &($3), $2, &($$));
        }
    | expr binop3 expr %prec '<' 
        {
            binop_IR(&($1), &($3), $2, &($$));
        }
    | expr binop4 expr %prec T_eq 
        {
            binop_IR(&($1), &($3), $2, &($$));
        }
    | expr binop5 expr %prec T_and 
        {
            binop_IR(&($1), &($3), $2, &($$));
        }
    | expr binop6 expr %prec T_or 
        {
            binop_IR(&($1), &($3), $2, &($$));
        }
    | unop expr %prec UN
        {
            unop_IR(&($2), $1, &($$));
        }
    ;
l_value
    : T_id l_value_tail
        {
            SymbolEntry * id = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
            int dims;

            if (id == NULL) 
                YYERROR;

            switch (id->entryType) {
                case ENTRY_VARIABLE:
                    {
                        /* Return the appropriate type if it's an array 
                        *  $2 is the number of dimensions following the id */
                        dims = array_dimensions(id->u.eVariable.type);
                        if ($2 > dims)
                            type_error("\"%s\" has less dimensions than specified", id->id);
                        else 
                            $$.type = n_dimension_type(id->u.eVariable.type, $2);
                        break;
                    }
                case ENTRY_PARAMETER:
                    {
                        dims = array_dimensions(id->u.eParameter.type);
                        if ($2 > dims)
                            type_error("\"%s\" has less dimensions than specified", id->id);
                        else 
                            $$.type = n_dimension_type(id->u.eParameter.type, $2);
                        break;
                    }
                case ENTRY_CONSTANT:
                    if ($2)
                        type_error("Constant \"%s\" cannot an Array",id->id);
                    $$.type = id->u.eConstant.type;
                    break;
                    
                default: ;
            }
            $$.value.s = id->id;
        }
    ;
l_value_tail
    : /* Nothing */ { $$ = 0; }
    | '[' expr ']' l_value_tail 
        {
                
            if (!compat_types(typeInteger, $2.type))
               type_error("Array index cannot be %s", verbose_type($2.type));
            $$ = 1 + $4;
        }
    ;
unop
    : '+'  { $$ = "+"; }
    | '-'  { $$ = "-"; }
    | '!'  { $$ = "!"; }
    | T_not { $$ = "not"; }
    ;

binop1: '*'| '/' | '%' | T_mod ;
binop2: '+'| '-' ;
binop3: '<'| '>'| T_leq | T_greq ;
binop4: T_eq | T_diff;
binop5: T_logand | T_and ;
binop6: T_logor | T_or;

call 
    : T_id '(' 
        {
            SymbolEntry * fun = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
            if (fun == NULL)
                YYERROR;

            currentCall = fun->u.eFunction.resultType;
            currentParam = fun->u.eFunction.firstArgument;
        } call_opt ')' { $$.type = currentCall; }
    ;
call_opt
    : /* Nothing */
    | expr call_opt_tail  
        {
            if (currentParam == NULL) {
                type_error("Invalid number of parameters specified");
                YYERROR;
            } else if (!compat_types(currentParam->u.eParameter.type, $1.type))
                type_error("Illegal parameter assignment from %s to %s", verbose_type($1.type), \
                    verbose_type(currentParam->u.eParameter.type));
            currentParam = currentParam->u.eParameter.next;
        }
    ;
call_opt_tail
    : /* Nothing */
    | ',' expr call_opt_tail
        {
            if (currentParam == NULL) {
                type_error("Invalid number of parameters specified");
                YYERROR;
            }
            if (!compat_types(currentParam->u.eParameter.type, $2.type))
                type_error("Illegal parameter assignment from %s to %s", verbose_type($2.type), \
                    verbose_type(currentParam->u.eParameter.type));
            currentParam = currentParam->u.eParameter.next;
        }
    ;
block
    : '{' {openScope();} block_tail '}' {closeScope();}
    ;
block_tail
    : /* Nothing */
    | local_def block_tail
    | stmt block_tail
    | error
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
        {
            if (!compat_types(typeInteger, $1.type)) {
                type_error("Type mismatch for \"%s\" operator", $2);
            }
        }
    | call ';'
    | T_if '(' expr ')' stmt stmt_opt_if 
        {
            if (!compat_types(typeBoolean, $3.type))
                type_error("if: condition is %s instead of Boolean", \
                            verbose_type($3.type));
           
        }
    | T_for { loop_counter++; } '(' T_id ',' range ')' loop_stmt { loop_counter--; }
        {
                SymbolEntry * i = lookupEntry($4, LOOKUP_ALL_SCOPES, true);
                if (i == NULL)
                    YYERROR;
                
                if (i->entryType != ENTRY_VARIABLE)
                    type_error("FOR: \"%s\" is not a variable", i->id);
                else if (!compat_types(typeInteger, i->u.eVariable.type))
                    type_error("FOR: control variable \"%s\" is not an Integer", i->id);
        }
    | T_while { loop_counter++; } '(' expr ')' loop_stmt { loop_counter--; }
        {
            if (!compat_types(typeBoolean, $4.type))
                type_error("while: condition is %s instead of Boolean", \
                            verbose_type($4.type));
        }
    | T_do { loop_counter++; } loop_stmt T_while '(' expr ')' ';' { loop_counter--; }
        {
            if (!compat_types(typeBoolean, $6.type))
                type_error("do..while: condition is %s instead of Boolean", \
                            verbose_type($6.type));
        }
    | T_switch '(' expr ')' '{' {openScope();} stmt_tail stmt_opt_switch '}' {closeScope();}
        {
            if (!compat_types(typeInteger, $3.type))
                type_error("switch: expression is %s instead of Integer", \
                            verbose_type($3.type));
        }

    | T_ret stmt_opt_ret ';'
		{
            if (currentFunctionType == NULL)
                YYERROR;
			else if (!compat_types(currentFunctionType, $2.type))
				type_error("return: incompatible return type: %s instead of %s", \
                verbose_type($2.type), verbose_type(currentFunctionType));

            functionHasReturn = true;
		}
    | write '(' stmt_opt_write ')' ';' 
    | block
    | error ';'
    ;
loop_stmt
    : stmt
    | T_break ';'  
        {
            if (loop_counter == 0) {
                type_error("Illegal break statement");
            }
        }
    | T_cont ';'
        {
            if (loop_counter == 0) {
                type_error("Illegal continue statement");
            }
        }
    ;
stmt_choice
    : T_pp { $$ = "++"; }
    | T_mm { $$ = "--"; }
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
        {
            if (!compat_types(typeInteger, $2.type))
                type_error("switch case is %s instead of Integer", \
                        verbose_type($2.type));
        }
    ;
stmt_opt_switch
    : /* Nothing */
    | T_def ':' clause
    ;
stmt_opt_ret
    : /* Nothing */ { $$.type = typeVoid; }
    | expr { $$.type = $1.type; }
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
        {
            if (!compat_types(typeInteger, $1.type))
                type_error("FOR: range start is %s instead of Integer", \
                                        verbose_type($1.type));
            if (!compat_types(typeInteger, $3.type))
                type_error("FOR: range end is %s instead of Integer", \
                                        verbose_type($3.type));
        }
    ;
range_choice
    : T_to 
    | T_downto
    ;
range_opt
    : /* Nothing */
    | T_step expr
        {
            if (!compat_types(typeInteger, $2.type))
                type_error("FOR: STEP is %s instead of Integer", \
                                        verbose_type($2.type));
        }
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
        {
            if (($1.type->kind >= TYPE_ARRAY) && ( $1.type->refType != typeChar))
                type_error("Cannot display an Array of type other than Char");
        }
    | T_form '(' expr ',' expr format_opt ')'
        {
            if (!compat_types(typeInteger, $5.type))
                type_error("FORM: second argument is %s instead of Integer", \
                                        verbose_type($5.type));
            if (($6 == 1) && (!compat_types(typeReal, $3.type)))
                type_error("FORM: first argument is not Real and precision is specified", \
                                        verbose_type($5.type));
        }
    ;
format_opt
    : /* Nothing */ { $$ = 0; }
    | ',' expr  
        {
            if (!compat_types(typeInteger, $2.type))
                type_error("FORM: third argument is %s instead of Integer", \
                                        verbose_type($2.type));
            $$ = 1;
        }
    ;

%%

int main ()
{
    yyparse();
    closeScope();
    printf("Parsing Complete\n");
    return 0;
}

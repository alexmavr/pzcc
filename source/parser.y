%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <llvm-c/Core.h>
#include <llvm-c/Analysis.h>
#include "semantic.h"
#include "symbol.h"
#include "general.h"
#include "error.h"
#include "ir.h"

extern int yylex();
extern LLVMBuilderRef builder;
extern LLVMModuleRef module;

Type currentType = NULL;				// Type indicator for var_init
LLVMTypeRef currentLLVMType = NULL;	    // LLVMType indicator var_init
Type currentFunctionType = NULL;		// type indicator for function return
SymbolEntry *currentFun = NULL;			// global function indicator for parameter declaration
int currentWrite = 0;                   // indicator for WRITE mode
bool function_has_ret = false;          // flag for marking whether a routine body returns
bool array_last = false;                // flag for the last dimension of an array variable
bool global_scope = true;               // flag marking the scope for initializations
bool switch_default_case = false;       // true if the default case of switch is being parsed

%}

%code requires {

#ifndef __PARSER_H_DEFS__
#define __PARSER_H_DEFS__

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
        LLVMValueRef Valref;
		bool is_lvalue;
        struct list_node * v_list; // general-purpose ValueRef list
	};
    
    struct for_node {
        LLVMValueRef from;
        LLVMValueRef to;
        LLVMValueRef step;
        char direction;         // '+' if TO, '-' if DOWNTO
    };

#endif /* __PARSER_H_DEFS__ */

}

%union {
	/* Constants */
	int i;
	double r;
	char c;
	const char *s;

	struct ast_node node;
	struct for_node for_node;
}

%token T_bool				"bool"
%token <s> T_and			"and"
%token T_break				"break"
%token T_case				"case"
%token T_char				"char"
%token T_const				"const"
%token T_cont				"continue"
%token T_def				"default"
%token T_do					"do"
%token T_downto				"DOWNTO"
%token T_false				"false"
%token T_else				"else"
%token T_for				"FOR"
%token T_form				"FORM"
%token T_func				"FUNC"
%token T_if					"if"
%token T_int				"int"
%token <s> T_mod			"mod"
%token T_next				"next"
%token T_not				"not"
%token <s> T_or				"or"
%token T_proc				"PROC"
%token T_prog				"PROGRAM"
%token T_real				"REAL"
%token T_ret				"return"
%token T_step				"STEP"
%token T_switch				"switch"
%token T_to					"TO"
%token T_true				"true"
%token T_while				"while"
%token T_write				"WRITE"
%token T_wrln				"WRITELN"
%token T_wrsp				"WRITESP"
%token T_wrspln				"WRITESPLN"
%token END 0				"end of file"
%token <s> T_id				"identifier"
%token <i> T_CONST_integer	"integer constant"
%token <r> T_CONST_real		"real constant"
%token <c> T_CONST_char		"char constant"
%token <s> T_CONST_string	"string constant"
%token <s> T_eq				"=="
%token <s> T_diff			"!="
%token <s> T_greq			">="
%token <s> T_leq			"<="
%token <s> T_logand			"&&"
%token <s> T_logor			"||"
%token <s> T_pp				"++"
%token <s> T_mm				"--"
%token <s> T_inc			"+="
%token <s> T_dec			"-="
%token <s> T_mul			"*="
%token <s> T_div			"/="
%token <s> T_opmod			"%="
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
%type <node> l_value_tail
%type <node> range_choice
%type <node> range_opt
%type <node> format_opt

%type <for_node> range


%type <s> assign
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
//	openScope(); // opening at main() now
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
	: T_const type { currentType=$2.type; } T_id '=' const_expr const_def_tail ';'
		{
			SymbolEntry *con = newConstant($4, currentType);
			if (con == NULL)
				YYERROR;

            /* cast the evaluated const_expr and create the resulting ValueRef*/
            LLVMValueRef res = NULL;
			if ((currentType == typeReal) && ($6.type == typeInteger)) {
				con->u.eConstant.value.vReal = (RepReal) $6.value.i;
                res = LLVMConstReal(LLVMDoubleType(), con->u.eConstant.value.vReal);
			} else if ((currentType == typeReal) && ($6.type == typeChar)) {
				con->u.eConstant.value.vReal = (RepReal) $6.value.c;
                res = LLVMConstReal(LLVMDoubleType(), con->u.eConstant.value.vReal);
			} else if ((currentType == typeInteger) && ($6.type == typeChar)) {
				con->u.eConstant.value.vInteger = (RepInteger) $6.value.c;
                res = LLVMConstInt(LLVMInt32Type(), \
                            con->u.eConstant.value.vInteger, false);
			} else if ((currentType == typeChar) && ($6.type == typeInteger)) {
				con->u.eConstant.value.vChar = int_to_char($6.value.i);
                res = LLVMConstInt(LLVMInt8Type(), \
                            con->u.eConstant.value.vChar, false);
			} else if (currentType != $6.type) {
				my_error(ERR_LV_ERR, "Illegal assignment from %s to %s on \"%s\"", \
						verbose_type($6.type), verbose_type(currentType), $4);
                YYERROR;
			} else if (currentType == typeInteger) {
				con->u.eConstant.value.vInteger = $6.value.i;
                res = LLVMConstInt(LLVMInt32Type(), \
                        con->u.eConstant.value.vInteger, false);
			} else if (currentType == typeReal) {
				con->u.eConstant.value.vReal = $6.value.r;
                res = LLVMConstReal(LLVMDoubleType(), con->u.eConstant.value.vReal);
			} else if (currentType == typeBoolean) {
				con->u.eConstant.value.vBoolean = $6.value.b;
                res = LLVMConstInt(LLVMInt1Type(), \
                        con->u.eConstant.value.vBoolean, false);
			} else if (currentType == typeChar) {
				con->u.eConstant.value.vChar = $6.value.c;
                res = LLVMConstInt(LLVMInt8Type(), \
                        con->u.eConstant.value.vChar, false);
			} else {
				my_error(ERR_LV_ERR, "Unexpected type %s for constant declaration", \
																 currentType);
                YYERROR;
            }

            if (global_scope) {
                /* Set the const as global */
                con->Valref = LLVMAddGlobal(module, type_to_llvm(currentType), $4);
                LLVMSetInitializer(con->Valref, res);
                LLVMSetGlobalConstant(con->Valref, true);
            } else {
                /* Allocate the constant and store the const value*/
                con->Valref = LLVMBuildAlloca(builder, type_to_llvm(currentType), $4);
                LLVMBuildStore(builder, res, con->Valref);
            }
		}
	;
const_def_tail
	: /* nothing */
	| ',' T_id '=' const_expr const_def_tail
		{
			SymbolEntry *con = newConstant($2, currentType);
			if (con == NULL)
				YYERROR;

            /* cast the evaluated const_expr and create the resulting ValueRef*/
            LLVMValueRef res = NULL;
			if ((currentType == typeReal) && ($4.type == typeInteger)) {
				con->u.eConstant.value.vReal = (RepReal) $4.value.i;
                res = LLVMConstReal(LLVMDoubleType(), con->u.eConstant.value.vReal);
			} else if ((currentType == typeReal) && ($4.type == typeChar)) {
				con->u.eConstant.value.vReal = (RepReal) $4.value.c;
                res = LLVMConstReal(LLVMDoubleType(), con->u.eConstant.value.vReal);
			} else if ((currentType == typeInteger) && ($4.type == typeChar)) {
				con->u.eConstant.value.vInteger = (RepInteger) $4.value.c;
                res = LLVMConstInt(LLVMInt32Type(), \
                            con->u.eConstant.value.vInteger, false);
			} else if ((currentType == typeChar) && ($4.type == typeInteger)) {
				con->u.eConstant.value.vChar = int_to_char($4.value.i);
                res = LLVMConstInt(LLVMInt8Type(), \
                            con->u.eConstant.value.vChar, false);
			} else if (currentType != $4.type) {
				my_error(ERR_LV_ERR, "Illegal assignment from %s to %s on \"%s\"", \
						verbose_type($4.type), verbose_type(currentType), $4);
                YYERROR;
			} else if (currentType == typeInteger) {
				con->u.eConstant.value.vInteger = $4.value.i;
                res = LLVMConstInt(LLVMInt32Type(), \
                        con->u.eConstant.value.vInteger, false);
			} else if (currentType == typeReal) {
				con->u.eConstant.value.vReal = $4.value.r;
                res = LLVMConstReal(LLVMDoubleType(), con->u.eConstant.value.vReal);
			} else if (currentType == typeBoolean) {
				con->u.eConstant.value.vBoolean = $4.value.b;
                res = LLVMConstInt(LLVMInt1Type(), \
                        con->u.eConstant.value.vBoolean, false);
			} else if (currentType == typeChar) {
				con->u.eConstant.value.vChar = $4.value.c;
                res = LLVMConstInt(LLVMInt8Type(), \
                        con->u.eConstant.value.vChar, false);
			} else {
				my_error(ERR_LV_ERR, "Unexpected type %s for constant declaration", \
																 currentType);
                YYERROR;
            }
            if (global_scope) {
                /* Set the const as global */
                con->Valref = LLVMAddGlobal(module, type_to_llvm(currentType), $2);
                LLVMSetInitializer(con->Valref, res);
                LLVMSetGlobalConstant(con->Valref, true);
            } else {
                /* Allocate the constant and store the const value*/
                con->Valref = LLVMBuildAlloca(builder, type_to_llvm(currentType), $2);
                LLVMBuildStore(builder, res, con->Valref);
            }
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
			SymbolEntry * var = newVariable($1, currentType);
            if (var == NULL)
                YYERROR;

            /* If initialized, cast correctly */
            LLVMValueRef res = LLVMConstNull(type_to_llvm(currentType));
			if ($2.type != NULL) {
				if (!compat_types(currentType, $2.type)) {
					my_error(ERR_LV_ERR, "Illegal assignment from %s to %s on \"%s\"", \
						verbose_type($2.type), verbose_type(currentType), $1);
                    YYERROR;
                }
                res = cast_compat(currentType, $2.type, $2.Valref);
			} 

            if (global_scope) {
                /* Set the var as global */
                var->Valref = LLVMAddGlobal(module, type_to_llvm(currentType), $1);
                LLVMSetInitializer(var->Valref, res);
            } else {
                /* Allocate the variable and store the const value*/
                var->Valref = LLVMBuildAlloca(builder, type_to_llvm(currentType), $1);
                LLVMBuildStore(builder, res, var->Valref);
            }
		}
	| T_id var_init_tail_plus
		{
			SymbolEntry * array = newVariable($1, $2.type);
            if (array == NULL)
                YYERROR;
            
            if (global_scope) {
                /* Set the var as global */
                array->Valref = LLVMAddGlobal(module, currentLLVMType, $1);
                LLVMSetInitializer(array->Valref, LLVMConstNull(currentLLVMType));
            } else {
                /* Allocate the variable and store the const value*/
                array->Valref = LLVMBuildAlloca(builder, currentLLVMType, $1);
            }

		}
	;
var_init_opt
	: /* nothing */ {$$.type = NULL;}
	| '=' expr  
        {
            $$.type = $2.type; 
            $$.Valref = $2.Valref;
        }
	;
var_init_tail_plus
	: '[' const_expr ']' { array_index_check(&($2)); } var_init_tail
		{
			$$.type = typeArray($2.value.i, $5.type);
            if (array_last) {
                currentLLVMType = type_to_llvm(currentType);
                array_last = false;
            }
            currentLLVMType = LLVMArrayType(currentLLVMType, $2.value.i);
		}
	;
var_init_tail
	: /* nothing */  
        { 
            $$.type = currentType; 
            array_last = true;
        }
	| '[' const_expr ']' { array_index_check(&($2)); } var_init_tail
		{
			$$.type = typeArray($2.value.i, $5.type);
            if (array_last) {
                currentLLVMType = type_to_llvm(currentType);
                array_last = false;
            }
            currentLLVMType = LLVMArrayType(currentLLVMType, $2.value.i);
		}
	;
routine
	: routine_header 
        {
            LLVMValueRef func_ref = LLVMGetNamedFunction(module, currentFun->id);
        
            if (func_ref != NULL) {
                if (LLVMCountParams(func_ref) != currentFun->u.eFunction.argno) {
                    my_error(ERR_LV_ERR, "Function %s is already declared with a different parameter count", currentFun->id);
                    YYERROR;
                }

            } else {
                size_t argno = currentFun->u.eFunction.argno;    
                SymbolEntry *curr_param = currentFun->u.eFunction.firstArgument;
                LLVMTypeRef *params = new(sizeof(LLVMTypeRef) * argno);
                int i;

                // Create param list
                for(i=argno-1; i>=0; i--, curr_param=curr_param->u.eParameter.next) {
                    if (curr_param->u.eParameter.type->kind >= TYPE_ARRAY)
                        params[i] = LLVMPointerType(type_to_llvm( \
                            iarray_to_array(curr_param->u.eParameter.type)), 0);
                    else if (curr_param->u.eParameter.mode == PASS_BY_REFERENCE)
                        params[i] = LLVMPointerType(type_to_llvm( \
                            curr_param->u.eParameter.type), 0);
                    else
                        params[i] = type_to_llvm(curr_param->u.eParameter.type);
                }
                
                // Create function type
                LLVMTypeRef funcType = LLVMFunctionType( \
                    type_to_llvm(currentFun->u.eFunction.resultType), \
                        params, argno, false);

                // Create function 
                func_ref = LLVMAddFunction(module, currentFun->id, funcType);
                LLVMSetLinkage(func_ref, LLVMExternalLinkage);
            }

        } routine_tail
		{
            // Actions for when a routine is closing (be it a forward declaration or a definition).
            closeScope();
			currentFunctionType = NULL;
			function_has_ret = false;
            global_scope = true;
		}
	;
routine_tail
	: ';' { forwardFunction(currentFun); }
	| '{' {
        LLVMValueRef func_ref = LLVMGetNamedFunction(module, currentFun->id);
        if (LLVMCountBasicBlocks(func_ref) != 0) {
            my_error(ERR_LV_ERR, "Function %s is already fully defined");
            YYERROR;
        }
        // position builder at start/end of function body
        LLVMBasicBlockRef block = LLVMAppendBasicBlock(func_ref, "entry");
        LLVMPositionBuilderAtEnd(builder, block);

        size_t argno = currentFun->u.eFunction.argno;    
        SymbolEntry *curr_param = currentFun->u.eFunction.firstArgument;
        int i;

        // Store parameters in new local variables if passed by value
        curr_param = currentFun->u.eFunction.firstArgument;
        char * new_str; // IR parameters are <name>_ref
        for(i=argno-1; i>=0; i--, curr_param=curr_param->u.eParameter.next) {
            LLVMValueRef param = LLVMGetParam(func_ref, i);
            if (curr_param->u.eParameter.mode == PASS_BY_VALUE) {
                curr_param->Valref = LLVMBuildAlloca(builder, \
                    type_to_llvm(curr_param->u.eParameter.type), curr_param->id);
                new_str = new(strlen(curr_param->id)+strlen("_ref")+1);
                new_str[0] = '\0';
                strcat(new_str, curr_param->id);
                strcat(new_str, "_ref");
                LLVMBuildStore(builder, param, curr_param->Valref);
                LLVMSetValueName(param, new_str);
                delete(new_str);	//BUG-SQUASHING
            } else {
                LLVMSetValueName(param, curr_param->id);
                curr_param->Valref = param;
            }
        }
    } block_tail '}' 
    {
        if ((currentFunctionType != typeVoid) && (!function_has_ret)) {
            my_error(ERR_LV_ERR, "function does not have a return statement");
            YYERROR;
        }

        if ((currentFunctionType == typeVoid) && (!function_has_ret))
            LLVMBuildRetVoid(builder);

        // remove empty labels at the routine end
        LLVMBasicBlockRef last_block = LLVMGetInsertBlock(builder);
        if (LLVMGetFirstInstruction(last_block) == NULL) {
            LLVMBuildRet(builder, LLVMGetUndef(type_to_llvm(currentFunctionType)));
        }
    }
	;
routine_header
	: routine_header_head T_id '('
		{
			currentFun = newFunction($2);
			openScope();
            global_scope = false;
		} routine_header_opt ')'
		{
			endFunctionHeader(currentFun, $1.type);
		}
	;
routine_header_head
	: T_proc	   { currentFunctionType = $$.type = typeVoid; }
	| T_func type  { currentFunctionType = $$.type = $2.type; }
	;
routine_header_opt
	: type formal routine_header_opt_tail
		{
			if (currentFun == NULL)
				YYERROR;
			if ($2.type == NULL) {
                // NULL is placeholder for &name
				newParameter($2.value.s, $1.type, PASS_BY_REFERENCE, currentFun);
			} else if ($2.type->kind >= TYPE_ARRAY) {
				Type current = $2.type;
				while (current->refType != typeVoid) {
					current = current->refType;
                    if (current->refType == NULL)
                        my_error(ERR_LV_INTERN, "unreachable null array state");
                }
				current->refType = $1.type;
				newParameter($2.value.s, $2.type, PASS_BY_REFERENCE, currentFun);
			} else {
				newParameter($2.value.s, $1.type, PASS_BY_VALUE, currentFun);
			}
		}
	| /* nothing */
	;
routine_header_opt_tail
	: /* nothing */
	| ',' type formal routine_header_opt_tail
		{
			if (currentFun == NULL)
				YYERROR;
			if ($3.type == NULL) {
				newParameter($3.value.s, $2.type, PASS_BY_REFERENCE, currentFun);
			} else if ($3.type->kind >= TYPE_ARRAY) {
				Type current = $3.type;
				while (current->refType != typeVoid)
					current = current->refType;
				current->refType = $2.type;
				newParameter($3.value.s, $3.type, PASS_BY_REFERENCE, currentFun);
			} else {
				newParameter($3.value.s, $2.type, PASS_BY_VALUE, currentFun);
			}
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
	: /* nothing */ { $$.type = typeVoid; }
	| '[' const_expr ']' formal_tail
		{
			array_index_check(&($2));
            $$.type = typeArray($2.value.i, $4.type);
		}
	;
program_header
	: T_prog { currentFunctionType = typeVoid; } T_id '(' ')'
        {
            SymbolEntry * prog = newFunction($3);
            if (prog == NULL)
                exit(EXIT_FAILURE);

            openScope();
            global_scope = false;
            endFunctionHeader(prog, typeVoid);

            LLVMTypeRef funcType = LLVMFunctionType(LLVMVoidType(), NULL, 0, 0);
            LLVMValueRef func = LLVMAddFunction(module, "main", funcType);
            LLVMSetLinkage(func, LLVMExternalLinkage);
            LLVMBasicBlockRef block = LLVMAppendBasicBlock(func, "entry");
            LLVMPositionBuilderAtEnd(builder, block);
        }
	;
program
	: program_header block 
        { 
            LLVMBuildRetVoid(builder); 
            closeScope();
            global_scope = true;
        }
	;
type
	: T_int		{ $$.type = typeInteger; }
	| T_bool	{ $$.type = typeBoolean; }
	| T_char	{ $$.type = typeChar; }
	| T_real	{ $$.type = typeReal; }
	;
const_unit
	: T_CONST_integer
		{
			$$.type = typeInteger;
			$$.value.i = $1;
            $$.Valref = LLVMConstInt(LLVMInt32Type(), $1, false);
		}
	| T_CONST_real
		{
			$$.type = typeReal;
			$$.value.r = $1;
            $$.Valref = LLVMConstReal(LLVMDoubleType(), $1);
		}
	| T_CONST_char
		{
			$$.type = typeChar;
			$$.value.c = $1;
            $$.Valref = LLVMConstInt(LLVMInt8Type(), $1, false);
		}
	| T_CONST_string
		{
			$$.type = typeArray(strlen($1) + 1, typeChar);
			$$.value.s = $1;
            LLVMValueRef str = LLVMConstString($1, strlen($1), false);
            LLVMValueRef tmp = LLVMBuildAlloca(builder, type_to_llvm($$.type), "strtmp");
            LLVMBuildStore(builder, str, tmp);
            $$.Valref = tmp;
		}
	| T_true
		{
			$$.value.b = true;
			$$.type = typeBoolean;
            $$.Valref = LLVMConstInt(LLVMInt1Type(), 1, false);
		}
	| T_false
		{
			$$.value.b = false;
			$$.type = typeBoolean;
            $$.Valref = LLVMConstInt(LLVMInt1Type(), 0, false);
		}
	;
const_expr
	: const_unit { $$ = $1; }
	| T_id
		{   /* constant variables only */
			SymbolEntry *id = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
			if (id == NULL)
				YYERROR;
			if (id->entryType != ENTRY_CONSTANT) {
				my_error(ERR_LV_ERR, "Non-constant identifier \"%s\" found in constant expression", $1);
				YYERROR;
			} 

            $$.type = id->u.eConstant.type;
            memcpy(&($$.value), &(id->u.eConstant.value), sizeof(val_union));
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
	:  const_unit
		{
			$$.is_lvalue = false;
			$$.type = $1.type;
		}
	| '(' expr ')'
		{
			$$ = $2;
		}
	| '(' error ')' { $$.type = typeVoid; }
	| l_value
		{
			$$.is_lvalue = true;
			$$.type = $1.type;
            if ($1.type->kind < TYPE_ARRAY) {
                $$.Valref = LLVMBuildLoad(builder, $1.Valref, "loadtmp");
                $$.v_list = new(sizeof(struct list_node));
                $$.v_list->Valref = $1.Valref;
                $$.v_list->next = NULL;
            } else
                $$.Valref = $1.Valref;
		}
	| call
		{
			$$ = $1;
			$$.is_lvalue = false;
		}
	| expr binop1 expr %prec '*'
		{
			binop_IR(&($1), &($3), $2, &($$));
			$$.is_lvalue = false;
		}
	| expr binop2 expr %prec '+'
		{
			binop_IR(&($1), &($3), $2, &($$));
			$$.is_lvalue = false;
		}
	| expr binop3 expr %prec '<'
		{
			binop_IR(&($1), &($3), $2, &($$));
			$$.is_lvalue = false;
		}
	| expr binop4 expr %prec T_eq
		{
			binop_IR(&($1), &($3), $2, &($$));
			$$.is_lvalue = false;
		}
	| expr binop5 expr %prec T_and
		{
			binop_IR(&($1), &($3), $2, &($$));
			$$.is_lvalue = false;
		}
	| expr binop6 expr %prec T_or
		{
			binop_IR(&($1), &($3), $2, &($$));
			$$.is_lvalue = false;
		}
	| unop expr %prec UN
		{
			unop_IR(&($2), $1, &($$));
			$$.is_lvalue = false;
		}
	;
l_value
	: T_id l_value_tail
		{
			int dims;
			SymbolEntry * id = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
			if (id == NULL)
				YYERROR;
			if (id->Valref == NULL && id->entryType != ENTRY_FUNCTION)
				YYERROR;

			$$.value.i = 0; // if 1, then the l_value is constant

            /* Type Checking for array dimensions */
			switch (id->entryType) {
				case ENTRY_VARIABLE:
					{
						/* Return the appropriate type if it's an array
					 	 * :: $2 is the number of dimensions following the id */
						dims = array_dimensions(id->u.eVariable.type);
						if ($2.value.i > dims)
                            if (dims == 0) {
                                my_error(ERR_LV_ERR, "\"%s\" is not an Array", id->id);
                                YYERROR;
                            } else {
                                my_error(ERR_LV_ERR, "\"%s\" has less dimensions than specified", id->id);
                                YYERROR;
                            }
						else
							$$.type = n_dimension_type(id->u.eVariable.type, $2.value.i);
						break;
					}
				case ENTRY_PARAMETER:
					{
						dims = array_dimensions(id->u.eParameter.type);
						if ($2.value.i > dims)
                            if (dims == 0) {
                                my_error(ERR_LV_ERR, "\"%s\" is not an Array", id->id);
                                YYERROR;
                            } else {
                                my_error(ERR_LV_ERR, "\"%s\" has less dimensions than specified", id->id);
                                YYERROR;
                            }
						else
							$$.type = n_dimension_type(id->u.eParameter.type, $2.value.i);
						break;
					}
				case ENTRY_CONSTANT:
					if ($2.value.i) {
						my_error(ERR_LV_ERR, "Constant \"%s\" cannot be an Array",id->id);
                        YYERROR;
                    }
					$$.type = id->u.eConstant.type;
                    $$.value.i = 1;
					break;
                case ENTRY_FUNCTION:
						my_error(ERR_LV_ERR, "Routine identifier \"%s\" cannot be modified or used as lvalue", id->id);
                        YYERROR;
				default: ;
			}

            /* Code generation */
            if ($2.v_list == NULL) 
                $$.Valref = id->Valref; // No dimensions specified
            else {
                LLVMValueRef * dim_array = array_from_list($2.v_list, $2.value.i);
                $$.Valref = LLVMBuildGEP(builder, id->Valref, \
                                     dim_array, $2.value.i + 1, "geptmp");
                free_list($2.v_list);
				delete(dim_array);		//BUG-SQUASHING
            }

		}
	;
l_value_tail
	: /* Nothing */ 
        {
            $$.value.i = 0; 
            $$.v_list = NULL;
        }
	| '[' expr ']'  l_value_tail
		{
			if (!compat_types(typeInteger, $2.type)) {
                my_error(ERR_LV_ERR, "Array index cannot be %s", verbose_type($2.type));
                YYERROR;
            }
            
            $$.v_list = add_to_list($4.v_list, $2.Valref);
			$$.value.i = 1 + $4.value.i;
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
			SymbolEntry *fun = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
			if (fun == NULL) {
				YYERROR;
            } if (fun->entryType != ENTRY_FUNCTION) {
                my_error(ERR_LV_ERR, "Attempting to call %s which is not a routine", $1);
				YYERROR;
            }

			function_call_func_type_push(fun);
			function_call_param_set(fun->u.eFunction.firstArgument);
			function_call_argv_init(fun);
		} call_opt ')'
		{ 
			SymbolEntry *fun = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
			LLVMValueRef fun_ref = LLVMGetNamedFunction(module, $1);
			if (fun_ref == NULL) {
				my_error(ERR_LV_ERR, "Definition of function %s is not visible at call site", $1);
                YYERROR;
			}
            if (current_func_call_list->current_arg_i != 0) {
				my_error(ERR_LV_ERR, "Too few parameters specified for function %s", $1);
                YYERROR;
            }

            if (fun->u.eFunction.resultType == typeVoid) {
                $$.Valref = LLVMBuildCall(builder, fun_ref, function_call_arglist_get(), function_call_argno_get(), "");
                $$.value.b = false;
             } else {
                $$.Valref = LLVMBuildCall(builder, fun_ref, function_call_arglist_get(), function_call_argno_get(), "calltmp");
                $$.value.b = true;
            }
			$$.type = function_call_type_pop();
		}
	;
call_opt
	: /* Nothing */
	| expr call_opt_tail
		{
			SymbolEntry *currentParam = function_call_param_get();
            Type wanted_type = currentParam->u.eParameter.type;

			if (currentParam == NULL) {
				my_error(ERR_LV_ERR, "Invalid number of parameters specified");
				YYERROR;
			} else if (!compat_types(wanted_type, $1.type)) {
				my_error(ERR_LV_ERR, "Illegal parameter assignment from %s to %s", \
					verbose_type($1.type), verbose_type(wanted_type));
                YYERROR;
			}
            if (wanted_type->kind >= TYPE_ARRAY) {
                Type cur_wanted_dim = wanted_type->refType;
                Type cur_given_dim = $1.type->refType;
                while (cur_wanted_dim->kind >= TYPE_ARRAY) {
                    if (cur_wanted_dim->size != cur_given_dim->size) {
                        my_error(ERR_LV_ERR, "Incompatible array sizes during parameter passing");
                        YYERROR;
                    }
                    cur_given_dim = cur_given_dim->refType;
                    cur_wanted_dim = cur_wanted_dim->refType;
                }
            }

			function_call_param_set(currentParam->u.eParameter.next);
            if (wanted_type->kind >= TYPE_ARRAY) {
                LLVMTypeRef dest_type = LLVMPointerType(type_to_llvm(iarray_to_array($1.type)),0);
                LLVMValueRef tmp = LLVMBuildPointerCast(builder, $1.Valref, dest_type, "ptrcasttmp");
                function_call_argval_push(tmp);
            } else {
                if (currentParam->u.eParameter.mode == PASS_BY_REFERENCE) {
                    if ($1.v_list == NULL || !$1.is_lvalue) {
                        my_error(ERR_LV_ERR, "Only variables can be passed by reference");
                        YYERROR;
                    }
                    function_call_argval_push($1.v_list->Valref);
                } else
                    function_call_argval_push(cast_compat(wanted_type, $1.type, $1.Valref));
            }
		}
	;
call_opt_tail
	: /* Nothing */
	| ',' expr call_opt_tail
		{
			SymbolEntry *currentParam = function_call_param_get();
            Type wanted_type = currentParam->u.eParameter.type;
			if (currentParam == NULL) {
				my_error(ERR_LV_ERR, "Invalid number of parameters specified");
				YYERROR;
			}
			if (!compat_types(currentParam->u.eParameter.type, $2.type)) {
				my_error(ERR_LV_ERR, "Illegal parameter assignment from %s to %s", \
					verbose_type($2.type), verbose_type(currentParam->u.eParameter.type));
                YYERROR;
            }
            if (wanted_type->kind >= TYPE_ARRAY) {
                Type cur_wanted_dim = wanted_type->refType;
                Type cur_given_dim = $2.type->refType;
                while (cur_wanted_dim->kind >= TYPE_ARRAY) {
                    if (cur_wanted_dim->size != cur_given_dim->size) {
                        my_error(ERR_LV_ERR, "Incompatible array sizes during parameter passing");
                        YYERROR;
                    }
                    cur_given_dim = cur_given_dim->refType;
                    cur_wanted_dim = cur_wanted_dim->refType;
                }
            }

			function_call_param_set(currentParam->u.eParameter.next);
            if (wanted_type->kind >= TYPE_ARRAY) {
                LLVMTypeRef dest_type = LLVMPointerType(type_to_llvm(iarray_to_array($2.type)),0);
                LLVMValueRef tmp = LLVMBuildPointerCast(builder, $2.Valref, dest_type, "ptrcasttmp");
                function_call_argval_push(tmp);
            } else {
                if (currentParam->u.eParameter.mode == PASS_BY_REFERENCE) {
                    if ($2.v_list == NULL || !$2.is_lvalue) {
                        my_error(ERR_LV_ERR, "Cannot pass non-variable arguments by reference");
                        YYERROR;
                    }
                    function_call_argval_push($2.v_list->Valref);
                } else 
                    function_call_argval_push(cast_compat(wanted_type, $2.type, $2.Valref));
            }
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
base_stmt
	: ';' 
	| l_value assign expr ';'
		{
			if (!compat_types($1.type, $3.type)) {
				my_error(ERR_LV_ERR, "Illegal assignment from %s to %s ", \
						verbose_type($3.type), verbose_type($1.type));
                YYERROR;
            }
            if ($1.value.i == 1) {
                my_error(ERR_LV_ERR, "Illegal assignment to constant variable");
                YYERROR;
            }

            struct ast_node res = $3;
            if (strcmp($2, "=")) {
                struct ast_node tmp;
                tmp.Valref = LLVMBuildLoad(builder, $1.Valref, "loadtmp");
                tmp.type = $1.type;
                if (!strcmp($2, "+="))
                    binop_IR(&tmp, &$3, "+", &res);
                else if (!strcmp($2, "-="))
                    binop_IR(&tmp, &$3, "-", &res);
                else if (!strcmp($2, "*="))
                    binop_IR(&tmp, &$3, "*", &res);
                else if (!strcmp($2, "/="))
                    binop_IR(&tmp, &$3, "/", &res);
                else if (!strcmp($2, "%="))
                    binop_IR(&tmp, &$3, "%", &res);   
            }

            if ($3.type->kind >= TYPE_ARRAY) {
                Type curr_expr = $3.type;
                Type curr_lvalue = $1.type;
                while (curr_expr->kind >= TYPE_ARRAY) {
                    if (curr_expr->size != curr_lvalue->size) {
                        my_error(ERR_LV_ERR, "Array dimension sizes %d and %d are incompatible for assignment",\
                                            curr_lvalue->size, curr_expr->size);
                        YYERROR;
                    }
                    curr_expr = curr_expr->refType;
                    curr_lvalue = curr_lvalue->refType;
                }
                res.Valref = LLVMBuildLoad(builder, res.Valref, "loadtmp");
            }

            res.Valref = cast_compat($1.type, res.type, res.Valref);
			LLVMBuildStore(builder, res.Valref, $1.Valref);
		}
	| l_value stmt_choice ';'
		{
			if (!compat_types($1.type, typeInteger)) {
				my_error(ERR_LV_ERR, "Type mismatch on \"%s\" operator: lvalue can be %s, %s or %s", \
                    $2, verbose_type(typeReal), verbose_type(typeInteger), verbose_type(typeChar));
                YYERROR;
			}

            struct ast_node tmp, one, res;
            tmp.Valref = LLVMBuildLoad(builder, $1.Valref, "loadtmp");
            tmp.type = $1.type;
            one.Valref = LLVMConstInt(LLVMInt32Type(), 1, false);
            one.type = typeInteger;

            if (!strcmp($2, "++"))
                binop_IR(&tmp, &one, "+", &res);
            else if (!strcmp($2, "--"))
                binop_IR(&tmp, &one, "-", &res);

            LLVMBuildStore(builder, res.Valref, $1.Valref);
		}
	| call ';' 
        {
            if ($1.value.b == true) {
                my_error(ERR_LV_ERR, "Unused function return value");
                YYERROR;
            }
        }
	| T_if '(' expr ')'
		{
			if (!compat_types(typeBoolean, $3.type)) {
				my_error(ERR_LV_ERR, "if: condition is %s instead of %s", \
							verbose_type($3.type), verbose_type(typeBoolean));
                YYERROR;
            }

			new_conditional_scope(IF_COND);

			// 1. Generate condition value.
			LLVMValueRef cond = LLVMBuildICmp(builder, LLVMIntNE, $3.Valref, \
									LLVMConstInt(LLVMInt1Type(), 0, false), "ifcond");
			LLVMValueRef function = LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));

			// 2. Generate new blocks for cases.
			LLVMBasicBlockRef then_ref = LLVMAppendBasicBlock(function, "then");
			LLVMBasicBlockRef else_ref = LLVMAppendBasicBlock(function, "else");
			LLVMBasicBlockRef merge_ref = LLVMAppendBasicBlock(function, "ifmerge");

			conditional_scope_save(then_ref, else_ref, merge_ref);

			// 3. Branch conditionally on then or else.
			LLVMBuildCondBr(builder, cond, then_ref, else_ref);

			// 4. Build then branch prologue.
			LLVMPositionBuilderAtEnd(builder, then_ref);
		} loop_stmt {
			LLVMBasicBlockRef else_ref, merge_ref;
			else_ref = conditional_scope_get(second);
			merge_ref = conditional_scope_get(third);

			// 5. Connect then branch to merge block.
			LLVMBuildBr(builder, merge_ref);
			// 6. Build else branch prologue.
			LLVMPositionBuilderAtEnd(builder, else_ref);
		} stmt_opt_if {
            LLVMBasicBlockRef merge_ref;
			merge_ref = conditional_scope_get(third);

			// 7. Connect else branch to merge block.
			LLVMBuildBr(builder, merge_ref);

			// 8. Position ourselves after the merge block.
			LLVMPositionBuilderAtEnd(builder, merge_ref);

			delete_conditional_scope();
		}
	| T_for '(' T_id ',' range ')' 
		{
            SymbolEntry * i = lookupEntry($3, LOOKUP_ALL_SCOPES, true);
            if (i == NULL)
                YYERROR;

            if (i->entryType != ENTRY_VARIABLE) {
                my_error(ERR_LV_ERR, "FOR: \"%s\" is not a variable", i->id);
                YYERROR;
            } else if (!compat_types(typeInteger, i->u.eVariable.type)) {
                my_error(ERR_LV_ERR, "FOR: control variable \"%s\" is not an Integer", i->id);
                YYERROR;
            }
            new_conditional_scope(FOR_COND);

            LLVMBuildStore(builder, $5.from , i->Valref);
			LLVMValueRef fun= LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));

			LLVMBasicBlockRef for_ref = LLVMAppendBasicBlock(fun, "for");
			LLVMBasicBlockRef forcond_ref = LLVMAppendBasicBlock(fun, "forcond");
			LLVMBasicBlockRef forbody_ref = LLVMAppendBasicBlock(fun, "forbody");
			LLVMBasicBlockRef endfor_ref = LLVMAppendBasicBlock(fun, "endfor");
            conditional_scope_save(for_ref, forbody_ref, endfor_ref);

            LLVMBuildBr(builder, forcond_ref);

            /* Change step */
			LLVMPositionBuilderAtEnd(builder, for_ref);
            LLVMValueRef ival = LLVMBuildLoad(builder, i->Valref, "loadtmp");
            
            if ($5.direction == '+')
                ival = LLVMBuildNSWAdd(builder, ival, $5.step, "addtmp");
            else
                ival = LLVMBuildNSWSub(builder, ival, $5.step, "addtmp");
            LLVMBuildStore(builder, ival, i->Valref);
            LLVMBuildBr(builder, forcond_ref);

			LLVMPositionBuilderAtEnd(builder, forcond_ref);
            ival = LLVMBuildLoad(builder, i->Valref, "loadtmp");

            LLVMValueRef cond;
            if ($5.direction == '+')
                cond = LLVMBuildICmp(builder, LLVMIntSGT, ival, \
                            $5.to, "forcond");
            else 
                cond = LLVMBuildICmp(builder, LLVMIntSLT, ival, \
                            $5.to, "forcond");

            LLVMBuildCondBr(builder, cond, endfor_ref, forbody_ref);

			LLVMPositionBuilderAtEnd(builder, forbody_ref);
		} loop_stmt 
        {
            LLVMBasicBlockRef for_ref = conditional_scope_get(first);
            LLVMBuildBr(builder, for_ref);

            LLVMBasicBlockRef endfor_ref = conditional_scope_get(third);
            LLVMPositionBuilderAtEnd(builder, endfor_ref);

            delete_conditional_scope();
        } 
	| T_while 
        { 
            new_conditional_scope(WHILE_COND);

			LLVMValueRef fun = LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));
            LLVMBasicBlockRef while_ref = LLVMAppendBasicBlock(fun, "while");
			LLVMBasicBlockRef whilebody_ref = LLVMAppendBasicBlock(fun, "whilebody");
			LLVMBasicBlockRef endwhile_ref = LLVMAppendBasicBlock(fun, "endwhile");
            conditional_scope_save(while_ref, whilebody_ref, endwhile_ref);
            
            LLVMBuildBr(builder, while_ref);
			LLVMPositionBuilderAtEnd(builder, while_ref);

        } '(' expr ')'
        { 
            if (!compat_types(typeBoolean, $4.type)) {
				my_error(ERR_LV_ERR, "while: condition is %s instead of %s", \
							verbose_type($4.type), verbose_type(typeBoolean));
                YYERROR;
            }

            LLVMBasicBlockRef whilebody_ref = conditional_scope_get(second);
            LLVMBasicBlockRef endwhile_ref = conditional_scope_get(third);
            LLVMValueRef cond = LLVMBuildICmp(builder, LLVMIntNE, $4.Valref, \
                            LLVMConstInt(LLVMInt1Type(), 0, false), "whilecond");
            LLVMBuildCondBr(builder, cond, whilebody_ref, endwhile_ref);
			LLVMPositionBuilderAtEnd(builder, whilebody_ref);
        } loop_stmt 
        { 
            LLVMBasicBlockRef while_ref = conditional_scope_get(first);
            LLVMBasicBlockRef endwhile_ref = conditional_scope_get(third);
            LLVMBuildBr(builder, while_ref);
			LLVMPositionBuilderAtEnd(builder, endwhile_ref);

            delete_conditional_scope();
        }
	| T_do
		{ 
			new_conditional_scope(DO_COND);

			LLVMValueRef fun = LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));
			LLVMBasicBlockRef do_ref = LLVMAppendBasicBlock(fun, "do");
			LLVMBasicBlockRef docond_ref = LLVMAppendBasicBlock(fun, "docond");
			LLVMBasicBlockRef enddo_ref = LLVMAppendBasicBlock(fun, "enddo");
			conditional_scope_save(do_ref, docond_ref, enddo_ref);

			LLVMBuildBr(builder, do_ref);
			LLVMPositionBuilderAtEnd(builder, do_ref);
		} loop_stmt
		{
			LLVMBasicBlockRef docond_ref = conditional_scope_get(second);
			LLVMBuildBr(builder, docond_ref);
			LLVMPositionBuilderAtEnd(builder, docond_ref);
		}
		T_while '(' expr ')' ';'
		{
			if (!compat_types(typeBoolean, $7.type)) {
				my_error(ERR_LV_ERR, "do..while: condition is %s instead of %s", \
							verbose_type($7.type), verbose_type(typeBoolean));
                YYERROR;
            }

			LLVMBasicBlockRef do_ref = conditional_scope_get(first);
			LLVMBasicBlockRef enddo_ref = conditional_scope_get(third);
			LLVMValueRef cond = LLVMBuildICmp(builder, LLVMIntNE, $7.Valref, \
							LLVMConstInt(LLVMInt1Type(), 0, false), "docondval");
			LLVMBuildCondBr(builder, cond, do_ref, enddo_ref);
			LLVMPositionBuilderAtEnd(builder, enddo_ref);

			delete_conditional_scope();
		}
	| T_switch
	'(' expr ')' '{'
		{
			if (!compat_types(typeInteger, $3.type)) {
				my_error(ERR_LV_ERR, "switch: expression is %s instead of %s", \
							verbose_type($3.type), verbose_type(typeInteger));
                YYERROR;
            }

			new_conditional_scope(SWITCH_COND);
			conditional_scope_valset($3.Valref);

			LLVMValueRef fun = LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));
			LLVMBasicBlockRef switchcond_ref = LLVMAppendBasicBlock(fun, "switch");
			LLVMBasicBlockRef endswitch_ref = LLVMAppendBasicBlock(fun, "endswitch");
			conditional_scope_save(switchcond_ref, NULL, endswitch_ref);

			LLVMBuildBr(builder, switchcond_ref);
			LLVMPositionBuilderAtEnd(builder, switchcond_ref);
		} stmt_tail
		stmt_opt_switch '}'
		{
            LLVMBasicBlockRef switchbody_ref = conditional_scope_get(second);
            LLVMBasicBlockRef switchlast_ref = conditional_scope_get(first);
            if (switchbody_ref != NULL) {
                LLVMPositionBuilderAtEnd(builder, switchbody_ref);
                LLVMBuildBr(builder, switchlast_ref);
            }

			LLVMBasicBlockRef endswitch_ref = conditional_scope_get(third);
			LLVMPositionBuilderAtEnd(builder, endswitch_ref);

			delete_conditional_scope();
		}
	| T_ret stmt_opt_ret ';'
		{
			if (currentFunctionType == NULL)
				YYERROR;
			else if (!compat_types(currentFunctionType, $2.type)) {
				my_error(ERR_LV_ERR, "return: incompatible return type: %s instead of %s", \
                    verbose_type($2.type), verbose_type(currentFunctionType));
                YYERROR;
            }
			function_has_ret = true;
            LLVMBuildRet(builder, cast_compat(currentFunctionType, $2.type, $2.Valref));
		}
	| write '(' stmt_opt_write ')' ';' 
        {
            if ((currentWrite == 1) ||  (currentWrite == 3)) {
                /* Print a newline if WRITELN or WRITESPLN */
                build_const_str_write_call("\n", 1);
            }
        }
	| error ';' 
	;
stmt
	: base_stmt
	| block 
	;
loop_stmt
	: base_stmt
	| loop_block 
	| T_break ';'
		{
            LLVMBasicBlockRef dest = conditional_scope_lastloop_get(third);
			if (dest == NULL) {
                my_error(ERR_LV_ERR, "break statement outside of loop context");
                YYERROR;
            }
            LLVMBuildBr(builder, dest);
		}
	| T_cont ';'
		{
            LLVMBasicBlockRef dest = conditional_scope_lastloop_get(first);
			if (dest == NULL) {
				my_error(ERR_LV_ERR, "continue statement outside of loop context");
                YYERROR;
            }
            LLVMBuildBr(builder, dest);
		}
	;
loop_block
	: '{' {openScope();} loop_block_tail '}' {closeScope();}
	;
loop_block_tail
	: /* Nothing */
	| local_def loop_block_tail
	| loop_stmt loop_block_tail
	| error
	;
stmt_choice
	: T_pp { $$ = "++"; }
	| T_mm { $$ = "--"; }
	;
stmt_opt_if
	: /* Nothing */ 
	| T_else loop_stmt
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
			if (!compat_types(typeInteger, $2.type)) {
				my_error(ERR_LV_ERR, "switch: case is %s instead of %s", \
						verbose_type($2.type), verbose_type(typeInteger));
                YYERROR;
            }

			LLVMBasicBlockRef switchcond_ref = conditional_scope_get(first);
			LLVMPositionBuilderAtEnd(builder, switchcond_ref);

            // Generate condition block for the next case and overwrite scope
			LLVMValueRef fun = LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));
            LLVMBasicBlockRef new_switchcond_ref = LLVMAppendBasicBlock(fun, "case_cond");
			conditional_scope_resave(first, new_switchcond_ref);
    
            // Generate new body, branch from the previous one and overwrite scope
			LLVMBasicBlockRef switchbody_ref = conditional_scope_get(second);
            LLVMBasicBlockRef new_switchbody_ref = LLVMAppendBasicBlock(fun, "case_body");
			conditional_scope_resave(second, new_switchbody_ref);
            if (switchbody_ref != NULL) {
                LLVMPositionBuilderAtEnd(builder, switchbody_ref);
                LLVMBuildBr(builder, new_switchbody_ref);
            }

            // Create case condition check for current case
            LLVMValueRef case_const = LLVMConstInt(LLVMInt32Type(), $2.value.i, false);
			LLVMPositionBuilderAtEnd(builder, switchcond_ref);
            LLVMValueRef switchval = conditional_scope_valget();
			LLVMValueRef caseval = LLVMBuildICmp(builder, LLVMIntNE, switchval, \
							case_const, "case_cond_val");
			LLVMBuildCondBr(builder, caseval, new_switchcond_ref, new_switchbody_ref);
            LLVMBuildBr(builder, switchcond_ref);

			LLVMPositionBuilderAtEnd(builder, new_switchbody_ref);
		}
	;
stmt_opt_switch
	: /* Nothing */
        {
			LLVMBasicBlockRef switchlast_ref = conditional_scope_get(first);
			LLVMBasicBlockRef endswitch_ref = conditional_scope_get(third);
            LLVMPositionBuilderAtEnd(builder, switchlast_ref);
            LLVMBuildBr(builder, endswitch_ref);
        }
	| T_def ':'
        {
			LLVMBasicBlockRef switchlast_ref = conditional_scope_get(first);
            LLVMPositionBuilderAtEnd(builder, switchlast_ref);
            switch_default_case = true;
        } clause
        {
            switch_default_case = false;
        }
	;
stmt_opt_ret
	: /* Nothing */	{ $$.type = typeVoid; }
	| expr			{ $$.type = $1.type; }
	;
stmt_opt_write
	: /* Nothing */
	| format stmt_opt_write_tail
	;
stmt_opt_write_tail
	: /* Nothing */     {;}
	| ',' 
        { 
            if (currentWrite >= 2){
                /* Print space if WRITESP or WRITESPLN*/
                build_const_str_write_call("  ", 1);
            }
        } format stmt_opt_write_tail  
	;
assign
	: '='     { $$ = "="; }
	| T_inc   { $$ = "+="; }
	| T_dec   { $$ = "-="; }
	| T_mul   { $$ = "*="; }
	| T_div   { $$ = "/="; }
	| T_opmod { $$ = "%="; }
	;
range
	: expr range_choice expr range_opt
		{
			if (!compat_types(typeInteger, $1.type)) {
				my_error(ERR_LV_ERR, "FOR: Range start is %s instead of %s", \
                                verbose_type($1.type), verbose_type(typeInteger));
                YYERROR;
            }
			if (!compat_types(typeInteger, $3.type)) {
				my_error(ERR_LV_ERR, "FOR: Range end is %s instead of %s", \
                                verbose_type($3.type), verbose_type(typeInteger));
                YYERROR;
            }
            $$.from = $1.Valref;
            $$.to = $3.Valref;
            $$.step = $4.Valref;
            $$.direction = $2.value.c;
		}
	;
range_choice
	: T_to      {$$.value.c = '+';}
	| T_downto  {$$.value.c = '-';}
	;
range_opt
	: /* Nothing */ { $$.Valref = LLVMConstInt(LLVMInt32Type(), 1, false); }
	| T_step expr
		{
			if (!compat_types(typeInteger, $2.type)) {
				my_error(ERR_LV_ERR, "FOR: STEP is %s instead of %s", \
                                verbose_type($2.type), verbose_type(typeInteger));
                YYERROR;
            }
            $$.Valref = cast_compat(typeInteger, $2.type, $2.Valref);
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
        {
            LLVMBasicBlockRef endswitch_ref = conditional_scope_get(third);
            LLVMBuildBr(builder, endswitch_ref);
            LLVMPositionBuilderAtEnd(builder, endswitch_ref);
        }
	| T_next ';' 
        {
            if (switch_default_case) {
                LLVMBasicBlockRef endswitch_ref = conditional_scope_get(third);
                LLVMBuildBr(builder, endswitch_ref);
                LLVMPositionBuilderAtEnd(builder, endswitch_ref);
            }
        }
	;
write
	: T_write  { currentWrite = 0; }
	| T_wrln   { currentWrite = 1; }
	| T_wrsp   { currentWrite = 2; }
	| T_wrspln { currentWrite = 3; }
	;
format
	: expr
		{
			if (($1.type->kind >= TYPE_ARRAY) && ( $1.type->refType != typeChar)) {
				my_error(ERR_LV_ERR, "Cannot display an Array of any type other than Char");
                YYERROR;
            }

            LLVMValueRef func_ref;
            LLVMValueRef * args = new(3 * sizeof(LLVMValueRef));
            LLVMTypeRef dest_type;
            args[0] = $1.Valref;

            /*  According to Pascal's specification, 
                if the width is not long enough for the data,
                the width specification is ignored, apart from REALs.
            */
            args[1] = LLVMConstInt(LLVMInt32Type(), 0, false); 
            if ($1.type == typeInteger) {
                func_ref = LLVMGetNamedFunction(module, "WRITE_INT");
                LLVMBuildCall(builder, func_ref, args, 2, "");
            } else if ($1.type == typeBoolean) {
                func_ref = LLVMGetNamedFunction(module, "WRITE_BOOL");
                LLVMBuildCall(builder, func_ref, args, 2, "");
            } else if ($1.type == typeChar) {
                func_ref = LLVMGetNamedFunction(module, "WRITE_CHAR");
                LLVMBuildCall(builder, func_ref, args, 2, "");
            } else if ($1.type == typeReal) {
                func_ref = LLVMGetNamedFunction(module, "WRITE_REAL");
                args[2] = LLVMConstInt(LLVMInt32Type(), DEFAULT_REAL_PRECISION, false); 
                LLVMBuildCall(builder, func_ref, args, 3, "");
            } else if ($1.type->kind >= TYPE_ARRAY){
                // Array Type. store the array and pass the pointer to WRITE_STRING
                func_ref = LLVMGetNamedFunction(module, "strlen");
                dest_type = LLVMPointerType(type_to_llvm(iarray_to_array($1.type)), 0);
                args[0] = LLVMBuildPointerCast(builder, $1.Valref, dest_type, "ptrcasttmp");
                args[1] = LLVMBuildCall(builder, func_ref, args, 1, "calltmp");
                func_ref = LLVMGetNamedFunction(module, "WRITE_STRING");
                LLVMBuildCall(builder, func_ref, args, 2, "");
            } else {
                my_error(ERR_LV_ERR, "Expression is not printable");
            }
            delete(args);
		}
	| T_form '(' expr ',' expr format_opt ')'
		{
			if (!compat_types(typeInteger, $5.type)) {
				my_error(ERR_LV_ERR, "FORM: second argument is %s instead of %s", \
										verbose_type($5.type), verbose_type(typeInteger));
                YYERROR;
            }
			if (($6.value.b == true) && (!compat_types(typeReal, $3.type))) {
				my_error(ERR_LV_ERR, "FORM: first argument is %s instead of %s but precision is specified", \
                                        verbose_type($5.type), verbose_type(typeReal));
                YYERROR;
            }
            
            LLVMValueRef func_ref;
            LLVMValueRef * args = new(3 * sizeof(LLVMValueRef));
            LLVMTypeRef dest_type;
            args[0] = $3.Valref;
            args[1] = cast_compat(typeInteger, $5.type, $5.Valref);

            if ($6.value.b == true) {
                /* If a third argument is specified, cast the formatted value to REAL */
                args[0] = cast_compat(typeReal, $3.type, $3.Valref);
                args[2] = cast_compat(typeInteger, $6.type, $6.Valref);
                func_ref = LLVMGetNamedFunction(module, "WRITE_REAL");
                LLVMBuildCall(builder, func_ref, args, 3, "");
            } else {
                if ($3.type == typeInteger) {
                    func_ref = LLVMGetNamedFunction(module, "WRITE_INT");
                    LLVMBuildCall(builder, func_ref, args, 2, "");
                } else if ($3.type == typeBoolean) {
                    func_ref = LLVMGetNamedFunction(module, "WRITE_BOOL");
                    LLVMBuildCall(builder, func_ref, args, 2, "");
                } else if ($3.type == typeChar) {
                    func_ref = LLVMGetNamedFunction(module, "WRITE_CHAR");
                    LLVMBuildCall(builder, func_ref, args, 2, "");
                } else if ($3.type == typeReal) {
                    func_ref = LLVMGetNamedFunction(module, "WRITE_REAL");
                    /* Use the default precision for reals if precision is not specified */
                    args[2] = LLVMConstInt(LLVMInt32Type(), DEFAULT_REAL_PRECISION, false); 
                    LLVMBuildCall(builder, func_ref, args, 3, "");
                } else {
                    /*  Array Type. pass a pointer to the array to WRITE_STRING */
                    dest_type = LLVMPointerType(type_to_llvm(iarray_to_array($3.type)), 0);
                    func_ref = LLVMGetNamedFunction(module, "WRITE_STRING");
                    args[0] = LLVMBuildPointerCast(builder, $3.Valref, dest_type, "ptrcasttmp");
                    LLVMBuildCall(builder, func_ref, args, 2, "");
                }
            }
            delete(args);
		}
	;
format_opt
	: /* Nothing */ { $$.value.b = false; }
	| ',' expr
		{
			if (!compat_types(typeInteger, $2.type)) {
				my_error(ERR_LV_ERR, "FORM: third argument is %s instead of %s", \
                                verbose_type($2.type), verbose_type(typeInteger));
                YYERROR;
            }
			$$.value.b = true;
            $$.Valref = $2.Valref;
		}
	;
%%

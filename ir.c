/*
 * .: >> ir.h
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Tue 04 Jun 2013 10:52:43 AM EEST
 *
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "ir.h"
#include "error.h"

/* LLVM Global objects */
LLVMBuilderRef builder;
LLVMModuleRef module;

/* Global variable for list of conditional statements (ofc loops included). */
struct cond_scope *current_cond_scope_list = NULL;

/* Global variable for stack of function call frames. */
struct func_call *current_func_call_list;

/* Adds an element to the back of a list. Creates a new list if head is NULL */
struct list_node * add_to_list(struct list_node * head, LLVMValueRef val) {
    struct list_node * newnode = (struct list_node *) new(sizeof(struct list_node));

    newnode->Valref = val;
    newnode->next = head; 
    return newnode;
}

/* Frees a list */
void free_list(struct list_node * head) {
    struct list_node * current = head;
    struct list_node * next;
    while (current != NULL) {
       next = current->next;
       free(current);
       current = next; }
}

/* Creates an array of ValueRefs from a given list. 
 * The first item of the array is the constant 0, following the usage
 * of BuildGEP command */
LLVMValueRef * array_from_list(struct list_node * head, unsigned int size) {
    int i=1;
    LLVMValueRef * res = malloc((size + 1) * sizeof(LLVMValueRef));
    res[0] = LLVMConstInt(LLVMInt32Type(), 0, false);

     while (head != NULL) {
        res[i] = head->Valref;
        head = head->next;
        i++;
    }
    return res;
}

/* Creates and holds a new scope. */
void new_conditional_scope (cond_type type) {
	struct cond_scope *temp_scope;
	struct cond_scope *prev_loop_scope;

	temp_scope = new(sizeof(struct cond_scope));
	temp_scope->prev = current_cond_scope_list;

	temp_scope->type = type;

	prev_loop_scope = (current_cond_scope_list == NULL) ? NULL : current_cond_scope_list->last_visible_loop;
	switch (type) {
		case IF_COND		:
			temp_scope->last_visible_loop = prev_loop_scope;
			break;
		case FOR_COND		:
		case WHILE_COND		:
		case DO_COND		:
			temp_scope->last_visible_loop = temp_scope;
			break;
		case SWITCH_COND	:
			temp_scope->last_visible_loop = NULL;
			break;
		default:
			my_error(ERR_LV_INTERN, "illegal conditional block type");
	}

	current_cond_scope_list = temp_scope;
}

/* Deletes a scope from the scope list. */
void delete_conditional_scope (void) {
	struct cond_scope *temp_scope;

	if (current_cond_scope_list == NULL)
		my_error(ERR_LV_INTERN, "Conditional scope close");
	temp_scope = current_cond_scope_list->prev;
	delete(current_cond_scope_list);
	current_cond_scope_list = temp_scope;
}

/* Puts the passed values in the current conditional scope. */
void conditional_scope_save (LLVMBasicBlockRef first, LLVMBasicBlockRef second, LLVMBasicBlockRef third) {
	if (current_cond_scope_list == NULL)
		my_error(ERR_LV_INTERN, "Conditional scope undefined");
	current_cond_scope_list->first = first;
	current_cond_scope_list->second = second;
	current_cond_scope_list->third = third;
}

/* Inserts a value reference (needed for switch statements) in the appropriate field of the conditional scope structure. */
void conditional_scope_valset (LLVMValueRef vr) {
	if (current_cond_scope_list == NULL)
		my_error(ERR_LV_INTERN, "Conditional scope undefined");
	current_cond_scope_list->val = vr;
}

/* Simply sanity checking (unneeded, as it is guarded by the parser rules) and returns the ValueRef of the current conditional scope. */
LLVMValueRef conditional_scope_valget (void) {
	if (current_cond_scope_list == NULL)
		my_error(ERR_LV_INTERN, "Conditional scope undefined");
	return (current_cond_scope_list->val);
}

/* Create a new function pushes a new function call type frame on the stack and sets its type. */
void function_call_func_type_push (SymbolEntry *fun) {
	struct func_call *temp_call;

	Type type = fun->u.eFunction.resultType;

	temp_call = new(sizeof(struct func_call));
	temp_call->prev = current_func_call_list;

	temp_call->func_ref = fun;
	temp_call->call_type = type;
	temp_call->current_param = NULL;

	current_func_call_list = temp_call;
}

/* Removes a frame from the function call stack. */
Type function_call_type_pop (void) {
	struct func_call *temp_call;
	Type ret_type;

	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	ret_type = current_func_call_list->call_type;

	temp_call = current_func_call_list;
	current_func_call_list = current_func_call_list->prev;

	delete(temp_call);

	return ret_type;
}

/* Updates the current parameter field of the currently top-of-the-stack call frame. */
void function_call_param_set (SymbolEntry *param_ref) {
	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	current_func_call_list->current_param = param_ref;
}

/* Returns the current parameter of <bla-bla-bla_see-above>. */
SymbolEntry *function_call_param_get (void) {
	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	return (current_func_call_list->current_param);
}

/* Initializes a proper length array for the arguments of a function call. */
void function_call_argv_init (SymbolEntry *fun) {
	SymbolEntry *cur_arg;
	size_t i = 0;

	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	cur_arg = fun->u.eFunction.firstArgument;
	while (cur_arg != NULL) {
		i++;
		cur_arg = cur_arg->u.eParameter.next;
	}

	current_func_call_list->argv = new((sizeof(LLVMValueRef))*i);
	current_func_call_list->current_arg_i = i;
	current_func_call_list->total_argno = i;

//	fprintf(stderr, "The call %s has %u arguments.\n", fun->id, i);		//TAG: Remove - simple sanity check.
}

/* 'Push' a LLVMValueRef in the current function call. */
void function_call_argval_push (LLVMValueRef val) {
	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	current_func_call_list->argv[(current_func_call_list->current_arg_i) - 1] = val;
	current_func_call_list->current_arg_i--;
}

/* Return the pointer to the argument LLVMValueRef array for the current function call frame. */
LLVMValueRef *function_call_arglist_get (void) {
	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	return current_func_call_list->argv;
}

/* Return the number of arguments for the current function frame. */
size_t function_call_argno_get (void) {
	if (current_func_call_list == NULL)
		my_error(ERR_LV_INTERN, "Function call frame undefined");

	return current_func_call_list->func_ref->u.eFunction.argno;
}

/* Converts a type from the symbol table format to the corresponding LLVM one. */
LLVMTypeRef type_to_llvm(Type t) {
	LLVMTypeRef res;
	switch (t->kind) {
		case TYPE_VOID:
			res = LLVMVoidType();
			break;
		case TYPE_INTEGER:
			res = LLVMInt32Type();
			break;
		case TYPE_REAL:
			res = LLVMDoubleType();
			break;
		case TYPE_BOOLEAN:
			res = LLVMInt1Type();
			break;
		case TYPE_CHAR:
			res = LLVMInt8Type();
			break;
        case TYPE_ARRAY:
			res = LLVMArrayType(type_to_llvm(t->refType), t->size);
			break;
        case TYPE_IARRAY:
			res = LLVMArrayType(type_to_llvm(t->refType), 0);
			break;
		default:
			res = NULL;
	}
	return res;
}

/* Cast an LLVM Value from one type to another. */
LLVMValueRef cast_compat(Type dest, Type src, LLVMValueRef src_val) {
    LLVMValueRef res;
    if ((dest == typeReal) && (src == typeInteger)) {
         res = LLVMBuildCast(builder, LLVMSIToFP, src_val, LLVMDoubleType(), "casttmp");
    } else if ((dest == typeReal) && (src == typeChar)) {
        res = LLVMBuildCast(builder, LLVMUIToFP, src_val, LLVMDoubleType(), "casttmp");
    } else if ((dest == typeChar) && (src == typeInteger)) {
        /* Take the Highest order bit (8th bit) of the integer by shifting right
         * 7 times and truncating to 1 bit.
         * If that bit is 1, the integer was negative and a Neg operation 
         * is performed
         * If it was 0, the integer was positive and no action is taken.
         * Finally, truncate the integer to 8 bits */

        LLVMValueRef shift_amm = LLVMConstInt(LLVMInt32Type(), 7, false);
        LLVMValueRef imv = LLVMBuildLShr(builder, src_val, shift_amm, "lshrtmp"); 
        imv = LLVMBuildTrunc(builder, imv, LLVMInt1Type(), "trunctmp"); 
        LLVMValueRef neg = LLVMBuildNeg(builder, src_val, "negtmp"); 
        imv = LLVMBuildSelect(builder, imv, neg, src_val, "selecttmp");
        res = LLVMBuildTrunc(builder, imv, LLVMInt8Type(), "trunctmp");

    } else if ((dest == typeInteger) && (src == typeChar)) {
        res = LLVMBuildZExt(builder, src_val, LLVMInt32Type(), "zexttmp");
    } else {
        res = src_val;
    }
    return res;
}

/* Creates a ARRAY type from an IARRAY type by setting 0 to the first dimension */
Type iarray_to_array(Type array) {
        return typeArray(0, array->refType);
}

/* Generates IR for all external function prototypes and adds them to symbol table */
void generate_external_definitions(void) {
    LLVMTypeRef *params = new(sizeof(LLVMTypeRef) * 3);
    SymbolEntry * func;
    LLVMValueRef func_ref;

    // PROC putchar(char)
    params[0] = type_to_llvm(typeChar);
    func_ref = LLVMAddFunction(module, "putchar", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("putchar");
    newParameter("__PLACEHOLDER__", typeChar, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);
    
    // PROC puts(char[])
    params[0] = LLVMPointerType(type_to_llvm(typeArray(0, typeChar)), 0);
    func_ref = LLVMAddFunction(module, "puts", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("puts");
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // PROC WRITE_INT(int, int)
    params[0] = type_to_llvm(typeInteger);
    params[1] = type_to_llvm(typeInteger);
    func_ref = LLVMAddFunction(module, "WRITE_INT", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("WRITE_INT");
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // PROC WRITE_BOOL(bool, int)
    params[0] = type_to_llvm(typeBoolean);
    params[1] = type_to_llvm(typeInteger);
    func_ref = LLVMAddFunction(module, "WRITE_BOOL", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("WRITE_BOOL");
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeBoolean, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // PROC WRITE_CHAR(char, int)
    params[0] = type_to_llvm(typeChar);
    params[1] = type_to_llvm(typeInteger);
    func_ref = LLVMAddFunction(module, "WRITE_CHAR", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("WRITE_CHAR");
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeChar, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // PROC WRITE_REAL(REAL, int, int)
    params[0] = type_to_llvm(typeReal);
    params[1] = type_to_llvm(typeInteger);
    params[2] = type_to_llvm(typeInteger);
    func_ref = LLVMAddFunction(module, "WRITE_REAL", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 3, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("WRITE_REAL");
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // PROC WRITE_STRING(char[], int)
    params[0] = LLVMPointerType(type_to_llvm(typeArray(0, typeChar)), 0);
    params[1] = type_to_llvm(typeInteger);
    func_ref = LLVMAddFunction(module, "WRITE_STRING", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("WRITE_STRING");
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // FUNC int READ_INT()
    func_ref = LLVMAddFunction(module, "READ_INT", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 0, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("READ_INT");
    endFunctionHeader(func, typeInteger);

    // FUNC bool READ_BOOL()
    func_ref = LLVMAddFunction(module, "READ_BOOL", \
                    LLVMFunctionType(type_to_llvm(typeBoolean), params, 0, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("READ_BOOL");
    endFunctionHeader(func, typeBoolean);

    // FUNC int getchar()
    func_ref = LLVMAddFunction(module, "getchar", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 0, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("getchar");
    endFunctionHeader(func, typeInteger);

    // FUNC REAL READ_REAL()
    func_ref = LLVMAddFunction(module, "READ_REAL", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 0, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("READ_REAL");
    endFunctionHeader(func, typeReal);

    // PROC READ_STRING(int, char[])
    params[0] = type_to_llvm(typeInteger);
    params[1] = LLVMPointerType(type_to_llvm(typeArray(0, typeChar)), 0);
    func_ref = LLVMAddFunction(module, "READ_STRING", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("READ_STRING");
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // FUNC int abs(int)
    params[0] = type_to_llvm(typeInteger);
    func_ref = LLVMAddFunction(module, "abs", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("abs");
    newParameter("__PLACEHOLDER__", typeInteger, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeInteger);

    // FUNC REAL fabs(REAL)
    params[0] = type_to_llvm(typeReal);
    func_ref = LLVMAddFunction(module, "fabs", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("fabs");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL sqrt(REAL)
    func_ref = LLVMAddFunction(module, "sqrt", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("sqrt");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL sin(REAL)
    func_ref = LLVMAddFunction(module, "sin", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("sin");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL cos(REAL)
    func_ref = LLVMAddFunction(module, "cos", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("cos");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL tan(REAL)
    func_ref = LLVMAddFunction(module, "tan", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("tan");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL arctan(REAL)
    func_ref = LLVMAddFunction(module, "arctan", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("arctan");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL exp(REAL)
    func_ref = LLVMAddFunction(module, "exp", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("exp");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL ln(REAL)
    func_ref = LLVMAddFunction(module, "ln", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("ln");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL trunc(REAL)
    func_ref = LLVMAddFunction(module, "trunc", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("trunc");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL round(REAL)
    func_ref = LLVMAddFunction(module, "round", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("round");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeReal);

    // FUNC REAL pi()
    func_ref = LLVMAddFunction(module, "pi", \
                    LLVMFunctionType(type_to_llvm(typeReal), params, 0, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("pi");
    endFunctionHeader(func, typeReal);

    // FUNC INT ROUND(REAL)
    func_ref = LLVMAddFunction(module, "ROUND", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("ROUND");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeInteger);

    // FUNC INT TRUNC(REAL)
    func_ref = LLVMAddFunction(module, "TRUNC", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("TRUNC");
    newParameter("__PLACEHOLDER__", typeReal, PASS_BY_VALUE, func);
    endFunctionHeader(func, typeInteger);

    // FUNC INT strlen(char[])
    params[0] = LLVMPointerType(type_to_llvm(typeArray(0, typeChar)), 0);
    func_ref = LLVMAddFunction(module, "strlen", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 1, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("strlen");
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    endFunctionHeader(func, typeInteger);

    // FUNC INT strcmp(char[], char[])
    params[1] = LLVMPointerType(type_to_llvm(typeArray(0, typeChar)), 0);
    func_ref = LLVMAddFunction(module, "strcmp", \
                    LLVMFunctionType(type_to_llvm(typeInteger), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("strcmp");
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    endFunctionHeader(func, typeInteger);

    // PROC strcpy(char[], char[])
    func_ref = LLVMAddFunction(module, "strcpy", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("strcpy");
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

    // PROC strcat(char[], char[])
    func_ref = LLVMAddFunction(module, "strcat", \
                    LLVMFunctionType(type_to_llvm(typeVoid), params, 2, false));
    LLVMSetLinkage(func_ref, LLVMExternalLinkage);
    func = newFunction("strcat");
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    newParameter("__PLACEHOLDER__", typeIArray(typeChar), PASS_BY_VALUE, func);
    endFunctionHeader(func, typeVoid);

}

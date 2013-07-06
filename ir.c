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
#include "ir.h"
#include "error.h"

LLVMBuilderRef builder;
LLVMModuleRef module;

/* Adds an element to the back of a list. 
 * Creates a new list if head is NULL */
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
       current = next;
    }
}

/* Creates an array of ValueRefs from a given list. 
 * The first item of the array is the constant 0, following the usage
 * of the BuildGEP command */
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


/* Global variable for list of conditional statements (ofc loops included). */
struct cond_scope *current_cond_scope_list = NULL;

/* Creates and holds a new scope. */
void new_conditional_scope (cond_type type) {
	struct cond_scope *temp_scope;
	struct cond_scope *prev_loop_scope;
	uint8_t prev_cond_flags;

	temp_scope = new(sizeof(struct cond_scope));
	temp_scope->prev = current_cond_scope_list;

	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * control_flow_flags algorithm:
	 *	cond_scope_delete			:	.pop()
	 *	if(X)						:	X
	 *	for(X) | while(X) | do(X)	:	X | 01
	 *	switch(X)					:	X | 10
	 * operational semantics:
	 *	1X	:	enveloped by break
	 *	X1	:	enveloped by loop statement (for/while/do-while)
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	temp_scope->type = type;

	prev_cond_flags = (current_cond_scope_list == NULL) ? 0x00 : current_cond_scope_list->control_flow_flags;
	prev_loop_scope = (current_cond_scope_list == NULL) ? NULL : current_cond_scope_list->last_visible_loop;
	switch (type) {
		case IF_COND		:
			temp_scope->last_visible_loop = prev_loop_scope;
			temp_scope->control_flow_flags = prev_cond_flags;
			break;
		case FOR_COND		:
		case WHILE_COND		:
		case DO_COND		:
			temp_scope->last_visible_loop = temp_scope;
			temp_scope->control_flow_flags = (prev_cond_flags | 0x01);
			break;
		case SWITCH_COND	:
			temp_scope->last_visible_loop = NULL;
			temp_scope->control_flow_flags = (prev_cond_flags | 0x02);
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

/* Converts a type from the symbol table format to the corresponding LLVM one */
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
		default:
			res = NULL;
	}
	return res;
}

/* Cast an LLVM Value from one type to another */
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

        LLVMValueRef shift_amm = LLVMConstInt(LLVMInt8Type(), 7, false);
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

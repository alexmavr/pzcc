/*
 * .: Library for IR generation.
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Tue 04 Jun 2013 10:53:07 AM EEST
 *
 */

#ifndef __IR_H__ 
#define __IR_H__

#include <llvm-c/Core.h>
#include "symbol.h"
#include "general.h"

extern LLVMBuilderRef builder;
extern LLVMModuleRef module;

/* This is the default number of decimal digits shown when printing REALs */
#define DEFAULT_REAL_PRECISION 5

/* Structure : General LLVMValueRef LL */
struct list_node {
    LLVMValueRef Valref;
    struct list_node * next;
};

#define list_move_to_next(_) ({_ = _->next;})

struct list_node *add_to_list(struct list_node * head, LLVMValueRef val);
LLVMValueRef *array_from_list(struct list_node * head, unsigned int size);
void free_list(struct list_node * head);

/* Structure : Conditional scope LL (for if/while/do/for/switch support in LLVM IR generation) stack implementation */
extern struct cond_scope *current_cond_scope_list;

typedef enum { IF_COND, FOR_COND, WHILE_COND, DO_COND, SWITCH_COND } cond_type;
struct cond_scope {
	cond_type type;

	LLVMBasicBlockRef first;
	LLVMBasicBlockRef second;
	LLVMBasicBlockRef third;

	LLVMValueRef val;

	struct cond_scope *last_visible_loop;

	struct cond_scope *prev;
};

void new_conditional_scope (cond_type type);
void delete_conditional_scope (void);

void conditional_scope_save (LLVMBasicBlockRef first, LLVMBasicBlockRef second, LLVMBasicBlockRef third);
//LLVMBasicBlockRef conditional_scope_get (int num);	//Why did I keep this?
#define conditional_scope_get(field)	(current_cond_scope_list->field)
#define conditional_scope_resave(field, ref) (current_cond_scope_list->field = ref)

#define conditional_scope_lastloop_get(field)	(((current_cond_scope_list->last_visible_loop) == NULL) ? NULL : (current_cond_scope_list->last_visible_loop->field))

void conditional_scope_valset (LLVMValueRef vr);
LLVMValueRef conditional_scope_valget (void);

/* Structure : Function call stack (for nested calls of type "a(b(c())") */
extern struct func_call *current_func_call_list;

struct func_call {
	SymbolEntry *func_ref;
	Type call_type;
	SymbolEntry *current_param;

	LLVMValueRef *argv;
	size_t current_arg_i;
	size_t total_argno;

	struct func_call *prev;
};

void function_call_func_type_push (SymbolEntry *fun);
Type function_call_type_pop (void);

void function_call_param_set (SymbolEntry *param_ref);
SymbolEntry *function_call_param_get (void);

void function_call_argv_init (SymbolEntry *fun);
void function_call_argval_push (LLVMValueRef val);
LLVMValueRef *function_call_arglist_get (void);
size_t function_call_argno_get (void);

/* Interface : Type transformation (?) methods */
LLVMTypeRef type_to_llvm(Type t);
Type iarray_to_array(Type array);
LLVMValueRef cast_compat(Type dest, Type src, LLVMValueRef src_val);

void generate_external_definitions(void);

void build_const_str_write_call(const char * string, int size);
#endif	/* __IR_H__ */

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

struct list_node {
    LLVMValueRef Valref;
    struct list_node * next;
};

#define list_move_to_next(_) ({_ = _->next;})

struct list_node *add_to_list(struct list_node * head, LLVMValueRef val);
LLVMValueRef *array_from_list(struct list_node * head, unsigned int size);
void free_list(struct list_node * head);

struct cond_scope {
	LLVMBasicBlockRef first;
	LLVMBasicBlockRef second;
	LLVMBasicBlockRef third;
	struct cond_scope *prev;
};

extern struct cond_scope *current_cond_scope_list;
void new_conditional_scope (void);
void delete_conditional_scope (void);
LLVMBasicBlockRef conditional_scope_get (int num);
#define conditional_scope_get(field) (current_cond_scope_list->field)
void conditional_scope_save (LLVMBasicBlockRef first, LLVMBasicBlockRef second, LLVMBasicBlockRef third);

LLVMTypeRef type_to_llvm(Type t);
LLVMValueRef cast_compat(Type dest, Type src, LLVMValueRef src_val);

#endif	/* __IR_H__ */

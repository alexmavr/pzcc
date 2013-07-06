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

typedef enum { IF_COND, FOR_COND, WHILE_COND, DO_COND, SWITCH_COND } cond_type;
struct cond_scope {
	cond_type type;
	//TODO: What did we say we would do with switches? Was it an array of BBRefs or inlining the condition checks?
	//TODO: If we want switches (or whatever that was) inside whiles not to have breaks, we can do a flag inheritance scheme like with curses.
	bool control_flow_flags;

	LLVMBasicBlockRef first;
	LLVMBasicBlockRef second;
	LLVMBasicBlockRef third;

	LLVMValueRef val;

	struct cond_scope *last_visible_loop;

	struct cond_scope *prev;
};

extern struct cond_scope *current_cond_scope_list;
void new_conditional_scope (cond_type type);
void delete_conditional_scope (void);

void conditional_scope_save (LLVMBasicBlockRef first, LLVMBasicBlockRef second, LLVMBasicBlockRef third);
//LLVMBasicBlockRef conditional_scope_get (int num);	//Why did I keep this?
#define conditional_scope_get(field)	(current_cond_scope_list->field)
#define conditional_scope_resave(field, ref) (current_cond_scope_list->field = ref)

#define conditional_scope_lastloop_get(field)	(((current_cond_scope_list->last_visible_loop) == NULL) ? NULL : (current_cond_scope_list->last_visible_loop->field))

void conditional_scope_valset (LLVMValueRef vr);
LLVMValueRef conditional_scope_valget (void);

LLVMTypeRef type_to_llvm(Type t);
LLVMValueRef cast_compat(Type dest, Type src, LLVMValueRef src_val);

#endif	/* __IR_H__ */

/*
 * .: General library for brevity in lexer and parser source file.
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Mon 18 Mar 2013 04:01:47 PM EET
 *
 */

#ifndef __COMP_LIB_H__
#define __COMP_LIB_H__

#include <stdbool.h>
#include "symbol.h"
#include "parser.h"

//Demotion from int to char by cutting all but the 8 LSB bits.
#define int_to_char(n) ((char) ((n) & 0xFF))

/* Type Checking */
const char *verbose_type(Type t);
int array_dimensions(Type t);
Type n_dimension_type(Type t, int n);
bool compat_types(Type t1, Type t2); // true if t2 can be converted to t1

void openLookScope(void);
void closeLookScope(void);

void eval_const_unop(struct ast_node *operand, const char *op, struct ast_node *res);
Type binop_type_check(const char *op, Type t);
void binop_IR(struct ast_node *left, struct ast_node *right, const char *op, struct ast_node *res);
void unop_IR(struct ast_node *operand, const char *op, struct ast_node *res);

void eval_const_binop(struct ast_node *left, struct ast_node *right, const char *op, struct ast_node *res);

int array_index_check(struct ast_node *_);

#endif	/* __COMP_LIB_H__ */

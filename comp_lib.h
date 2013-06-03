/* 
 * .: General library for brevity in lexer and parser source file.
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Mon 18 Mar 2013 04:01:47 PM EET
 * 
 */
#include "symbol/symbol.h"
#include "parser.h"
#include "stdbool.h"

#define INTERNAL_ERROR 0

extern char *filename;
extern int yylineno;

//Demotion from int to char by cutting all but the 8 LSB bits.
#define int_to_char(n) ((char) ((n) & 0xFF))

/* Error Reporting */
typedef enum { ERR_LV_WARN, ERR_LV_ERR, ERR_LV_CRIT, ERR_LV_INTERN } error_lv;

void yyerror (const char *msg);
void my_error (error_lv level, const char *msg, ...);

void crit_cleanup (void);

/* Type Checking */
const char * verbose_type(Type t); 
int array_dimensions(Type t);
Type n_dimension_type(Type t, int n);
bool compat_types(Type t1, Type t2); // true if t2 can be converted to t1

void openLookScope();
void closeLookScope();

void eval_const_unop(struct ast_node * operand, const char * op, struct ast_node * res);
Type binop_type_check(const char * op, Type t);
void binop_IR(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res);
void unop_IR(struct ast_node * operand, const char * op, struct ast_node * res);

void eval_const_binop(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res );

int array_index_check(struct ast_node * _);

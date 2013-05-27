/* 
 * .: General library for brevity in lexer source file.
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Mon 18 Mar 2013 04:01:47 PM EET
 * 
 */
#include "symbol/symbol.h"
#include "parser.h"
#include "stdbool.h"

extern int yylineno;

#define int_to_char(n) ((char) ((n) & 0xFF))

/* Error Reporting */
typedef enum { ERR_LV_WARN, ERR_LV_CRIT } error_lv;

void lex_error (error_lv level, const char *msg, ...);
void yyerror (const char *msg);
void type_error (const char *msg, ...);

void crit_cleanup (void);

/* Type Checking */
const char * verbose_type(Type t); 
int array_dimensions(Type t);
Type n_dimension_type(Type t, int n);
bool compat_types(Type t1, Type t2); // true if t2 can be converted to t1

void openLookScope();
void closeLookScope();

void eval_const_binop(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res );

int array_index_check(struct ast_node * _);

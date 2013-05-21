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


extern int yylineno;

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

void eval_const_binop(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res );

void array_index_check(struct ast_node * _);

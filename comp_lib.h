/* 
 * .: General library for brevity in lexer source file.
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Mon 18 Mar 2013 04:01:47 PM EET
 * 
 */
#include "symbol/symbol.h"

extern int yylineno;

typedef enum { ERR_LV_WARN, ERR_LV_CRIT } error_lv;

void lex_error (error_lv level, const char *msg, ...);
void yyerror (const char *msg);
void type_error (const char *msg, ...);

void crit_cleanup (void);


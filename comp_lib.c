/* 
 * .: >> comp_lib.h
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "nalfemp"
 * @: Mon 18 Mar 2013 04:10:23 PM EET
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "comp_lib.h"

//Cleanup on critical error.
void crit_cleanup (void) {
	;
}

//Lexical error function.
void lex_error (error_lv level, const char *msg) {
	fprintf(stderr, "Lexical error [%d @ %s ]: %s\n", yylineno, yytext, msg);
	exit(EXIT_FAILURE);
}

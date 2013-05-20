/* 
 * .: >> comp_lib.h
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Mon 18 Mar 2013 04:10:23 PM EET
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "comp_lib.h"

//Cleanup on critical error.
void crit_cleanup (void) {
	;
}

/*  Lexical Error function  */
void lex_error (error_lv level, const char *msg, ...) {
	va_list va;

	va_start(va, msg);
	switch (level) {
		case ERR_LV_WARN:
			fprintf(stderr, "WARNING: ");
			break;
		case ERR_LV_CRIT:
			fprintf(stderr, "ERROR: ");
			break;
		default:
			fprintf(stderr, "My mind just exploded\n");
			exit(EXIT_FAILURE);
	}
	fprintf(stderr, "Lexical error [line %d]: ", yylineno);
	vfprintf(stderr, msg, va);
	fprintf(stderr, "\n");
	va_end(va);
	if (level == ERR_LV_CRIT) {
		crit_cleanup();
		exit(EXIT_FAILURE);
	}
}

void yyerror (const char *msg) {
    /* ignores the string "syntax error," */
	fprintf(stderr, "Syntax error [line %d]: %s\n", yylineno, &msg[14]);
}

void type_error (const char *msg, ...) {
	va_list va;

	va_start(va, msg);
	fprintf(stderr, "Semantic error [line %d]: ", yylineno);
    vfprintf(stderr, msg, va);
    fprintf(stderr, "\n");
    va_end(va);
}

const char * verbose_type(Type t ) {
    char * res = "Array of ";
    if (t == typeInteger)
        return "Integer";
    else if (t == typeReal)
        return "Real";
    else if (t == typeBoolean)
        return "Boolean";
    else if (t == typeChar)
        return "Char";
    else if (t == typeVoid)
        return "Void";
    else if ((t->kind == TYPE_ARRAY) || (t->kind == TYPE_IARRAY)) {
        if (t->refType->kind == TYPE_ARRAY)
            return "Multidimensional Array";
        else {       
            strcat(res, verbose_type(t->refType));
            strcat(res, "s");
            return res;
        }
    }
}




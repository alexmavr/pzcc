/*
 * .: >> error.h
 *
 * ?: Aristoteles Panaras "ale1ster"
 * @: Mon 03 Jun 2013 08:57:09 PM EEST
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>
#include "general.h"
#include "error.h"

//Wrapper for interfacing with lexer's error routine.
void yyerror (const char *msg) {
	/* reformats the string "syntax error," */
	my_error(ERR_LV_ERR, "Syntax error: %s", &msg[14]);
}

//General error reporting function.
void my_error (error_lv level, const char *msg, ...) {
	va_list va;

	va_start(va, msg);
	fprintf(stderr, "[%s:%d]: ", filename, yylineno);
	switch (level) {
		case ERR_LV_WARN:
			fprintf(stderr, "WARNING: ");
			break;
		case ERR_LV_ERR:
			fprintf(stderr, "ERROR: ");
			break;
		case ERR_LV_CRIT:
			fprintf(stderr, "CRITICAL: ");
			break;
		case ERR_LV_INTERN:
			fprintf(stderr, "INTERNAL: ");
			break;
		default:
			fprintf(stderr, "My mind just exploded\n");
			exit(EXIT_FAILURE);
	}
	vfprintf(stderr, msg, va);
	fprintf(stderr, "\n");
	va_end(va);
	if ((level == ERR_LV_CRIT) || (level == ERR_LV_INTERN)) {
		cleanup();
		exit(EXIT_FAILURE);
	}
}

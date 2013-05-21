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
#include "parser.h"

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
            res = "Multidimensional Array";
        else {       
            strcat(res, verbose_type(t->refType));
            strcat(res, "s");
        }
    }
    return res;
}


RepReal eval_real_op(RepReal left, RepReal right, const char * op) {
    RepReal res = 0.0;
    if (!strcmp(op, "*")) 
        res = left * right;
    else if (!strcmp(op, "/")) 
        res = left / right;
    else if (!strcmp(op, "+")) 
        res = (RepReal) left + (RepReal) right;
    else if (!strcmp(op, "-")) 
        res = left - right;
    else if (!strcmp(op, "%") || !strcmp(op, "MOD"))
        type_error("Type mismatch on constant \"%s\" operator", op);
    return res;
}

RepInteger eval_int_op(RepInteger left, RepInteger right, const char * op) {
    RepInteger res = 0;
    if (!strcmp(op, "*")) 
        res = left * right;
    else if (!strcmp(op, "/")) 
        res = left / right;
    else if (!strcmp(op, "+")) 
        res = left + right;
    else if (!strcmp(op, "-")) 
        res = left - right;
    else if (!strcmp(op, "%") || !strcmp(op, "MOD"))
        res = left % right;
    return res;
}

void const_binop_semantics(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res ) {
    if ((left->type == typeInteger) && (right->type == typeReal)) {
        res->type = typeReal;
        res->value.r = eval_real_op((RepReal) left->value.i, right->value.r, op);

    } else if ((left->type == typeReal) && (right->type == typeInteger)) {
        res->type = typeReal;
        res->value.r = eval_real_op(left->value.r, (RepReal) right->value.i, op);

    } else if ((left->type == typeInteger) && (right->type == typeInteger)) {
        res->type = typeInteger;
        res->value.i = eval_int_op(left->value.i, right->value.i, op);
    } else {
        type_error("Type mismatch on \"%s\" operator", op);
    }   
}


void array_index_check(struct ast_node * _) {
    if (_->type != typeInteger)
        type_error("Array index is %s instead of Integer", verbose_type(_->type));
    else if (_->value.i <= 0) 
        type_error("Array index is negative");
}


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
#include "symbol/general.h"

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
    char * res = new(35 * sizeof(char));
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
            strcpy(res, verbose_type(t->refType));
            strcat(res, " Array");
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
        type_error("Cannot perform \"%s\" on Reals", op);
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

void eval_const_binop(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res) {
    if ((left->type == typeInteger) && (right->type == typeReal)) {
        res->type = typeReal;
        res->value.r = eval_real_op((RepReal) left->value.i, right->value.r, op);

    } else if ((left->type == typeReal) && (right->type == typeInteger)) {
        res->type = typeReal;
        res->value.r = eval_real_op(left->value.r, (RepReal) right->value.i, op);

    } else if ((left->type == typeChar) && (right->type == typeReal)) {
        res->type = typeReal;
        res->value.r = eval_real_op((RepReal) left->value.c, right->value.r, op);

    } else if ((left->type == typeReal) && (right->type == typeChar)) {
        res->type = typeReal;
        res->value.r = eval_real_op(left->value.r, (RepReal) right->value.c, op);

    } else if ((left->type == typeReal) && (right->type == typeReal)) {
        res->type = typeReal;
        res->value.r = eval_real_op(left->value.r, right->value.r, op);

    } else if ((left->type == typeInteger) && (right->type == typeInteger)) {
        res->type = typeInteger;
        res->value.i = eval_int_op(left->value.i, right->value.i, op);

    } else if ((left->type == typeChar) && (right->type == typeInteger)) {
        res->type = typeInteger;
        res->value.i = eval_int_op((RepInteger) left->value.c, right->value.i, op);

    } else if ((left->type == typeInteger) && (right->type == typeChar)) {
        res->type = typeInteger;
        res->value.i = eval_int_op(left->value.i, (RepInteger) right->value.c, op);

    } else if ((left->type == typeChar) && (right->type == typeChar)) {
        res->type = typeInteger;
        res->value.i = eval_int_op((RepInteger) left->value.c, (RepInteger) right->value.c, op);

    } else {
        type_error("Type mismatch on \"%s\" constant operator", op);
    }   
}


void array_index_check(struct ast_node * _) {
    if (!compat_types(typeInteger, _->type))
        type_error("Array index cannot be %s" , verbose_type(_->type));
    else if (_->value.i <= 0) 
        type_error("Array index cannot be negative");
}

/* Returns the number of dimensions of the type t 
 * If not an array, returns 0 */
int array_dimensions(Type t) {
    Type current = t;
    int dimensions = 0;
    
    while ((current->kind == TYPE_ARRAY) || (current->kind == TYPE_IARRAY)) {
        current = current->refType;
        dimensions++;
    }
    return dimensions;
}

/* Calculates the type of the n-th dimension of the array */
Type n_dimension_type(Type t, int n) {
    Type current = t;
    int m = n;

    while ((m > 0) && ((current->kind == TYPE_ARRAY) || (current->kind == TYPE_IARRAY))) {
        t = t->refType;
        m--;
    }
    return t;
}

/* Return true if t2 can be cast to t1 */
bool compat_types(Type t1, Type t2) {
    bool res = false;
    while (((t1->kind == TYPE_ARRAY) && (t2->kind == TYPE_ARRAY)) \
        || ((t1->kind == TYPE_IARRAY) && (t2->kind == TYPE_IARRAY))) {
        /* is the grouping correct ? */
        t1 = t1->refType;
        t2 = t2->refType;
    }
    if ((t1 == t2)
    || ((t1 == typeInteger) && (t2 == typeChar)) \
    || ((t1 == typeReal) && (t2 == typeInteger)) \
    || ((t1 == typeReal) && (t2 == typeChar)) \
    || ((t1 == typeChar) && (t2 == typeInteger))) \
            res = true;
    return res;
}


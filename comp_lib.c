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
#include <assert.h>
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

const char * verbose_type (Type t) {
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
    else if (t->kind >= TYPE_ARRAY) {
        if (t->refType->kind == TYPE_ARRAY)
            res = "Multidimensional Array";
        else {       
            strcpy(res, verbose_type(t->refType));
            strcat(res, " Array");
        }
    }
    return res;
}


void eval_real_op (RepReal left, RepReal right, const char * op, struct ast_node * res) {
    if (!strcmp(op, "*")) {
        res->type = typeReal;
        res->value.r = left * right;
    } else if (!strcmp(op, "/")) {
        res->type = typeReal;
        res->value.r = left / right;
    } else if (!strcmp(op, "+")) {
        res->type = typeReal;
        res->value.r = left + right;
    } else if (!strcmp(op, "-")) {
        res->type = typeReal;
        res->value.r = left - right;
    } else if (!strcmp(op, "<")) {
        res->type = typeBoolean;
        res->value.b = left < right;
    } else if (!strcmp(op, ">")) {
        res->type = typeBoolean;
        res->value.b = left < right;
    } else if (!strcmp(op, ">=")) {
        res->type = typeBoolean;
        res->value.b = left >= right;
    } else if (!strcmp(op, "<=")) {
        res->type = typeBoolean;
        res->value.b = left <= right;
    } else if (!strcmp(op, "==")) {
        res->type = typeBoolean;
        res->value.b = left == right;
    } else if (!strcmp(op, "!=")) {
        res->type = typeBoolean;
        res->value.b = left != right;
    } else
        type_error("Cannot perform \"%s\" between Reals", op);
}

void eval_int_op (RepInteger left, RepInteger right, const char * op, struct ast_node * res) {
    if (!strcmp(op, "*")) {
        res->type = typeInteger;
        res->value.i = left * right;
    } else if (!strcmp(op, "/")) {
        res->type = typeInteger;
        res->value.i = left / right;
    } else if (!strcmp(op, "+")) {
        res->type = typeInteger;
        res->value.i = left + right;
    } else if (!strcmp(op, "-")) {
        res->type = typeInteger;
        res->value.i = left - right;
    } else if (!strcmp(op, "%") || !strcmp(op, "MOD")) {
        res->type = typeInteger;
        res->value.i = left % right;
    } else if (!strcmp(op, "<")) {
        res->type = typeBoolean;
        res->value.b = left < right;
    } else if (!strcmp(op, ">")) {
        res->type = typeBoolean;
        res->value.b = left > right;
    } else if (!strcmp(op, "<=")) {
        res->type = typeBoolean;
        res->value.b = left <= right;
    } else if (!strcmp(op, ">=")) {
        res->type = typeBoolean;
        res->value.b = left >= right;
    } else if (!strcmp(op, "==")) {
        res->type = typeBoolean;
        res->value.b = left == right;
    } else if (!strcmp(op, "!=")) {
        res->type = typeBoolean;
        res->value.b = left != right;
    } else 
        type_error("Cannot perform \"%s\" between Integers", op);
}


void eval_bool_op (RepBoolean left, RepBoolean right, const char * op, struct ast_node * res) {
    res->type = typeBoolean;;
    if (!strcmp(op, "==")) 
        res->value.b = left == right;
    else if (!strcmp(op, "!=")) 
        res->value.b = left != right;
    else if (!strcmp(op, "&&") || !strcmp(op,"and")) 
        res->value.b = left && right;
    else if (!strcmp(op, "||") || !strcmp(op,"or")) 
        res->value.b = left || right;
    else 
        type_error("Cannot perform \"%s\" between Booleans", op);
}

void eval_const_unop(struct ast_node * operand, const char * op, struct ast_node * res) {
    if (!strcmp(op, "+")) {
        if (operand->type == typeInteger) {
            res->type = typeInteger;
            res->value.i = operand->value.i;
        } else if (operand->type == typeReal) {
            res->type = typeReal;
            res->value.r = operand->value.r;
        } else
            type_error("Cannot perform \"%s\" on %s", op, verbose_type(operand->type));
    } else if (!strcmp(op, "-")) {
        if (operand->type == typeInteger) {
            res->type = typeInteger;
            res->value.i = -(operand->value.i);
        } else if (operand->type == typeReal) {
            res->type = typeReal;
            res->value.r = -(operand->value.r);
        } else
            type_error("Cannot perform \"%s\" on %s", op, verbose_type(operand->type));
    } else if (!strcmp(op, "!") || !strcmp(op, "not")) {
        if (operand->type == typeBoolean) {
            res->type = typeBoolean;
            res->value.b = !(operand->value.b);
        } else
            type_error("Cannot perform \"%s\" on %s", op, verbose_type(operand->type));
    } else 
        assert(INTERNAL_ERROR);
}

void unop_IR(struct ast_node * operand, const char * op, struct ast_node * res) {
    if (!strcmp(op, "+")) {
        if (operand->type == typeInteger) {
            res->type = typeInteger;
            // IR placeholder
        } else if (operand->type == typeReal) {
            res->type = typeReal;
            // IR placeholder
        } else
            type_error("Cannot perform \"%s\" on %s", op, verbose_type(operand->type));
    } else if (!strcmp(op, "-")) {
        if (operand->type == typeInteger) {
            res->type = typeInteger;
            // IR placeholder
        } else if (operand->type == typeReal) {
            res->type = typeReal;
            // IR placeholder
        } else
            type_error("Cannot perform \"%s\" on %s", op, verbose_type(operand->type));
    } else if (!strcmp(op, "!") || !strcmp(op, "not")) {
        if (operand->type == typeBoolean) {
            res->type = typeBoolean;
            // IR placeholder
        } else
            type_error("Cannot perform \"%s\" on %s", op, verbose_type(operand->type));
    } else 
        assert(INTERNAL_ERROR);
}

void eval_const_binop(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res) {
    
    if ((left->type == typeInteger) && (right->type == typeReal)) {
        eval_real_op((RepReal) left->value.i, right->value.r, op, res);

    } else if ((left->type == typeReal) && (right->type == typeInteger)) {
        eval_real_op(left->value.r, (RepReal) right->value.i, op, res);

    } else if ((left->type == typeChar) && (right->type == typeReal)) {
        eval_real_op((RepReal) left->value.c, right->value.r, op, res);

    } else if ((left->type == typeReal) && (right->type == typeChar)) {
        eval_real_op(left->value.r, (RepReal) right->value.c, op, res);

    } else if ((left->type == typeReal) && (right->type == typeReal)) {
        eval_real_op(left->value.r, right->value.r, op, res);

    } else if ((left->type == typeInteger) && (right->type == typeInteger)) {
        eval_int_op(left->value.i, right->value.i, op, res);

    } else if ((left->type == typeChar) && (right->type == typeInteger)) {
        eval_int_op((RepInteger) left->value.c, right->value.i, op, res);

    } else if ((left->type == typeInteger) && (right->type == typeChar)) {
        eval_int_op(left->value.i, (RepInteger) right->value.c, op, res);

    } else if ((left->type == typeChar) && (right->type == typeChar)) {
        eval_int_op((RepInteger) left->value.c, (RepInteger) right->value.c, op, res);

    } else if ((left->type == typeBoolean) && (right->type == typeBoolean)) {
        eval_bool_op(left->value.b, right->value.b, op, res);

    } else {
        type_error("Type mismatch on \"%s\" operator between %s and %s", \
                op, verbose_type(left->type), verbose_type(right->type));
    }   
}

/* Expr Binops 
 * Create IR for casting each */
void binop_IR(struct ast_node * left, struct ast_node * right, const char * op, struct ast_node * res) {
    if ((left->type == typeInteger) && (right->type == typeReal)) {
        res->type = binop_type_check(op, typeReal);

    } else if ((left->type == typeReal) && (right->type == typeInteger)) {
        res->type = binop_type_check(op, typeReal);

    } else if ((left->type == typeChar) && (right->type == typeReal)) {
        res->type = binop_type_check(op, typeReal);

    } else if ((left->type == typeReal) && (right->type == typeChar)) {
        res->type = binop_type_check(op, typeReal);

    } else if ((left->type == typeReal) && (right->type == typeReal)) {
        res->type = binop_type_check(op, typeReal);

    } else if ((left->type == typeInteger) && (right->type == typeInteger)) {
        res->type = binop_type_check(op, typeInteger);

    } else if ((left->type == typeChar) && (right->type == typeInteger)) {
        res->type = binop_type_check(op, typeInteger);

    } else if ((left->type == typeInteger) && (right->type == typeChar)) {
        res->type = binop_type_check(op, typeInteger);

    } else if ((left->type == typeChar) && (right->type == typeChar)) {
        res->type = binop_type_check(op, typeInteger);

    } else if ((left->type == typeBoolean) && (right->type == typeBoolean)) {
        res->type = binop_type_check(op, typeBoolean);

    } else {
        type_error("Type mismatch on \"%s\" operator between %s and %s", \
                op, verbose_type(left->type), verbose_type(right->type));
    }   
}

Type binop_type_check(const char * op, Type t) {
    Type res = NULL;

    if (t == typeReal) {
        if ((!strcmp(op, "*")) || (!strcmp(op, "/")) || (!strcmp(op, "+")) \
                                                   || (!strcmp(op, "-")))
            res = typeReal;
        else if ((!strcmp(op, "<")) || (!strcmp(op, ">")) || (!strcmp(op, ">=")) \
               || (!strcmp(op, "<=")) || (!strcmp(op, "!=")))
            res = typeBoolean;
        else 
            type_error("Cannot perform \"%s\" between Reals", op);
    } else if (t == typeInteger) {
        if ((!strcmp(op, "*")) || (!strcmp(op, "/")) || (!strcmp(op, "+"))  \
          || (!strcmp(op, "-")) || (!strcmp(op, "%") || !strcmp(op, "MOD")))
            res = typeInteger;
        else if ((!strcmp(op, "<")) || (!strcmp(op, ">")) || (!strcmp(op, "<="))
          || (!strcmp(op, ">=")) || (!strcmp(op, "==")) || (!strcmp(op, "!=")))
            res = typeBoolean;
        else 
            type_error("Cannot perform \"%s\" between Integers", op);
    } else if (t == typeBoolean) {
        if ((!strcmp(op, "==")) || (!strcmp(op, "!=")) 
        || (!strcmp(op, "&&")) || (!strcmp(op,"and")) 
        || (!strcmp(op, "||")) || (!strcmp(op,"or")))
            res = typeBoolean;
        else
            type_error("Cannot perform \"%s\" between Booleans", op);
    } else 
        ; // Internal error

    return res;
}

int array_index_check(struct ast_node * _) {
    int ret = 0;
    if (!compat_types(typeInteger, _->type)) {
        type_error("Array index cannot be %s" , verbose_type(_->type));
        ret = 1;
    }
    else if (_->value.i <= 0) {
        type_error("Array index cannot be negative");
        ret = 1;
    }
    return ret;
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
    while ((t1->kind >= TYPE_ARRAY) && (t2->kind >= TYPE_ARRAY)) {
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

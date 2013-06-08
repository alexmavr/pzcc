/*
 * .: >> ir.h
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Tue 04 Jun 2013 10:52:43 AM EEST
 *
 */
#include <stdlib.h>
#include "ir.h"

LLVMBuilderRef builder;
LLVMModuleRef module;

struct list_node * add_to_list(struct list_node * head, LLVMValueRef val) {
    struct list_node * newnode = (struct list_node *) new(sizeof(struct list_node));

    newnode->Valref = val;
    if (head == NULL) {
        newnode->next = NULL;
    } else {
        head->next = newnode;
    }
    return newnode;
}

LLVMTypeRef type_to_llvm(Type t) {
	LLVMTypeRef res;
	switch (t->kind) {
		case TYPE_VOID:
			res = LLVMVoidType();
			break;
		case TYPE_INTEGER:
			res = LLVMInt32Type();
			break;
		case TYPE_REAL:
			res = LLVMDoubleType();
			break;
		case TYPE_BOOLEAN:
			res = LLVMInt1Type();
			break;
		case TYPE_CHAR:
			res = LLVMInt8Type();
			break;
		default:
			res = NULL;
	}
	return res;
}

LLVMValueRef cast_compat(Type dest, Type src, LLVMValueRef src_val) {
    LLVMValueRef res;
    if ((dest == typeReal) && (src == typeInteger)) {
         res = LLVMBuildCast(builder, LLVMSIToFP, src_val, LLVMDoubleType(), "casttmp");
    } else if ((dest == typeReal) && (src == typeChar)) {
        res = LLVMBuildCast(builder, LLVMUIToFP, src_val, LLVMDoubleType(), "casttmp");
    } else if ((dest == typeChar) && (src == typeInteger)) {
        /* Take the Highest order bit (8th bit) of the integer by shifting right 7 times
         * and truncating to 1 bit.
         * Using the select operator, use that value to determine the sign.
         * If that bit is 1, the integer was negative and a Neg operation is performed
         * If it was 0, the integer was positive.
         * Finally, truncate the corrent integer to 8 bits */

        LLVMValueRef shift_amm = LLVMConstInt(LLVMInt8Type(), 7, false);
        LLVMValueRef imv = LLVMBuildLShr(builder, src_val, shift_amm, "lshrtmp"); 
        imv = LLVMBuildTrunc(builder, imv, LLVMInt1Type(), "trunctmp"); // 1-bit condition
        LLVMValueRef neg = LLVMBuildNeg(builder, src_val, "negtmp"); // negative branch
        imv = LLVMBuildSelect(builder, imv, neg, src_val, "selecttmp");
        res = LLVMBuildTrunc(builder, imv, LLVMInt8Type(), "trunctmp");

    } else if ((dest == typeInteger) && (src == typeChar)) {
        res = LLVMBuildZExt(builder, src_val, LLVMInt32Type(), "zexttmp");
    } else {
        res = src_val;
    }
    return res;
}

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
        /* Our problem: negative numbers are in two's complement form and we need their positive value
         * We could either: 
         * a) set the highest order bit to 0 and ignore the rest, claiming this as default behavior for int-to-char conversion
         * b) check the highest order bit for the sign and if it is 1, 
         * perform a BuildNeg,BuildSub or BuildXor on the number,
         * otherwise leave it as is. This requires a branch instruction.
         * The code below performs (a), but I think we should do (b) instead.
         *
         * Maybe postpone it until we start doing branches?
         */
        LLVMValueRef imv = LLVMBuildTrunc(builder, src_val, LLVMIntType(7), "trunctmp");
        res = LLVMBuildZExt(builder, imv, LLVMInt8Type(), "zexttmp");
    } else if ((dest == typeInteger) && (src == typeChar)) {
        res = LLVMBuildZExt(builder, src_val, LLVMInt32Type(), "zexttmp");
    } else {
        res = src_val;
    }
    return res;
}

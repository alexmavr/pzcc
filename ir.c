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
//		LLVMValueRef mask = LLVMConstInt(LLVMInt32Type(), 255, false);
//		res = LLVMBuildAnd(builder, src_val, mask, "andtmp" );
//		res = LLVMBuildTrunc(builder, src_val, LLVMInt8Type(), "trunctmp");
		// problems with trunc	::	Above is try 1.
//		LLVMValueRef mask = LLVMConstInt(LLVMInt32Type(), 256, false);
//		res = LLVMBuildURem(builder, src_val, mask, "trunctmp");
		// problems again	::	This is the second try.
		LLVMValueRef mask = LLVMConstInt(LLVMInt32Type(), 256, false); 
		LLVMValueRef imv = LLVMBuildURem(builder, src_val, mask, "uremtmp");
		imv = LLVMBuildSub(builder, mask, imv, "subtmp");
        res = LLVMBuildTrunc(builder, imv, LLVMInt8Type(), "trunctmp");
    } else if ((dest == typeInteger) && (src == typeChar)) {
        res = LLVMBuildZExt(builder, src_val, LLVMInt32Type(), "zexttmp");
    } else {
        res = src_val;
    }
    return res;
}

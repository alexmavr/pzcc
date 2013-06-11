#include <stdio.h>
#include <stdlib.h>
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/Transforms/Scalar.h>

int main (void) {
    LLVMModuleRef module = LLVMModuleCreateWithName("kal");
    LLVMBuilderRef builder = LLVMCreateBuilder();
//	LLVMInitializeNativeTarget();

	LLVMTypeRef funcType = LLVMFunctionType(LLVMVoidType(), NULL, 0, 0);
	LLVMValueRef func = LLVMAddFunction(module, "main", funcType);
	LLVMSetLinkage(func, LLVMExternalLinkage);
	LLVMBasicBlockRef block = LLVMAppendBasicBlock(func, "entry");
	LLVMPositionBuilderAtEnd(builder, block);

	LLVMValueRef cond = LLVMBuildICmp(builder, LLVMIntNE, LLVMConstInt(LLVMInt32Type(), 2, 0), LLVMConstInt(LLVMInt32Type(), 1, 0), "ifcond");

	LLVMValueRef function = LLVMGetBasicBlockParent(LLVMGetEntryBasicBlock(builder));	//TODO: This must be wrong
	//LLVMValueRef function = LLVMBasicBlockAsValue(LLVMGetPreviousBasicBlock(LLVMGetInsertBlock(builder)));
	// 2. Generate new blocks for cases.
	LLVMBasicBlockRef then_ref = LLVMAppendBasicBlock(function, "then");
	LLVMBasicBlockRef else_ref = LLVMAppendBasicBlock(function, "else");
	LLVMBasicBlockRef merge_ref = LLVMAppendBasicBlock(function, "ifmerge");

	// 3. Branch conditionally on then or else.
	LLVMBuildCondBr(builder, cond, then_ref, else_ref);

	// 4. Build then branch prologue.
	LLVMPositionBuilderAtEnd(builder, then_ref);

	// 5. Connect then branch to merge block.
	LLVMBuildBr(builder, then_ref);

	LLVMBuildXor(builder, LLVMGetUndef(LLVMInt32Type()), LLVMGetUndef(LLVMInt32Type()), "subtmp");

	then_ref = LLVMGetInsertBlock(builder);

	// 6. Build else branch prologue.
	LLVMPositionBuilderAtEnd(builder, else_ref);

	// 7. Connect else branch to merge block.
	LLVMBuildBr(builder, merge_ref);

	LLVMBuildXor(builder, LLVMGetUndef(LLVMInt32Type()), LLVMGetUndef(LLVMInt32Type()), "subtmp");

	else_ref = LLVMGetInsertBlock(builder);
	// 8. Position ourselves after the merge block.
	LLVMPositionBuilderAtEnd(builder, merge_ref);
	// 9. Build the phi node.
	LLVMValueRef phi = LLVMBuildPhi(builder, LLVMDoubleType(), "phi");
	// 10. Add incoming edges.
	LLVMValueRef ah_t = LLVMBasicBlockAsValue(then_ref);
	LLVMAddIncoming(phi, &ah_t, &then_ref, 1);
	ah_t = LLVMBasicBlockAsValue(else_ref);
	LLVMAddIncoming(phi, &ah_t, &else_ref, 1);

	LLVMDumpModule(module);
	LLVMDisposeBuilder(builder);
	LLVMDisposeModule(module);

	return 0;
}

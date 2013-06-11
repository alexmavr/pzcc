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

	LLVMValueRef owning_block = LLVMGetBasicBlockParent(LLVMGetInsertBlock(builder));	//TODO: WRONG??
	//LLVMValueRef owning_block = LLVMBasicBlockAsValue(LLVMGetPreviousBasicBlock(LLVMGetInsertBlock(builder)));
	// 2. Generate new blocks for cases.
	LLVMBasicBlockRef then_ref = LLVMAppendBasicBlock(owning_block, "then");
	LLVMBasicBlockRef else_ref = LLVMAppendBasicBlock(owning_block, "else");
	LLVMBasicBlockRef merge_ref = LLVMAppendBasicBlock(owning_block, "ifmerge");

	// 3. Branch conditionally on then or else.
	LLVMBuildCondBr(builder, cond, then_ref, else_ref);

	// 4. Build then branch prologue.
	LLVMPositionBuilderAtEnd(builder, then_ref);

	LLVMValueRef hi1 = LLVMBuildXor(builder, LLVMGetUndef(LLVMInt32Type()), LLVMGetUndef(LLVMInt32Type()), "subtmp");

	// 5. Connect then branch to merge block.
	LLVMBuildBr(builder, merge_ref);

	then_ref = LLVMGetInsertBlock(builder);

	// 6. Build else branch prologue.
	LLVMPositionBuilderAtEnd(builder, else_ref);

	LLVMValueRef hi2 = LLVMBuildXor(builder, LLVMGetUndef(LLVMInt32Type()), LLVMGetUndef(LLVMInt32Type()), "subtmp2");

	// 7. Connect else branch to merge block.
	LLVMBuildBr(builder, merge_ref);

	else_ref = LLVMGetInsertBlock(builder);
	// 8. Position ourselves after the merge block.
	LLVMPositionBuilderAtEnd(builder, merge_ref);
	// 9. Build the phi node.
//	LLVMValueRef phi = LLVMBuildPhi(builder, LLVMDoubleType(), "phi");
	// 10. Add incoming edges.
//	LLVMAddIncoming(phi, &hi1, &then_ref, 1);
//	LLVMAddIncoming(phi, &hi2, &else_ref, 1);

	LLVMDumpModule(module);
	LLVMDisposeBuilder(builder);
	LLVMDisposeModule(module);

	return 0;
}

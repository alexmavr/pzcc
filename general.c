/*
 * .: >> general.h
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * +: Nikolaos S. Papaspyrou (nickie@softlab.ntua.gr)
 * @: Mon 03 Jun 2013 08:35:52 PM EEST
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <llvm-c/Target.h>
#include <llvm-c/Core.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/Transforms/Scalar.h>
#include "semantic.h"
#include "general.h"
#include "error.h"


//Cleanup hook.
void cleanup (void) {
	;
}

void *new (size_t size) {
	void *result = malloc(size);

	if (result == NULL) {
		my_error(ERR_LV_CRIT, "\rOut of memory");
	}
	return result;
}

void delete (void *p) {
	if (p != NULL) {
		free(p);
	}
}

//Input filename.
char *filename = "stdin";
extern FILE *yyin;

//Entry point.
int main (int argc, char **argv) {
	//Open input file (if none exists, it uses the default - stdin).
	if (argc > 1) {
		filename=argv[1];
		yyin = fopen(filename, "r");
		if (yyin == NULL) {
			my_error(ERR_LV_CRIT, "Cannot open input file %s", filename);
			exit(EXIT_FAILURE);
		}
	}
    
    module = LLVMModuleCreateWithName("pzc");
    builder = LLVMCreateBuilder();
    LLVMInitializeNativeTarget();

    LLVMPassManagerRef pass_manager = LLVMCreateFunctionPassManagerForModule(module);
    LLVMAddPromoteMemoryToRegisterPass(pass_manager);
    LLVMAddInstructionCombiningPass(pass_manager);
    LLVMAddReassociatePass(pass_manager);
    LLVMAddGVNPass(pass_manager);
    LLVMAddCFGSimplificationPass(pass_manager);
    LLVMInitializeFunctionPassManager(pass_manager);

	yyparse();
	//closeScope();

    LLVMDumpModule(module);
    LLVMDisposePassManager(pass_manager);
    LLVMDisposeBuilder(builder);
    LLVMDisposeModule(module);

	printf("Parsing Complete\n");

	return 0;
}

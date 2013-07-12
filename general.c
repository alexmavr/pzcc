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
#include "error.h"
#include "general.h"
#include "ir.h"
#include "termopts.h"

//Cleanup hook.
void cleanup (void) {
	;
}

void *new (size_t size) {
	void *result = malloc(size);

	if (result == NULL) {
		my_error(ERR_LV_CRIT, "Out of memory");
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

struct options_t our_options = { .in_file = NULL, .output_type = OUT_NONE, .output_is_stdout = false, .output_filename = NULL, .opt_flag = 0 };

//Entry point.
int main (int argc, char **argv) {

	//Parse command-line options.
	parse_term_options(argc, argv);
	yyin = our_options.in_file;

fprintf(stderr, "Line %d\n", __LINE__);

	module = LLVMModuleCreateWithName("pzcc");

fprintf(stderr, "Line %d\n", __LINE__);

	builder = LLVMCreateBuilder();

fprintf(stderr, "Line %d\n", __LINE__);

	LLVMInitializeNativeTarget();

fprintf(stderr, "Line %d\n", __LINE__);


/*
	LLVMPassManagerRef pass_manager = LLVMCreateFunctionPassManagerForModule(module);
	LLVMAddPromoteMemoryToRegisterPass(pass_manager);
	LLVMAddInstructionCombiningPass(pass_manager);
	LLVMAddReassociatePass(pass_manager);
	LLVMAddGVNPass(pass_manager);
	LLVMAddCFGSimplificationPass(pass_manager);
	LLVMInitializeFunctionPassManager(pass_manager);
*/

	yyparse();
//	closeScope();

	if (our_options.opt_flag == true) {
		//...
fprintf(stderr, "TODO: Must implement optimizations\n");
		//...
	}

	switch (our_options.output_type) {
		case OUT_IR:
//*
			if (our_options.output_is_stdout == false) {
				char *err_msg = NULL;
				if (LLVMPrintModuleToFile(module, our_options.output_filename, &err_msg)) {
					my_error(ERR_LV_INTERN, "LLVM module not dumped correctly: %s", err_msg);
					LLVMDisposeMessage(err_msg);
				}
			} else {
				LLVMDumpModule(module);
			}
//*/
//			LLVMDumpModule(module);
			break;
		case OUT_ASM:
			//...
fprintf(stderr, "TODO: Must implement assembly output\n");
			//...
			break;
		case OUT_EXEC:
			//...
fprintf(stderr, "TODO: Must implement executable output (assembler - linker)\n");
			//...
			break;
		default:
			my_error(ERR_LV_INTERN, "Unknown output file type detected");
	}

//	LLVMDisposePassManager(pass_manager);
	LLVMDisposeBuilder(builder);
	LLVMDisposeModule(module);

	printf("Parsing Complete\n");

	return 0;
}

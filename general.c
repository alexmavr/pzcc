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
#include <unistd.h>
#include <sys/wait.h>
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

struct options_t our_options = { .in_file = NULL, .output_type = OUT_NONE, .output_is_stdout = false, .output_filename = NULL, .opt_flags = NULL, .llc_flags = NULL, .opt_flag = 0 };

//IR dump method.
static void dump_ir (char *outfile) {
	if (our_options.output_is_stdout == false) {
		char *err_msg = NULL;
		if (LLVMPrintModuleToFile(module, outfile, &err_msg)) {
			my_error(ERR_LV_INTERN, "LLVM module not dumped correctly: %s", err_msg);
			LLVMDisposeMessage(err_msg);
		}
	} else {
		LLVMDumpModule(module);
	}
}

//Entry point.
int main (int argc, char **argv) {
	char tmp_f[L_tmpnam];
	int ret = 0;

	//Parse command-line options.
	parse_term_options(argc, argv);
	yyin = our_options.in_file;

	module = LLVMModuleCreateWithName("pzcc");
	builder = LLVMCreateBuilder();
	LLVMInitializeNativeTarget();

	initSymbolTable(256);
    openScope();

    generate_external_definitions(); // declares external function prototypes

	yyparse();

	//Dump IR to intermediate file.
	dump_ir(our_options.tmp_filename);

	//Optimizer pass on dumped IR.
	if (our_options.opt_flag == true) {
		pid_t opted = fork();
		if (opted == 0) {
			if (our_options.opt_flags == NULL) {
				execlp("opt", "opt", "-S", "-std-compile-opts", "-o", our_options.tmp_filename, our_options.tmp_filename, (char *)NULL);
			} else {
				execlp("opt", "opt", "-S", "-std-compile-opts", our_options.opt_flags, "-o", our_options.tmp_filename, our_options.tmp_filename, (char *)NULL);
			}
		} else {
			size_t guard = 0;
			while ((waitpid(opted, NULL, 0) != opted) && (guard < 100)) { guard++; }
		}
	}

	switch (our_options.output_type) {
		//If IR was requested, simply copy the temp file to the output file.
		case OUT_IR:
			//...
			dump_ir(our_options.output_filename);
			//...
			break;
		case OUT_ASM:
			if (tmpnam(tmp_f) == NULL) {
				my_error(ERR_LV_ERR, "Could not open temporary file");
				goto err_end;
			}
fprintf(stderr, "TMPNAME is %s\n", tmp_f);
			//Create command-line call for llc and its arguments.
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

	LLVMDisposeBuilder(builder);
	LLVMDisposeModule(module);

	printf("Parsing Complete\n");

	goto nrm_end;
err_end:
	ret = 1;
nrm_end:
	return ret;
}

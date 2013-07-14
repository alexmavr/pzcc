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

struct options_t our_options = { .in_file = NULL, .output_type = OUT_NONE, .output_is_stdout = false, .output_filename = NULL, .llvmopt_flags = NULL, .llvmllc_flags = NULL, .opt_flag = 0 };

//LLVM IR dump method.
static void dump_ir (char *outfile) {
	if (outfile != NULL) {
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
	pid_t tmp_pid;
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
	//TODO: what goes on here?? line78:openScope() -> external function definitions -> close general scope where?

	//Dump IR to intermediate file.
	dump_ir(our_options.tmp_filename);

	//Optimizer pass on dumped IR.
	if (our_options.opt_flag == true) {
		tmp_pid = fork();
		if (tmp_pid == 0) {
			if (our_options.llvmopt_flags == NULL) {
				execlp("opt", "opt", "-S", "-std-compile-opts", "-o", our_options.tmp_filename, our_options.tmp_filename, (char *)NULL);
			} else {
				execlp("opt", "opt", "-S", "-std-compile-opts", our_options.llvmopt_flags, "-o", our_options.tmp_filename, our_options.tmp_filename, (char *)NULL);
			}
		} else if (tmp_pid < 0) {
			my_error(ERR_LV_INTERN, "fork() call failed");
		} else {
			size_t guard = 0;
			while ((waitpid(tmp_pid, NULL, 0) != tmp_pid) && (guard < 100)) { guard++; }
		}
	}

	switch (our_options.output_type) {
		//If IR was requested, simply copy the temp file to the output file.
		case OUT_IR:
			if (rename(our_options.tmp_filename, our_options.output_filename) != 0) {
				tmp_pid = fork();
				if (tmp_pid == 0) {
					execlp("mv", "mv", our_options.tmp_filename, our_options.output_filename, (char *)NULL);
				} else if (tmp_pid < 0) {
					my_error(ERR_LV_INTERN, "fork() call failed");
				} else {
					size_t guard = 0;
					while ((waitpid(tmp_pid, NULL, 0) != tmp_pid) && (guard < 100)) { guard++; }
				}
			}
			break;
		//If assembly output was requested, generate and dump it to the output file.
		case OUT_ASM:
			tmp_pid = fork();
			if (tmp_pid == 0) {
				switch (our_options.opt_flag) {
					case true	:
						if (our_options.output_filename != NULL)
							execlp("llc", "llc", "-filetype=asm", "-O3", "-o", our_options.output_filename, our_options.tmp_filename, (char *)NULL);
						else
							execlp("llc", "llc", "-filetype=asm", "-O3", our_options.tmp_filename, (char *)NULL);
						break;
					case false	:
						if (our_options.output_filename != NULL)
							execlp("llc", "llc", "-filetype=asm", "-o", our_options.output_filename, our_options.tmp_filename, (char *)NULL);
						else
							execlp("llc", "llc", "-filetype=asm", our_options.tmp_filename, (char *)NULL);
						break;
					default		:
						my_error(ERR_LV_INTERN, "Invalid value in boolean variable");
						break;
				}
			} else if (tmp_pid < 0) {
				my_error(ERR_LV_INTERN, "fork() call failed");
			} else {
				size_t guard = 0;
				while ((waitpid(tmp_pid, NULL, 0) != tmp_pid) && (guard < 100)) { guard++; }
			}
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

/*
	goto nrm_end;
err_end:
	ret = 1;
nrm_end:
*/
	return ret;
}

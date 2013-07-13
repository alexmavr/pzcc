/* 
 * .: >> termopts.h
 * 
 * ?: Aristoteles Panaras "ale1ster"
 * @: 2013-07-11T23:48:42 EEST
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "general.h"
#include "error.h"
#include "termopts.h"

static void calculate_output_file (void) {
	char *temp = NULL;
	char *extension_s[] = { "", "imm", "asm", "out" };
	size_t i;

	for (i=0; our_options.output_filename[i] != '\0'; i++) {
	}
	
	temp = new(sizeof(char) * (i+5));

	snprintf(temp, (i+5), "%s.%s", our_options.output_filename, extension_s[our_options.output_type]);
	temp[i+4] = '\0';

	free(our_options.output_filename);
	our_options.output_filename = temp;
}

//Per-option parser.
static error_t parse_opt (int key, char *arg, struct argp_state *state) {
	error_t ret = 0;

//fprintf(stderr, "OPTION PARSER called with key %c and argument %s\n", key, arg);

	switch (key) {
		//Set optimization flag.
		case 'o':
			our_options.opt_flag = true;
			break;
		//Set output to IR.
		case 'i':
			if (our_options.output_type == OUT_NONE) {
				our_options.output_type = OUT_IR;
			} else {
				my_error(ERR_LV_WARN, "Multiple outputs specified");
				ret = 1;
			}
			break;
		//Set output to assembly.
		case 'f':
			if (our_options.output_type == OUT_NONE) {
				our_options.output_type = OUT_ASM;
			} else {
				my_error(ERR_LV_WARN, "Multiple outputs specified");
				ret = 1;
			}
			break;
		case 'l':
			our_options.llc_flags = arg;
			break;
		case 't':
			our_options.opt_flags = arg;
			break;
		//Capture input filename.
		case ARGP_KEY_ARG:
			if (our_options.in_file == NULL) {
				our_options.in_file = fopen(arg, "r");
				if (our_options.in_file == NULL) {
					my_error(ERR_LV_WARN, "Input file %s not found", arg);
					ret = 1;
				//Save the output file name.
				} else {
					our_options.output_filename = strdup(arg);
					if (our_options.output_filename == NULL) {
						my_error(ERR_LV_WARN, "strdup() failed");
						ret = 1;
					}
				}
			} else {
				my_error(ERR_LV_WARN, "Multiple input files specified");
				ret = 1;
			}
			break;
		//Capture option parsing end event, check input stream and open output.
		case ARGP_KEY_END:
			if (our_options.output_type == OUT_NONE)
				our_options.output_type = OUT_EXEC;

			if (our_options.in_file == NULL) {
				our_options.in_file = stdin;
			}
			if (our_options.in_file == stdin) {
				our_options.output_is_stdout = true;
			} else {
				calculate_output_file();
			}
			break;
	}

	return ret;
}

//Global argp variables.
const char *argp_program_version = "Pazcal 0.1a";
const char *argp_program_bug_address = "<spiritual.dragon.of.ra@gmail.com>";
//Argp option structure.
static struct argp_option options[] = {
	{ "emit-intermediate", 'i', 0, 0, "Emit LLVM intermediate code", 0 }, 
	{ "emit-final", 'f', 0, 0, "Emit final assembly code", 0 }, 
	{ "optimize", 'o', 0, 0, "Enable all optimizations", 1 }, 
	{ "opt-flags" , 't', "OPT_FLAGS", 0, "Option string to be used with opt when -o option is in effect", 2 }, 
	{ "llc-flags", 'l', "LLC_FLAGS", 0, "Option string to be used with llc when -f option is in effect", 2 }, 
	{ 0 }
};
//Non-option argument description.
static char args_doc[] = "[ FILE ]";
//Argp structure.
static struct argp argp = { options, parse_opt, args_doc, "Pazcal compiler for Compilers course - NTUA 2013\vGNU Licence", 0, 0, 0 };

void parse_term_options (int argc, char **argv) {
	argp_parse(&argp, argc, argv, ARGP_IN_ORDER, 0, NULL);
}

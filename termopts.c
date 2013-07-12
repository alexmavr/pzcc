/* 
 * .: >> termopts.h
 * 
 * ?: Aristoteles Panaras "ale1ster"
 * @: 2013-07-11T23:48:42 EEST
 * 
 */

#include <stdio.h>
#include <string.h>
#include "termopts.h"
#include "error.h"

//Per-option parser.
static error_t parse_opt (int key, char *arg, struct argp_state *state) {
	error_t ret = 0;

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
		//Capture input filename.
		case ARGP_KEY_ARG:
			if (our_options.in_file == NULL) {
				our_options.in_file = fopen(arg, "r");
				if (our_options.in_file == NULL) {
					my_error(ERR_LV_WARN, "Input file %s not found", arg);
					ret = 1;
				//Save the output file name.
				} else {
					our_options.input_filename = strdup(arg);
					if (our_options.input_filename == NULL) {
						my_error(ERR_LV_WARN, "strdup() failed");
						ret = 1;
					}
				}
			} else {
				my_error(ERR_LV_WARN, "Multiple files specified");
				ret = 1;
			}
			break;
		//Capture option parsing end event, check input stream and open output.
		case ARGP_KEY_END:
			if (our_options.in_file == NULL) {
				our_options.in_file = stdin;
			}
			if (our_options.in_file == stdin) {
				our_options.out_file = stdout;
			} else {
				//...
fprintf(stderr, "FILENAME copy is %s\n", our_options.input_filename);
				char *ext_ptr = strstr(our_options.input_filename, ".pzc");
				if (ext_ptr != NULL) {
					//...
					//TODO: Modify the file extension.
fprintf(stderr, "NOT SUPPORTED. EXITING\n");
exit(EXIT_FAILURE);
					//...
				}
				//...
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
	{ "optimize", 'o', 0, 0, "Enable all optimizations", 0 }, 
	{ "emit-intermediate", 'i', 0, 0, "Emit LLVM intermediate code", 1 }, 
	{ "emit-final", 'f', 0, 0, "Emit final assembly code", 1 }, 
	{ 0 }
};
//Non-option argument description.
static char args_doc[] = "[ FILE ]";
//Argp structure.
static struct argp argp = { options, parse_opt, args_doc, "Pazcal compiler for Compilers course - NTUA 2013\vGNU Licence", 0, 0, 0 };

void parse_term_options (int argc, char **argv) {
	argp_parse(&argp, argc, argv, ARGP_IN_ORDER, 0, NULL);
}

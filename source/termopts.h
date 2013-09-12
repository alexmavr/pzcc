/*
 * .: Option parsing from terminal invocation.
 *
 * ?: Aristoteles Panaras "ale1ster"
 * @: 2013-07-11T23:48:25 EEST
 *
 */

#ifndef __TERMINAL_OPTIONS_H__
#define __TERMINAL_OPTIONS_H__

#include <stdbool.h>
#include <argp.h>

//Structure for option parsing. We use it to store the parsed information.
struct options_t {
	//Verbose flag
	bool verbose_flag;

	//Input/Output files
	FILE *in_file;
	bool output_is_stdout;
	enum { OUT_NONE, OUT_IR, OUT_ASM, OUT_EXEC } output_type;
	char *output_filename;

	//General requirements
	char *tmp_filename;
	char *tmp_filename_too;

	//Flags for propagation
	char *llvmopt_flags;
	char *llvmllc_flags;
	char *llvmclang_flags;

	//Optimization flag
	bool opt_flag;

	//Library object file
	char *pzc_lib_file;
};

//Option instance definition.
extern struct options_t our_options;

//Argument parser.
void parse_term_options (int argc, char **argv);

#endif	/* __TERMINAL_OPTIONS_H__ */

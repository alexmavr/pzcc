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
	//Input/Output files.
	FILE *in_file;
	enum { OUT_NONE, OUT_IR, OUT_ASM, OUT_EXEC } output_type;
	bool output_is_stdout;
	char *output_filename;

	//Optimization flag
	bool opt_flag;
};

//Option instance definition.
extern struct options_t our_options;

//Argument parser.
void parse_term_options (int argc, char **argv);

#endif	/* __TERMINAL_OPTIONS_H__ */

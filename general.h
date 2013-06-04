/*
 * .: Library of general routines, macros and other resources.
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * +: Nikolaos S. Papaspyrou (nickie@softlab.ntua.gr)
 * @: Mon 03 Jun 2013 08:36:10 PM EEST
 *
 */

#ifndef __GENERAL_H__
#define __GENERAL_H__

#include <llvm-c/Core.h>

void *new		(size_t);
void delete		(void *);
void cleanup	(void);

extern char *filename;
extern int yylineno;

LLVMBuilderRef builder;
LLVMModuleRef module;

int main (int argc, char **argv);

#endif	/* __GENERAL_H__ */

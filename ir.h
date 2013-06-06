/*
 * .: Library for IR generation.
 *
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Tue 04 Jun 2013 10:53:07 AM EEST
 *
 */

#ifndef __IR_H__
#define __IR_H__

#include <llvm-c/Core.h>
#include "symbol.h"

LLVMTypeRef type_to_llvm(Type t);
LLVMValueRef cast_compat(Type dest, Type src, LLVMValueRef src_val);


#endif	/* __IR_H__ */

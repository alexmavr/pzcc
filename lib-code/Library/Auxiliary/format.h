#ifndef __FORMAT_H__
#define __FORMAT_H__


#ifndef __PZCTYPES_H__
#include "pzctypes.h"
#endif


#define SPACEPAD_CHAR        '_'
#define POINT_CHAR           '.'
#define EXPONENT_LOWER_CHAR  'e'
#define EXPONENT_UPPER_CHAR  'E'

#define FLAG_LEFTALIGN  0x01
#define FLAG_ZEROPAD    0x02
#define FLAG_FORCESIGN  0x04
#define FLAG_NOSIGNEXP  0x08
#define FLAG_FORMAT     0x30
#define FLAG_FIXED      0x00
#define FLAG_EXPON      0x10
#define FLAG_SMART      0x20
#define FLAG_UPPERCASE  0x40

byte formatInteger (char * buffer, integer i,
                    byte width, byte flags, byte base);

byte formatReal (char * buffer, real r,
                 byte width, byte precision,
	             byte flags, byte base);

byte parseInteger (const char * buffer, integer * p, byte base);

byte parseReal (const char * buffer, real * p, byte base);


#endif

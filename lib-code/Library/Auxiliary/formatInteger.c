#include "pzctypes.h"
#include "format.h"

byte formatInteger (char * buffer, integer i,
                    byte width, byte flags, byte base)
{
	const char * digit =
		(flags & FLAG_UPPERCASE) ?
			"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" :
			"0123456789abcdefghijklmnopqrstuvwxyz";

	static char temp [5];
	char sign = '\0';
	char * s = buffer, * p = temp;
	integer padding;

	if (i < 0) {
    	i = -i;
        sign = '-';
    }
    else if (flags & FLAG_FORCESIGN)
		sign = '+';

	/* This is to compute the digits */
	
	if (i == 0)
		*p++ = '0';
	else
		while (i > 0) {
			byte U = i % base;
			
			i = i / base;
			*p++ = digit[U];
		}

	/* And this is the final formatting */
	
	padding = width - (p - temp);
	if (sign)
		padding--;

	if (!(flags & FLAG_LEFTALIGN)) {
		if (flags & FLAG_ZEROPAD)
			for (i = 0; i < padding; i++)
				*s++ = '0';
		else
			for (i = 0; i < padding; i++)
				*s++ = SPACEPAD_CHAR;
	}

	if (sign)
		*s++ = sign;

	while (--p >= temp)
		*s++ = *p;

	if (flags & FLAG_LEFTALIGN)
		for (i = 0; i < padding; i++)
			*s++ = SPACEPAD_CHAR;
	
	*s = '\0';			
	return s - buffer;
}

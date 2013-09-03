#include "pzctypes.h"
#include "format.h"


byte parseInteger (const char * buffer, integer * p, byte base)
{
	integer result = 0;
	byte negative = 0;
	const char * s = buffer;

	/* Skip leading spaces */

	for (;;) {
		switch (*s) {
			case ' ':
			case '\n':
			case '\t':
			case '\r':
			case '\v':
			case '\f':
				s++;
				continue;
		}
		break;
	}

	/* Sign */

	switch (*s) {
		case '-':
			negative = 1;
		case '+':
			s++;
			break;
	}

	/* Integer */

	for (;;) {
		byte digit = *s;

		if (digit >= '0' && digit <= '9')
			digit -= '0';
		else {
			digit |= 0x20;
			if (digit < 'a')
				break;
			digit -= 'a';
			digit += 10;
			if (digit > base)
				break;
		}

		result = result * base + digit;
		s++;
	}

    /* Apply sign and return */

	if (negative)
		result = -result;

	*p = result;
	return s - buffer;
}

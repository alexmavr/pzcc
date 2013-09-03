#include "pzctypes.h"
#include "format.h"


byte parseReal (const char * buffer, real * p, byte base)
{
	real result = 0.0L;
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

	/* Integer part */
		
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
	
	/* Fractional part */

	if (*s == POINT_CHAR) {
		real M = 1.0L;

		s++;
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
			
			M /= base;
			result += M * digit;
			s++;			
		}
	}

	/* Exponent */
		
	if (*s == EXPONENT_LOWER_CHAR || *s == EXPONENT_UPPER_CHAR) {
		integer exponent;
		real M = base;
		
		s++;
		s += parseInteger(s, &exponent, base);
		
		if (exponent < 0) {
			exponent = -exponent;
			M = 1 / M;
		}
		
		while (exponent > 0) {
			if ((exponent & 1) > 0)
				result *= M;
			exponent >>= 1;
			M *= M;
		}
	}
	
	/* Apply sign and return */
		
	if (negative)
		result = -result;
	
	*p = result;
	return s - buffer;
}

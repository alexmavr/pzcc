#include "pzctypes.h"
#include "format.h"

byte isnanl (real r)
{
	return isnan(r);
}

byte isinfl (real r)
{
	return isinf(r);
}

byte formatReal (char * buffer, real r,
                 byte width, byte precision,
                 byte flags, byte base)
{
    static char temp [256];
    char sign = '\0';
    char * toPrint, * s = buffer;
    byte size, i;
    integer padding;

    if (isinfl(r)) {
        if (r < 0.0L)
            sign = '-';
        toPrint = "Inf";
        size = 3;
    }
    else if (isnanl(r)) {
        toPrint = "NaN";
        size = 3;
    }
    else {
        real invbase = 1.0L / base;
        integer exponent = 0, sizeInt, sizeFrac;

        if (r < 0.0L) {
            r = -r;
            sign = '-';
        }

        /* This is inexact, but we'll live with it for now !!! */

        while (r > 0.0L)
            if (r >= 1.0L) {
                integer k = 1;
                real M = base;

                while (r >= M) {
                    M *= M;
                    k <<= 1;
                }
                exponent += k;
                r /= M;
            }
            else if (r < invbase) {
                integer k = 1;
                real M = invbase;

                while (r < M) {
                    M *= M;
                    k <<= 1;
                }
                exponent -= k;
                r /= M;
            }
            else
                break;

        /* Force exponent format if the exponent is too large */

        if (exponent > 255
        		|| ((flags & FLAG_FORMAT) == FLAG_SMART
        			&& (exponent > 6 || exponent <= -5))) {
            flags &= ~FLAG_FORMAT;
            flags |= FLAG_EXPON;
		}
		else if ((flags & FLAG_FORMAT) == FLAG_SMART) {
            flags &= ~FLAG_FORMAT;
            flags |= FLAG_FIXED;
		}

        /* Use format */

        if ((flags & FLAG_FORCESIGN) && sign != '-')
            sign = '+';

        switch (flags & FLAG_FORMAT) {
            case FLAG_FIXED:
                sizeInt = exponent;
                break;
            case FLAG_EXPON:
                sizeInt = 1;
                exponent--;
                break;
        }
        sizeFrac = precision;

        /* This is an adaptation of Steele & White FP3, plus the exponent */

        do {
            const char * digit =
                (flags & FLAG_UPPERCASE) ?
                    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" :
                    "0123456789abcdefghijklmnopqrstuvwxyz";
            const real VALUE_2_POW_MINUS_65 =
                2.7105054312137610850186320021749e-20L;

            real R = r, U, M = VALUE_2_POW_MINUS_65;
            char * p = temp;

            if (sizeInt <= 0) {
                *p++ = '0';
                if (sizeFrac > 0) {
                    *p++ = POINT_CHAR;
					while (sizeInt++ < 0)
						if (sizeFrac-- > 0)
							*p++ = '0';
						else
							break;
				}
				sizeInt = 0;
            }

            for (;;) {
                R = split(base * R, &U);
                M = M * base;
                if (R < M || R > 1-M || (sizeInt <= 0 && sizeFrac <= 0))
                    break;
               	*p++ = digit[(byte) U];
                if (sizeInt > 0) {
                    if (--sizeInt == 0) {
	                	if (sizeFrac > 0)
	                		*p++ = POINT_CHAR;
	                	else
	                		break;
	                }
                }
                else
                	sizeFrac--;
            }
            
            if (R >= 0.5L)
                U++;
                
            if (sizeInt > 0) {
	           	*p++ = digit[(byte) U];
                while (--sizeInt > 0)
                	*p++ = '0';
            	if (sizeFrac > 0)
            		*p++ = POINT_CHAR;
            	else
            		break;
            }
            else if (sizeFrac-- > 0)
				*p++ = digit[(byte) U];

			while (sizeFrac-- > 0)
				*p++ = '0';
			
            if ((flags & FLAG_FORMAT) == FLAG_EXPON) {
                *p++ = (flags & FLAG_UPPERCASE) ?
                            EXPONENT_UPPER_CHAR :
                            EXPONENT_LOWER_CHAR;
                p += formatInteger(p, exponent, 0,
                            ((flags & FLAG_NOSIGNEXP) ? 0 : FLAG_FORCESIGN)
                                | (flags & FLAG_UPPERCASE),
                            base);
            }

            *p = '\0';

	        toPrint = temp;
	        size = p - temp;
        } while (0);
    }

    /* And this is the final formatting */

    padding = width - size;
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

    while (*toPrint)
        *s++ = *toPrint++;

    if (flags & FLAG_LEFTALIGN)
        for (i = 0; i < padding; i++)
            *s++ = SPACEPAD_CHAR;

    *s = '\0';
    return s - buffer;
}

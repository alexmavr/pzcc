/* 
 * .: Just unary operation testing.
 * 
 * ?: Aristoteles Panaras "ale1ster"
 * @: Thu 06 Jun 2013 08:44:47 PM EEST
 * 
 */

#include <stdio.h>
#include <stdlib.h>
//#include <stdint.h>

int main (void) {
	int hi = ((-97) & 0xFF)%256;
	fprintf(stderr, "%d\n", hi);
	return 0;
}

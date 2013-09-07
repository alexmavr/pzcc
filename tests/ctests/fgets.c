/* 
 * .: fgets() behaviour testing.
 * 
 * ?: Aristoteles Panaras "ale1ster"
 * @: Sat 07 Sep 2013 09:22:28 PM EEST
 * 
 */

#include <stdlib.h>
#include <stdio.h>

int main (void) {
	char hi[40];
	fgets(hi, 40, stdin);
	fprintf(stderr, "String is '%s'\n", hi);
	return 0;
}

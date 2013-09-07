/* 
 * .: Testing -lgc flag of gcc.
 * > gcc -g % -lgc
 * OR
 * > gcc -g -Wl,--as-needed -lgc %
 * 
 * ?: Aristoteles Panaras "ale1ster"
 * @: 2013-09-06T21:47:32 EEST
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <gc/gc.h>

int main (void) {
	char *hi;
	size_t i = 0;
	while (1) {
//		hi = (char *)malloc(4300);
		hi = (char *)GC_malloc(4300);
		if (i == 8000)
			break;
		i++;
	}
	return 0;
}

#include <stdio.h>
#include "format.h"

void rawReal (real r)
{
	unsigned char * b = (unsigned char *) &r;
	int i;
	
	printf("( ", r);
	for (i = 9; i >=0; i--)
		printf("%02x ", b[i]);
	printf(")");
}

void sanity (const char * temp, byte size)
{
	int j;

	for (j = 0; j < size; j++)
		if (temp[j] == '\0')
			printf("\n!!! sanity error: \"%s\" of size %d\n\n", temp, size);
	if (temp[j] != '\0')
		printf("\n!!! sanity error: \"%s\" of size %d\n\n", temp, size);
}

int main ()
{
	integer i;
	real r;
	char temp [256];
	byte size;

	/* Testing integers */

	do {	
		printf("i = ");
		scanf("%hd", &i);
		printf("\n");

		printf("i = %hd\n", i);
		printf("i = %ho\n", i);
		printf("i = %hx\n", i);
		printf("\n");
	
		size = formatInteger(temp, i, 0, 0, 10);
		sanity(temp, size);
		printf("base 10: i = %s\n", temp);
	
		size = formatInteger(temp, i, 0, 0, 8);
		sanity(temp, size);
		printf("base  8: i = %s\n", temp);
	
		size = formatInteger(temp, i, 0, 0, 16);
		sanity(temp, size);
		printf("base 16: i = %s\n", temp);
	
		size = formatInteger(temp, i, 0, 0, 2);
		sanity(temp, size);
		printf("base  2: i = %s\n", temp);
	
		printf("\n");
	} while (i != 0);

	/* Testing reals */

	do {	
		printf("r = ");
		scanf("%Lf", &r);
		printf("\n");

		printf("r = %Lf\n", r);
		printf("r = %Le\n", r);
		printf("r = %0.50Lf\n", r);
		printf("r = "); rawReal(r);
		printf("\n\n");
	
		size = formatReal(temp, r, 0, 16, FLAG_FIXED, 10);
		sanity(temp, size);
		printf("base 10, fixed,  0.16: r = %s\n", temp);
		
		size = formatReal(temp, r, 0, 16, FLAG_EXPON, 10);
		sanity(temp, size);
		printf("base 10, expon,  0.16: r = %s\n", temp);
		
		size = formatReal(temp, r, 0, 16, FLAG_SMART, 10);
		sanity(temp, size);
		printf("base 10, smart,  0.16: r = %s\n", temp);
	
		size = formatReal(temp, r, 0, 3, FLAG_FIXED, 10);
		sanity(temp, size);
		printf("base 10, fixed,   0.3: r = %s\n", temp);
		
		size = formatReal(temp, r, 0, 0, FLAG_FIXED, 10);
		sanity(temp, size);
		printf("base 10, fixed,   0.0: r = %s\n", temp);

		size = formatReal(temp, r, 0, 3, FLAG_EXPON, 10);
		sanity(temp, size);
		printf("base 10, expon,   0.3: r = %s\n", temp);
		
		size = formatReal(temp, r, 0, 0, FLAG_EXPON, 10);
		sanity(temp, size);
		printf("base 10, expon,   0.0: r = %s\n", temp);

		size = formatReal(temp, r, 10, 3, FLAG_FIXED, 10);
		sanity(temp, size);
		printf("base 10, fixed,  10.3: r = %s\n", temp);

		size = formatReal(temp, r, 10, 3, FLAG_EXPON, 10);
		sanity(temp, size);
		printf("base 10, expon,  10.3: r = %s\n", temp);

		size = formatReal(temp, r, 10, 3, FLAG_FIXED | FLAG_LEFTALIGN, 10);
		sanity(temp, size);
		printf("base 10, fixed, -10.3: r = %s\n", temp);

		size = formatReal(temp, r, 10, 3, FLAG_EXPON | FLAG_LEFTALIGN, 10);
		sanity(temp, size);
		printf("base 10, expon, -10.3: r = %s\n", temp);

		size = formatReal(temp, r, 10, 3, FLAG_FIXED | FLAG_ZEROPAD, 10);
		sanity(temp, size);
		printf("base 10, fixed, 010.3: r = %s\n", temp);

		size = formatReal(temp, r, 10, 3, FLAG_EXPON | FLAG_ZEROPAD, 10);
		sanity(temp, size);
		printf("base 10, expon, 010.3: r = %s\n", temp);

		size = formatReal(temp, r, 0, 16, FLAG_SMART, 8);
		sanity(temp, size);
		printf("base  8, smart,  0.16: r = %s\n", temp);
	
		size = formatReal(temp, r, 0, 16, FLAG_SMART, 16);
		sanity(temp, size);
		printf("base 16, smart,  0.16: r = %s\n", temp);
	
		size = formatReal(temp, r, 0, 16, FLAG_SMART, 2);
		sanity(temp, size);
		printf("base  2, smart,  0.16: r = %s\n", temp);
	
		printf("\n");
	} while (r != 0.0);
	
	return 0;
}

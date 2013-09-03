#include <stdio.h>
#include "format.h"

int main ()
{
	integer i1, i2;
	real r1, r2;
	char temp [256];

	/* Testing integers */

	do {	
		printf("i = ");
		fgets(temp, 256, stdin);
		
		parseInteger(temp, &i1, 10);
		printf("i1 = %hd\n", i1);

		sscanf(temp, "%hd", &i2);
		printf("i2 = %hd\n", i2);
		
		if (i1 != i2)
			printf("Sanity error: %hd\n", i1-i2);

		printf("\n");
	} while (i2 != 0);

	/* Testing reals */

	do {	
		printf("r = ");
		fgets(temp, 256, stdin);
		
		parseReal(temp, &r1, 10);
		printf("r1 = %Lf\n", r1);

		sscanf(temp, "%Lf", &r2);
		printf("r2 = %Lf\n", r2);
		
		if (r1 != r2)
			printf("Sanity error: %Lg!\n", (r1-r2)/r2);

		printf("\n");
	} while (r2 != 0.0);
	
	return 0;
}

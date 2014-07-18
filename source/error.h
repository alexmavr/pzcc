/*
 * .: Error library.
 *
 * ?: Aristoteles Panaras "ale1ster"
 * @: Mon 03 Jun 2013 08:57:21 PM EEST
 *
 */

#ifndef __ERROR_H__
#define __ERROR_H__

#include <stdbool.h>

/* Error Levels */
typedef enum { ERR_LV_WARN, ERR_LV_ERR, ERR_LV_CRIT, ERR_LV_INTERN } error_lv;

/* Reporter functions */
void yyerror (const char *msg);
void my_error (error_lv level, const char *msg, ...);

#endif	/* __ERROR_H__ */

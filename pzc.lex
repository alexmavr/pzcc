%{
#include <stdlib.h>
#include <stdarg.h> 
#include "comp_lib.h"

#define T_eof		0
#define T_bool		256
#define T_and		257
#define T_break		258
#define T_case		259
#define T_char		260
#define T_const		261
#define T_cont		262
#define T_def		263
#define T_do		264
#define T_downto	265
#define T_false		266
#define T_else		267
#define T_for		268
#define T_form		269
#define T_func		270
#define T_if		271
#define T_int		272
#define T_mod		273
#define T_next		274
#define T_not		275
#define T_or		276
#define T_proc		277
#define T_prog		278
#define T_real		279
#define T_ret		280
#define T_step		281
#define T_switch	282
#define T_to		283
#define T_true		284
#define T_while		285
#define T_write		286
#define T_wrln		287
#define T_wrsp		288
#define T_wrspln	289
#define T_id		290
#define T_CONST_integer	291
#define T_CONST_real	292
#define T_CONST_char	293
#define T_CONST_string	294
#define T_eq        295
#define T_diff      296
#define T_greq      297
#define T_leq       298
#define T_logand    299 
#define T_logor     300
#define T_pp        301
#define T_mm        302
#define T_inc       303 
#define T_dec       304 
#define T_mul       305
#define T_div       306
#define T_opmod       307

%}

%option noyywrap
%option yylineno

W			[ \t\r]
INT			0|[1-9][0-9]*
ESC_SEQ		\\[nrt0\'\"\\]
CHAR		({ESC_SEQ}|[^\'\"\\\n])
SEPAR_n_OPS	[&;.\(\):,\[\]\{\}+\-*/%!=><]

%%

"bool"					{ return T_bool;	}
"and"					{ return T_and;		}
"break"					{ return T_break;	}
"case"					{ return T_case;	}
"char"					{ return T_char;	}
"const"					{ return T_const;	}
"continue"				{ return T_cont;	}
"default"				{ return T_def;		}
"do"					{ return T_do;		}
"DOWNTO"				{ return T_downto;	}
"else"					{ return T_else;	}
"false"					{ return T_false;	}
"FOR"					{ return T_for;		}
"FORM"					{ return T_form;	}
"FUNC"					{ return T_func;	}
"if"					{ return T_if;		}
"int"					{ return T_int;		}
"MOD"					{ return T_mod;		}
"NEXT"					{ return T_next;	}
"not"					{ return T_not;		}
"or"					{ return T_or;		}
"PROC"					{ return T_proc;	}
"PROGRAM"				{ return T_prog;	}
"REAL"					{ return T_real;	}
"return"				{ return T_ret;		}
"STEP"					{ return T_step;	}
"switch"				{ return T_switch;	}
"TO"					{ return T_to;		}
"true"					{ return T_true;	}
"while"					{ return T_while;	}
"WRITE"					{ return T_write;	}
"WRITELN"				{ return T_wrln;	}
"WRITESP"				{ return T_wrsp;	}
"WRITESPLN"				{ return T_wrspln;	}


[a-zA-Z][0-9a-zA-Z_]*			{ return T_id;				}
{INT}							{ return T_CONST_integer;	}
{INT}\.[0-9]+((e|E)[-+]?{INT})?	{ return T_CONST_real;		}
'{CHAR}'						{ return T_CONST_char;		}
\"{CHAR}*\"						{ return T_CONST_string;	}

{SEPAR_n_OPS}					{ return yytext[0];			}

==                              { return T_eq;              }
!=                              { return T_diff;            }
>=                              { return T_greq;            }
\<=                              { return T_leq;             }
&&                              { return T_logand;             }
\|\|                              { return T_logor;              }
\+\+                              { return T_pp;              }
\-\-                              { return T_mm;              }
\+=                              { return T_inc;             }
\-=                              { return T_dec;             }
\*=                              { return T_mul;             }
\/=                              { return T_div;             }
\%=                              { return T_opmod;             }

"\/\/"[^\n]*					{ /* one-line comment */	}
\/\*([^*]|(\*[^\/]))*\*\/		{ /* multi-line comment: If yylineno is activated, this is OK. Else we go states. */	}

{W}+							{ /* ignore whitespace */	}
\n								{ /* line counting: yylineno */	}
.								{ lex_error("invalid token");	}

%%

int main (void)
{
    int token;
	
	yylineno = 1;
    do {
        token = yylex();
        printf("token=%d, line=%d, lexeme=\"%s\"\n", token, yylineno, yytext);
    } while (token != T_eof);

    return EXIT_SUCCESS;
}

%{
/* 
 * .: >> pzc.lex
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "afein"
 * @: Mon 18 Mar 2013 04:10:23 PM EET
 * 
 */

#include <stdlib.h>
#include <stdarg.h> 
#include "comp_lib.h"
#include "parser.h"

#define YY_NO_INPUT

#define T_eof		0
%}

%option noyywrap
%option yylineno
%option nounput

W			[ \t\r]
INT			0|[1-9][0-9]*
ESC_SEQ		\\[nrt0\'\"\\]
CHAR		({ESC_SEQ}|[^\'\"\\\n])
SEPAR_n_OPS	[&;.\(\):,\[\]\{\}+\-*/%!=><]
WARN_SEQ	\\[^\']
WARN_CHAR	({WARN_SEQ}|[^\'\"\\\n])

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

\\\n					{ /* C-like expression breakage on multiple lines (?) */	}

[a-zA-Z][0-9a-zA-Z_]*				{ return T_id;				}
{INT}								{ 
                                        yylval.i = atoi(yytext); 
                                        return T_CONST_integer;
                                	}
[0-9]+\.[0-9]+((e|E)[-+]?{INT})?	{
                                        yylval.r = atof(yytext); 
                                        return T_CONST_real;		
                                    }
'{CHAR}'							{
                                        yylval.c = yytext[1];
                                        return T_CONST_char;	
                                	}
'{WARN_CHAR}'						{ lex_error(ERR_LV_WARN, "Wrong escape sequence"); return T_CONST_char;	}
\"{CHAR}*\"							{ 
                                        int i = 1;
                                        /* Remove the "" surrounding the string */
                                        while (yytext[i] != '\"' || yytext[i-1] == '\\')
                                            i++;
                                        char *tmp= malloc(i*sizeof(char));
                                        tmp = &yytext[1];
                                        tmp[i-1] = '\0';
                                        yylval.s = (const char *) tmp;
                                        free(tmp);
                                        return T_CONST_string;
                                	}
\"{WARN_CHAR}\"						{ lex_error(ERR_LV_WARN, "Wrong escape sequence"); return T_CONST_string;	}
	
{SEPAR_n_OPS}						{ return yytext[0];			}

==									{ return T_eq;				}
!=								    { return T_diff;			}
>=								    { return T_greq;			}
\<=									{ return T_leq;				}
&&									{ return T_logand;			}
\|\|								{ return T_logor;			}
\+\+								{ return T_pp;				}
\-\-								{ return T_mm;				}
\+=									{ return T_inc;				}
\-=									{ return T_dec;				}
\*=									{ return T_mul;				}
\/=									{ return T_div;				}
\%=									{ return T_opmod;			}

"\/\/"[^\n]*						{ /* one-line comment */	}
\/\*([^*]|(\**[^\/]))*\*\/			{ /* multi-line comment */  }

{W}+								{ /* ignore whitespace */	}
\n									{ /* line counting: yylineno */	}

\"|\'							    { lex_error(ERR_LV_CRIT, "Unexpected token %s", yytext);	}
.									{ lex_error(ERR_LV_CRIT, "Invalid token %s", yytext);	}

%%

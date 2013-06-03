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
#include <string.h>
#include "symbol/symbol.h"
#include "symbol/general.h"
#include "parser.h"
#include "comp_lib.h"

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
"and"					{
							yylval.s = "and";
							return T_and;
						}
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
"MOD"					{
							yylval.s = "MOD";
							return T_mod;	
						}
"NEXT"					{ return T_next;	}
"not"					{ return T_not;		}
"or"					{
							yylval.s = "or";
							return T_or;		
						}
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

\\\n					{ /* C-like expression breakage on multiple lines (?) */ }

[a-zA-Z][0-9a-zA-Z_]*				{
										char *tmp = (char *) new(yyleng * sizeof(char));
										strcpy(tmp, yytext);
										yylval.s = (const char *) tmp;
										return T_id;
									}

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

'{WARN_CHAR}'						{
										my_error(ERR_LV_WARN, "Malformed escape sequence: %s ", yytext);
										return T_CONST_char;
									}

\"{CHAR}*\"							{
										/* copy the string without the surrounding " chars */
										char * tmp = (char *) new((yyleng-1) * sizeof(char));
										strcpy (tmp, &yytext[1]);
										tmp[yyleng-2] = '\0';
										yylval.s = (const char *) tmp;
										return T_CONST_string;
									}
\"{WARN_CHAR}*\"					{
										my_error(ERR_LV_WARN, "Malformed escape sequence: %s", yytext);
										return T_CONST_string;
									}
	
{SEPAR_n_OPS}						{
										char * tmp= (char *) new(2 * sizeof(char));
										tmp[0] = yytext[0];
										tmp[1] = '\0';
										yylval.s = tmp;
										return yytext[0];		
									}

==									{
										yylval.s = "==";
										return T_eq;			
									}
\!\=								{

										yylval.s = "!=";
										return T_diff;			
									}
>=									{
										yylval.s = ">=";
										return T_greq;			
									}
\<=									{
										yylval.s = "<=";
										return T_leq;			
									}
&&									{
										yylval.s = "&&";
										return T_logand;		
									}
\|\|								{
										yylval.s = "||";
										return T_logor;		
									}
\+\+								{
										yylval.s = "++";
										return T_pp;		
									}
\-\-								{
										yylval.s = "--";
										return T_mm;		
									}
\+=									{
										yylval.s = "+=";
										return T_inc;		
									}
\-=									{
										yylval.s = "-=";
										return T_dec;		
									}
\*=									{
										yylval.s = "*=";
										return T_mul;		
									}
\/=									{
										yylval.s = "/=";
										return T_div;		
									}
\%=									{
										yylval.s = "%=";
										return T_opmod;;		
									}

"\/\/"[^\n]*						{ /* one-line comment */	}
\/\*([^*]|(\**[^\/]))*\*\/			{ /* multi-line comment */  }

{W}+								{ /* ignore whitespace */	}
\n									{ /* line counting: yylineno */	}

\"|\'								{ my_error(ERR_LV_CRIT, "Unexpected token %s", yytext);	}
.									{ my_error(ERR_LV_CRIT, "Invalid token %s", yytext);	}

%%


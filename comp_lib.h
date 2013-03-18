/* 
 * .: General library for brevity in lexer source file.
 * 
 * ?: Aristoteles Panaras "ale1ster"
 *    Alexandros Mavrogiannis "nalfemp"
 * @: Mon 18 Mar 2013 04:01:47 PM EET
 * 
 */



void lex_error (const char *msg) {
	fprintf(stderr, "Lexical error [%d @ %s ]: %s\n", yylineno, yytext, msg);
	exit(EXIT_FAILURE);
}

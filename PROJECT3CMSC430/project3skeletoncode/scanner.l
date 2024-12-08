%{
#include <cstdio>
#include <string>
#include <vector>

using namespace std;

#include "values.h"
#include "listing.h"
#include "parser.tab.h"  // Include Bison's header file for token definitions

int convert_hex_to_int(const char *hex_str) {
    int value = 0;
    sscanf(hex_str + 1, "%x", &value); // Skip the '#' character and convert
    return value;
}
%}

%option noyywrap

// Definitions
ws          [ \t\r]+
comment     "//".*\n
line        [\n]
id          [A-Za-z]([A-Za-z0-9])*
digit       [0-9]
dec         {digit}+
real        {digit}*"."{digit}+([eE][+-]?{digit}+)?
hex         "#"({digit}|[A-Fa-f])+
char        \'([^\\n\'\\\\]|\\\\[btnrf\'\\\\])\'
punc        [\(\),:;]

%%

{ws}                    { /* Ignore whitespace */ }
{comment}               { ECHO; nextLine(); }
{line}                  { ECHO; nextLine(); }
{real}                  { ECHO; yylval.rval = atof(yytext); return REAL_LITERAL; }
{hex}                   { ECHO; yylval.ival = convert_hex_to_int(yytext); return HEX_LITERAL; }
"+"                     { ECHO; yylval.oper = ADD; return ADDOP; }
"*"                     { ECHO; yylval.oper = MULTIPLY; return MULOP; }
"&"                     { ECHO; yylval.oper = AND; return ANDOP; }
"|"                     { ECHO; yylval.oper = OR; return TOKEN_OROP; }
"!"                     { ECHO; yylval.oper = NOT; return TOKEN_NOTOP; }
"-"                     { ECHO; yylval.oper = SUBTRACT; return TOKEN_SUBTRACT; }
"/"                     { ECHO; yylval.oper = DIVIDE; return TOKEN_DIVIDE; }
"%"                     { ECHO; yylval.oper = MOD; return TOKEN_MODOP; }
"^"                     { ECHO; yylval.oper = EXP; return TOKEN_EXPOP; }
"~"                     { ECHO; yylval.oper = NEG; return TOKEN_NEGOP; }
{punc}                  { ECHO; return yytext[0]; }

"begin"                 { ECHO; return BEGIN_; }
"case"                  { ECHO; return CASE; }
"character"             { ECHO; return CHARACTER; }
"end"                   { ECHO; return END; }
"endswitch"             { ECHO; return ENDSWITCH; }
"function"              { ECHO; return FUNCTION; }
"integer"               { ECHO; return INTEGER; }
"real"                  { ECHO; return REAL; }
"is"                    { ECHO; return IS; }
"list"                  { ECHO; return TOKEN_LIST; }  // Renamed to TOKEN_LIST
"of"                    { ECHO; return OF; }
"others"                { ECHO; return OTHERS; }
"returns"               { ECHO; return RETURNS; }
"switch"                { ECHO; return SWITCH; }
"when"                  { ECHO; return WHEN; }
"else"                  { ECHO; return ELSE; }
"elsif"                 { ECHO; return ELSIF; }
"endif"                 { ECHO; return ENDIF; }
"fold"                  { ECHO; return FOLD; }
"endfold"               { ECHO; return ENDFOLD; }
"if"                    { ECHO; return IF; }
"then"                  { ECHO; return THEN; }
"left"                  { ECHO; return LEFT; }
"right"                 { ECHO; return RIGHT; }
{id}                    { ECHO; yylval.iden = strdup(yytext); return IDENTIFIER; }
{dec}                   { ECHO; yylval.ival = atoi(yytext); return INT_LITERAL; }
{char}                  { ECHO; yylval.cval = yytext[1]; return CHAR_LITERAL; }
.                       { ECHO; appendError(LEXICAL, yytext); }
%%


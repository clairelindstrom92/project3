/* CMSC 430 Compiler Theory and Design
   Project 3 Parser with semantic actions for the interpreter */

%{

#include <iostream>
#include <cmath>
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);
double extract_element(CharPtr list_name, double subscript);

Symbols<double> scalars;
Symbols<vector<double>*> lists;
double result;

%}

%define parse.error verbose

%union {
    CharPtr iden;           // Identifier names
    Operators oper;         // Operator type
    double rval;            // Real values (float)
    int ival;               // Integer values
    char cval;              // Character values
    vector<double>* list;   // List of doubles
}

%token <iden> IDENTIFIER
%token <ival> INT_LITERAL HEX_LITERAL
%token <rval> REAL_LITERAL
%token <cval> CHAR_LITERAL
%token <oper> ADDOP MULOP ANDOP RELOP TOKEN_OROP TOKEN_NOTOP TOKEN_SUBTRACT TOKEN_DIVIDE TOKEN_MODOP TOKEN_EXPOP TOKEN_NEGOP
%token ARROW
%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS OF OTHERS RETURNS SWITCH WHEN
%token REAL FOLD ENDFOLD IF THEN LEFT RIGHT ELSIF ENDIF
%token TOKEN_LIST

%type <void> optional_variable
%type <rval> function_header type body statement_ statement cases case expression term primary condition relation scalar_variable
%type <list> list_variable list_literal expressions

%%

function:
    function_header optional_variable body ';' { result = $3; }
    ;

function_header:
    FUNCTION IDENTIFIER RETURNS type ';' { /* Function header parsed */ }
    ;

type:
    INTEGER    { /* Type is INTEGER */ }
    |
    CHARACTER  { /* Type is CHARACTER */ }
    |
    REAL       { /* Type is REAL */ }
    ;

optional_variable:
    list_variable { /* Variable declaration */ }
    |
    scalar_variable { /* Variable declaration */ }
    |
    %empty { /* No action needed */ }
    ;

scalar_variable:
    IDENTIFIER ':' type IS expression ';' { scalars.insert($1, $5); }
    ;

list_variable:
    IDENTIFIER ':' TOKEN_LIST OF type IS list_literal ';' { lists.insert($1, $6); }
    ;

list_literal:
    '(' expressions ')' { $$ = $2; }
    ;

expressions:
    expressions ',' expression { $1->push_back($3); $$ = $1; }
    |
    expression { $$ = new vector<double>(); $$->push_back($1); $$ = $$; }
    ;

body:
    BEGIN_ statement_ END { $$ = $2; }
    ;

statement_:
    statement ';' { $$ = $1; }
    |
    statement_ statement ';' { $$ = $2; }
    |
    error ';' { yyerrok; }
    ;

statement:
    expression { $$ = $1; }
    |
    WHEN condition ',' expression ':' expression { $$ = $2 ? $4 : $6; }
    |
    SWITCH expression IS cases OTHERS ARROW statement ENDSWITCH { $$ = !isnan($4) ? $4 : $7; }
    ;

cases:
    cases case { $$ = !isnan($1) ? $1 : $2; }
    |
    %empty { $$ = NAN; }
    ;

case:
    CASE INT_LITERAL ARROW statement ';' { /* Handle case */ }
    ;

condition:
    condition ANDOP relation { $$ = $1 && $3; }
    |
    relation { $$ = $1; }
    ;

relation:
    '(' condition ')' { $$ = $2; }
    |
    expression RELOP expression { $$ = evaluateRelational($1, $2, $3); }
    ;

expression:
    expression ADDOP term { $$ = evaluateArithmetic($1, $2, $3); }
    |
    term { $$ = $1; }
    ;

term:
    term MULOP primary { $$ = evaluateArithmetic($1, $2, $3); }
    |
    primary { $$ = $1; }
    ;

primary:
    '(' expression ')' { $$ = $2; }
    |
    INT_LITERAL { $$ = $1; }
    |
    CHAR_LITERAL { $$ = $1; }
    |
    REAL_LITERAL { $$ = $1; }
    |
    HEX_LITERAL { $$ = $1; }
    |
    IDENTIFIER '(' expression ')' { $$ = extract_element($1, $3); }
    |
    IDENTIFIER {
        double val;
        if (!scalars.find($1, val)) {
            appendError(UNDECLARED, $1);
            $$ = NAN;
        } else {
            $$ = val;
        }
    }
    ;

%%

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

double extract_element(CharPtr list_name, double subscript) {
    vector<double>* list;
    if (lists.find(list_name, list)) {
        if (subscript < 0 || subscript >= list->size()) {
            appendError(RUNTIME, "Subscript out of range");
            return NAN;
        }
        return (*list)[(int)subscript];
    }
    appendError(UNDECLARED, list_name);
    return NAN;
}

int main(int argc, char *argv[]) {
    firstLine();
    yyparse();
    if (lastLine() == 0)
        cout << "Result = " << result << endl;
    return 0;
}


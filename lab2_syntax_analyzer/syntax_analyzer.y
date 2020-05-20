%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/common.h"
#include "syntax_tree/SyntaxTree.h"

#include "lab1_lexical_analyzer/lexical_analyzer.h"

// external functions from lex
extern int yylex();
extern int yyparse();
extern int yyrestart();
extern FILE * yyin;

// external variables from lexical_analyzer module
extern int lines;
extern char * yytext;

// Global syntax tree.
SyntaxTree * gt;

void yyerror(const char * s);
%}

%union {
/********** TODO: Fill in this union structure *********/
    struct _SyntaxTreeNode* nd;
    char* cd;
}
%type <nd>program declaration-list declaration var-declaration type-specifier fun-declaration params param-list param compound-stmt local-declarations statement-list statement expression-stmt selection-stmt iteration-stmt return-stmt expression var simple-expression relop additive-expression addop term mulop factor call args arg-list
%token <cd>IDENTIFIER 284 NUMBER 285 ARRAY 287
/*284 285 286**/


/********** TODO: Your token definition here ***********/
%token ADD 259 SUB 260 DIV 262 MUL 261
%token LT 263 LTE 264 GT 265 GTE 266 EQ 267 NEQ 268
%token ASSIN 269 SEMICOLON 270 COMMA 271
%token LPARENTHESE 272 RPARENTHESE 273 LBRACKET 274 RBRACKET 275 LBRACE 276 RBRACE 277
%token ELSE 278 IF 279 INT 280 RETURN 281 VOID 282 WHILE 283
%token EOL 288 COMMENT 289 BLANK 290

%left ADD SUB
%left DIV MUL


/* compulsory starting symbol */
%start program

%%
/*************** TODO: Your rules here *****************/
program : declaration-list {$$=newSyntaxTreeNode("program"); SyntaxTreeNode_AddChild($$,$1); gt->root=$$;}
        ;
declaration-list : declaration-list declaration {$$=newSyntaxTreeNode("declaration-list");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,$2);}
                 | declaration {$$=newSyntaxTreeNode("declaration-list");SyntaxTreeNode_AddChild($$,$1);}
				 ;
declaration : var-declaration {$$=newSyntaxTreeNode("declaration");SyntaxTreeNode_AddChild($$,$1);}
            | fun-declaration {$$=newSyntaxTreeNode("declaration");SyntaxTreeNode_AddChild($$,$1);}
			;
var-declaration : type-specifier IDENTIFIER SEMICOLON{$$=newSyntaxTreeNode("var-declaration");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));}
                | type-specifier IDENTIFIER LBRACKET NUMBER RBRACKET SEMICOLON{$$=newSyntaxTreeNode("var-declaration");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("["));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($4));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("]"));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));}
				;
type-specifier : INT {$$=newSyntaxTreeNode("type-specifier");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("int"));}
               | VOID {$$=newSyntaxTreeNode("type-specifier");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("void"));}
			   ;
fun-declaration : type-specifier IDENTIFIER LPARENTHESE params RPARENTHESE compound-stmt {$$=newSyntaxTreeNode("fun-declaration");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));SyntaxTreeNode_AddChild($$,$4);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));SyntaxTreeNode_AddChild($$,$6);}
                ;
params : param-list {$$=newSyntaxTreeNode("params");SyntaxTreeNode_AddChild($$,$1);}
       | VOID {$$=newSyntaxTreeNode("params");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("void"));}
	   ;
param-list : param-list COMMA param {$$=newSyntaxTreeNode("param-list");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(","));SyntaxTreeNode_AddChild($$,$3);}
           | param {$$=newSyntaxTreeNode("param-list");SyntaxTreeNode_AddChild($$,$1);}
		   ;
param : type-specifier IDENTIFIER {$$=newSyntaxTreeNode("param");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));}
      | type-specifier IDENTIFIER ARRAY {$$=newSyntaxTreeNode("param");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("[]"));}
	  ;
compound-stmt : LBRACE local-declarations statement-list RBRACE {$$=newSyntaxTreeNode("compound-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("{"));SyntaxTreeNode_AddChild($$,$2);SyntaxTreeNode_AddChild($$,$3);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("}"));}
              ;
local-declarations : local-declarations var-declaration {$$=newSyntaxTreeNode("local-declarations");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,$2);}
                   | /*empty*/ {$$=newSyntaxTreeNode("local-declarations");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("epsilon"));}
				   ;
statement-list : statement-list statement {$$=newSyntaxTreeNode("statement-list");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,$2);}
               | /*empty*/ {$$=newSyntaxTreeNode("statement-list");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("epsilon"));}
			   ;
statement : expression-stmt {$$=newSyntaxTreeNode("statement");SyntaxTreeNode_AddChild($$,$1);}
          | compound-stmt {$$=newSyntaxTreeNode("statement");SyntaxTreeNode_AddChild($$,$1);}
		  | selection-stmt {$$=newSyntaxTreeNode("statement");SyntaxTreeNode_AddChild($$,$1);}
		  | iteration-stmt {$$=newSyntaxTreeNode("statement");SyntaxTreeNode_AddChild($$,$1);}
		  | return-stmt {$$=newSyntaxTreeNode("statement");SyntaxTreeNode_AddChild($$,$1);}
		  ;
expression-stmt : expression SEMICOLON {$$=newSyntaxTreeNode("expression-stmt");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));}
                | SEMICOLON {$$=newSyntaxTreeNode("expression-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));}
				;
selection-stmt : IF LPARENTHESE expression RPARENTHESE statement {$$=newSyntaxTreeNode("selection-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("if"));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));SyntaxTreeNode_AddChild($$,$3);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));SyntaxTreeNode_AddChild($$,$5);}
               | IF LPARENTHESE expression RPARENTHESE statement ELSE statement {$$=newSyntaxTreeNode("selection-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("if"));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));SyntaxTreeNode_AddChild($$,$3);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));SyntaxTreeNode_AddChild($$,$5);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("else"));SyntaxTreeNode_AddChild($$,$7);}
			   ;
iteration-stmt : WHILE LPARENTHESE expression RPARENTHESE statement {$$=newSyntaxTreeNode("iteration-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("while"));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));SyntaxTreeNode_AddChild($$,$3);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));SyntaxTreeNode_AddChild($$,$5);}
               ;
return-stmt : RETURN SEMICOLON {$$=newSyntaxTreeNode("return-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("return"));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));}
            | RETURN expression SEMICOLON{$$=newSyntaxTreeNode("return-stmt");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("return"));SyntaxTreeNode_AddChild($$,$2);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));}
			;
expression : var ASSIN expression {$$=newSyntaxTreeNode("expression");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("="));SyntaxTreeNode_AddChild($$,$3);}
           | simple-expression {$$=newSyntaxTreeNode("expression");SyntaxTreeNode_AddChild($$,$1);}
		   ;
var : IDENTIFIER {$$=newSyntaxTreeNode("var");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));}
    | IDENTIFIER LBRACKET expression RBRACKET {$$=newSyntaxTreeNode("var");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("["));SyntaxTreeNode_AddChild($$,$3);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("]"));}
	;
simple-expression : additive-expression relop additive-expression {$$=newSyntaxTreeNode("simple-expression");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,$2);SyntaxTreeNode_AddChild($$,$3);}
                  | additive-expression {$$=newSyntaxTreeNode("simple-expression");SyntaxTreeNode_AddChild($$,$1);}
				  ;
relop : LT {$$=newSyntaxTreeNode("relop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("<"));}
      | LTE {$$=newSyntaxTreeNode("relop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("<="));}
	  | GT {$$=newSyntaxTreeNode("relop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(">"));}
	  | GTE {$$=newSyntaxTreeNode("relop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(">="));}
	  | EQ {$$=newSyntaxTreeNode("relop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("=="));}
	  | NEQ {$$=newSyntaxTreeNode("relop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("!="));}
	  ;
additive-expression : additive-expression addop term {$$=newSyntaxTreeNode("additive-expression");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,$2);SyntaxTreeNode_AddChild($$,$3);}
                    | term {$$=newSyntaxTreeNode("additive-expression");SyntaxTreeNode_AddChild($$,$1);}
					;
addop : ADD {$$=newSyntaxTreeNode("addop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("+"));}
      | SUB {$$=newSyntaxTreeNode("addop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("-"));}
	  ;
term : term mulop factor {$$=newSyntaxTreeNode("term");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,$2);SyntaxTreeNode_AddChild($$,$3);}
     | factor {$$=newSyntaxTreeNode("term");SyntaxTreeNode_AddChild($$,$1);}
	 ;
mulop : MUL {$$=newSyntaxTreeNode("mulop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("*"));}
      | DIV {$$=newSyntaxTreeNode("mulop");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("/"));}
	  ;
factor : LPARENTHESE expression RPARENTHESE {$$=newSyntaxTreeNode("factor");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));SyntaxTreeNode_AddChild($$,$2);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));}
       | var {$$=newSyntaxTreeNode("factor");SyntaxTreeNode_AddChild($$,$1);}
	   | call {$$=newSyntaxTreeNode("factor");SyntaxTreeNode_AddChild($$,$1);}
	   | NUMBER {$$=newSyntaxTreeNode("factor");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));}
	   ;
call : IDENTIFIER LPARENTHESE args RPARENTHESE {$$=newSyntaxTreeNode("call");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));SyntaxTreeNode_AddChild($$,$3);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));}
     ;
args : arg-list {$$=newSyntaxTreeNode("args");SyntaxTreeNode_AddChild($$,$1);}
     | /*empty*/ {$$=newSyntaxTreeNode("args");SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("epsilon"));}
     ;
arg-list : arg-list COMMA expression {$$=newSyntaxTreeNode("arg-list");SyntaxTreeNode_AddChild($$,$1);SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(","));SyntaxTreeNode_AddChild($$,$3);}
         | expression {$$=newSyntaxTreeNode("arg-list");SyntaxTreeNode_AddChild($$,$1);}
         ;


%%

void yyerror(const char * s)
{
	// TODO: variables in Lab1 updates only in analyze() function in lexical_analyzer.l
	//       You need to move position updates to show error output below
	fprintf(stderr, "[%s]:[%d] syntax error for %s\n", s, lines, yytext);
}

/// \brief Syntax analysis from input file to output file
///
/// \param input basename of input file
/// \param output basename of output file
void syntax(const char * input, const char * output)
{
	gt = newSyntaxTree();

	char inputpath[256] = "./testcase/";
	char outputpath[256] = "./syntree/";
	strcat(inputpath, input);
	strcat(outputpath, output);

	if (!(yyin = fopen(inputpath, "r"))) {
		fprintf(stderr, "[ERR] Open input file %s failed.", inputpath);
		exit(1);
	}
	yyrestart(yyin);
	printf("[START]: Syntax analysis start for %s\n", input);
	FILE * fp = fopen(outputpath, "w+");
	if (!fp)	return;

	// yyerror() is invoked when yyparse fail. If you still want to check the return value, it's OK.
	// `while (!feof(yyin))` is not needed here. We only analyze once.
	yyparse();
	//printf("test\ngt:%s\ntest\n",gt->root->name);
	printf("[OUTPUT] Printing tree to output file %s\n", outputpath);
	printSyntaxTree(fp, gt);
	deleteSyntaxTree(gt);
	gt = 0;

	fclose(fp);
	printf("[END] Syntax analysis end for %s\n", input);
}

/// \brief starting function for testing syntax module.
///
/// Invoked in test_syntax.c
int syntax_main(int argc, char ** argv)
{
	char filename[50][256];
	char output_file_name[256];
	const char * suffix = ".syntax_tree";
	int fn = getAllTestcase(filename);
	for (int i = 0; i < fn; i++) {
                        lines=1;
			int name_len = strstr(filename[i], ".cminus") - filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			syntax(filename[i], output_file_name);
	}
	return 0;
}

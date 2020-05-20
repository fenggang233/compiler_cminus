%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <stdio.h>
#include <stdlib.h>


#include "lab1_lexical_analyzer/lexical_analyzer.h"
#include "common/common.h"

#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#endif


int files_count=0;
int lines=1;
int pos_start=1;
int pos_end=1;

/*****************声明和选项设置  end*****************/


%}
ADD [+]
SUB [-]
MUL [*]
DIV [/]
LT [<]
LTE [<][=]
GT [>]
GTE [>][=]
EQ [=][=]
NEQ [!][=]
ASSIN [=]
SEMICOLON [;]
COMMA [,]
LPARENTHESE \(
RPARENTHESE \)
LBRACKET \[
RBRACKET \]
LBRACE \{
RBRACE \}
ELSE else
IF if
INT int
RETURN return
VOID void
WHILE while
IDENTIFIER [a-zA-Z][a-zA-Z]*
NUMBER [0-9][0-9]*
LETTER [a-zA-Z]
ARRAY \[\]
EOL [\n]
BLANK [ \n\t]



commentPattern "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
identifierPattern [a-zA-Z][a-zA-Z]*

%%

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/
{ADD} {
	pos_start = pos_end;
	pos_end += 1;
	return 259;
}
{SUB} {
	pos_start = pos_end;
	pos_end += 1;
	return 260;
}
{MUL} {
	pos_start = pos_end;
	pos_end += 1;
	return 261;
}
{DIV} {
	pos_start = pos_end;
	pos_end += 1;
	return 262;
}
{LT} {
	pos_start = pos_end;
	pos_end += 1;
	return 263;
}
{LTE} {
	pos_start = pos_end;
	pos_end += 2;
	return 264;
}
{GT} {
	pos_start = pos_end;
	pos_end += 1;
	return 265;
}
{GTE} {
	pos_start = pos_end;
	pos_end += 2;
	return 266;
}
{EQ} {
	pos_start = pos_end;
	pos_end += 2;
	return 267;
}
{NEQ} {
	pos_start = pos_end;
	pos_end += 2;
	return 268;
}
{ASSIN} {
	pos_start = pos_end;
	pos_end += 1;
	return 269;
}
{SEMICOLON} {
	pos_start = pos_end;
	pos_end += 1;
	return 270;
}
{COMMA} {
	pos_start = pos_end;
	pos_end += 1;
	return 271;
}
{LPARENTHESE} {
	pos_start = pos_end;
	pos_end += 1;
	return 272;
}
{RPARENTHESE} {
	pos_start = pos_end;
	pos_end += 1;
	return 273;
}
{LBRACKET} {
	pos_start = pos_end;
	pos_end += 1;
	return 274;
}
{RBRACKET} {
	pos_start = pos_end;
	pos_end += 1;
	return 275;
}
{LBRACE} {
	pos_start = pos_end;
	pos_end += 1;
	return 276;
}
{RBRACE} {
	pos_start = pos_end;
	pos_end += 1;
	return 277;
}
{ELSE} {
	pos_start = pos_end;
	pos_end += 4;
	return 278;
}
{IF} {
	pos_start = pos_end;
	pos_end += 2;
	return 279;
}
{INT} {
	pos_start = pos_end;
	pos_end += 3;
	return 280;
}
{RETURN} {
	pos_start = pos_end;
	pos_end += 6;
	return 281;
}
{VOID} {
	pos_start = pos_end;
	pos_end += 4;
	return 282;
}
{WHILE} {
	pos_start = pos_end;
	pos_end += 5;
	return 283;
}
{IDENTIFIER} {
	pos_start=pos_end;
	pos_end+=strlen(yytext);
#ifndef LAB1_ONLY
	yylval.cd=strdup(yytext);
#endif
	return 284;
}
{NUMBER} {
	pos_start=pos_end;
	pos_end+=strlen(yytext);
#ifndef LAB1_ONLY
	yylval.cd=strdup(yytext);
#endif
	return 285;
}
{ARRAY} {
	pos_start=pos_end;
	pos_end+=strlen(yytext);
#ifndef LAB1_ONLY
	yylval.cd=strdup(yytext);
#endif
	return 287;
}

{EOL} {
	lines++;
	pos_end = 1;
#ifdef LAB1_ONLY
	return 288;
#endif
}
"/*" {
	int c;
	pos_start = pos_end;
	pos_end += 2;
	while((c=input())!=0){
		pos_end += 1;
		if(c == '\n'){
			++lines;
			pos_end=1;
		}
		else if(c == '*'){
			if((c = input()) == '/'){
				pos_end++;
#ifdef LAB1_ONLY
				return 289;
#endif
                                break;
			}
			else unput(c);
		}
	}
#ifdef LAB1_ONLY
	return 289;
#endif
}
{BLANK} {
	pos_start=pos_end;
	pos_end += 1;
#ifdef LAB1_ONLY
	return 290;
#endif
}
. {return ERROR;}



 /****请在此补全所有flex的模式与动作  end******/
%%
/****************C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
void analyzer(char* input_file_name, char* output_file_name){
	lines = 1;
	pos_start = 1;
	pos_end = 1;
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");

	int token;
	while(token = yylex()){
		switch(token){
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT:
				break;
			case BLANK:
				break;
			case EOL:
				break;
		
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}


/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int lex_main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";

	files_count = getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
                        lines=1;pos_start=1;pos_end=1;
			int name_len = strstr(filename[i], ".cminus")-filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);

			analyzer(filename[i],output_file_name);
	}
	return 0;
}
/****************C代码 end*************/

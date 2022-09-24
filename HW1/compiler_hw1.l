/*
    filename: compiler_hw1.l
*/

/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT
    #define print_token(token) \
        printf("%-8s \t %s\n", strcmp(token, "NEWLINE")? yytext: "", token)

    int line_num = 0;
    int comment_num = 0;
    int last_comment_line = -1;
    int next=0; 
%}

%x insidecom

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
c_comment_start \/\*
c_comment_mid (\*[^\n\/]|[^*\n])*\n
c_comment_end (\*[^\n\/]|[^*\n])*\*\/
cpp_comment \/\/([^\n])*\n
string \".*\"

/* Rules section */
%%

"+"         { print_token(  "ADD"); }
"-"         { print_token(  "SUB"); }
"*"         { print_token(  "MUL"); }
"/"         { print_token(  "QUO"); }
"%"         { print_token(  "REM"); }
"++"        { print_token(  "INC"); }
"--"        { print_token(  "DEC"); }
":"         { print_token(  "COLON"); }
"<"         { print_token(  "LSS"); }
">"         { print_token(  "GTR"); }
"<="        { print_token(  "LEQ"); }
">="        { print_token(  "GEQ"); }
"=="        { print_token(  "EQL"); }
"!="        { print_token(  "NEQ"); }
"("         { print_token( "LPAREN"); }
")"         { print_token( "RPAREN"); }
"{"         { print_token( "LBRACE"); }
"}"         { print_token( "RBRACE"); }
"["         { print_token( "LBRACK"); }
"]"         { print_token( "RBRACK"); }
";"         { print_token( "SEMICOLON"); }
","         { print_token( "COMMA"); }
"\""        { print_token( "QUOTA"); }
"\n"        { printf("%-8s \t %s\n", "", "NEWLINE"); line_num++; if (next) { comment_num++; next = 0; } }
"="         { print_token(  "ASSIGN"); }
"+="        { print_token(  "ADD_ASSIGN"); }
"-="        { print_token(  "SUB_ASSIGN"); }
"*="        { print_token(  "MUL_ASSIGN"); }
"/="        { print_token(  "QUO_ASSIGN"); }
"%="        { print_token(  "REM_ASSIGN"); }
"&&"        { print_token(  "LAND"); }
"||"        { print_token(  "LOR"); }
"!"         { print_token(  "NOT"); }
"int32"     { print_token(  "INT"); }
"float32"   { print_token(  "FLOAT"); }
"string"    { print_token(  "STRING"); }
"bool"      { print_token(  "BOOL"); }
"case"      { print_token(  "CASE"); }
"switch"    { print_token(  "SWITCH"); }
"default"   { print_token(  "DEFAULT"); }
"if"        { print_token( "IF"); }
"else"      { print_token( "ELSE"); }
"for"       { print_token( "FOR"); }
"var"       { print_token(  "VAR"); }
"print"     { print_token(  "PRINT"); }
"println"   { print_token(  "PRINTLN"); }
"return"    { print_token(  "RETURN"); }
"true"      { print_token(  "TRUE"); }
"false"     { print_token(  "FALSE"); }
"func"      { print_token(  "FUNC"); }
"package"   { print_token(  "PACKAGE"); }


{inumber}   { print_token( "INT_LIT"); }
{fnumber}   { print_token( "FLOAT_LIT"); }
{id}        { print_token(  "IDENT"); }

{c_comment_start}  { BEGIN(insidecom); printf("%s", yytext);}

<insidecom>{c_comment_mid}  {char *str = (char *)malloc(strlen(yytext) * sizeof(char)); strncpy(str, yytext, strlen(yytext)-1);
                            printf("%s%-8s \t %s\n",str ,"\n", "C Comment");
                            comment_num++; line_num++; }

<insidecom>{c_comment_end}  {char *str = (char *)malloc(strlen(yytext) * sizeof(char)); strncpy(str, yytext, strlen(yytext)-2);
                            printf("%s%-8s \t %s\n", str,"*/", "C Comment");
                            next = 1; BEGIN 0; }

{cpp_comment}   {char *str = (char *)malloc(strlen(yytext) * sizeof(char)); str = strtok(yytext, "\n");
                printf("%-8s \t %s\n%-8s \t %s\n", str, "C++ Comment","", "NEWLINE");
                comment_num++; line_num++; }

{string}   {char *str = (char *)malloc(strlen(yytext) * sizeof(char)); strncpy(str, yytext, strlen(yytext)-1);
            str += 1;
            printf("%-8s \t %s\n", "\"", "QUOTA");
            printf("%-8s \t %s\n", str, "STRING_LIT"); 
            printf("%-8s \t %s\n", "\"", "QUOTA"); }


<<EOF>>     { line_num++; yyterminate(); }
[ \t]+      {;}
.           {;}
%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}

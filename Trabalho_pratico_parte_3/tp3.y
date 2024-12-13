%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern char *yytext;

void yyerror(const char *s);
extern double x,y,z;
extern int dg;
extern void setOnOff(int value);
%}

%union {
    char *id;
    int numInt;
    double numDou;
}

%token START END ON OFF TAKEOFF LAND TURN MOVE FLY SETSHIP SETSPACE
%token <id> <str> ID
%token <numInt> INT
%token <numDou> DOUBLE
%token LPAREN RPAREN COLON SEMICOLON GREATER
%start instrucoes
%type <id> SETSHIP
%%

instrucoes:
    START LPAREN ID RPAREN COLON lista_instrucoes COLON END { 
            printf("Instruções válidas!\n"); 
        }
    | START LPAREN ID RPAREN COLON COLON END { 
            printf("Análise correta, mas código sem instruções!\n"); 
        }
    | error { yyerror("Erro sintático!\n"); }
    ;
;
lista_instrucoes:
    instrucao
    | lista_instrucoes instrucao
    ;
;
instrucao:    
    ON ID SEMICOLON
    | OFF SEMICOLON
    | TAKEOFF SEMICOLON
    | LAND SEMICOLON
    | TURN SEMICOLON
    | MOVE SEMICOLON
    | FLY SEMICOLON
    | SETSHIP DOUBLE DOUBLE DOUBLE INT INT GREATER SEMICOLON {
            printf("\n### SETSHIP: %s  x:%f, y:%f, z:%f, DG:%d Status:%d \n", $1,$2,$3,$4,$5,$6); 
            x=$2; y=$3; z=$4; dg=$5; 
            setOnOff($6);
            }
    | SETSPACE SEMICOLON 
    ;
;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main() {
    
    yyparse();
    return 0;
}
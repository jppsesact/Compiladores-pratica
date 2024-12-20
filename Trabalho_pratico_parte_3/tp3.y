%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern char *yytext;

void yyerror(const char *s);
extern double x,y,z,xMin,yMin,xMax,yMax;
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
%type <id> SETSHIP SETSPACE
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
    ON SEMICOLON
    | OFF SEMICOLON
    | TAKEOFF SEMICOLON
    | LAND SEMICOLON
    | TURN SEMICOLON
    | MOVE SEMICOLON
    | FLY SEMICOLON
    | SETSHIP DOUBLE DOUBLE DOUBLE INT INT GREATER SEMICOLON {
            printf("\n### SETSHIP: %s  x:%lf, y:%lf, z:%lf, DG:%d Status:%d \n", $1,$2,$3,$4,$5,$6); 
            x=$2; y=$3; z=$4; dg=$5; 
            setOnOff($6);
            }
    | SETSPACE DOUBLE DOUBLE DOUBLE DOUBLE GREATER SEMICOLON {
            printf("\n### SETSPACE: xMin:%lf, yMin:%lf, xMax:%lf, yMax:%lf\n", $2,$3,$4,$5); 
            xMin=$2; yMin=$3; xMax=$4; yMax=$5;
            if (xMax<=xMin || yMax<=yMin) {
                printf("-- ERROR: Espaço inválido ou inexistente\n");
                exit(-1);
            }
    }
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
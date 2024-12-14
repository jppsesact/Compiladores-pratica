  /*
   * NOTA: As intruções abaixo indicam ao flex para não gerar código C para as respetivas funções, evitando warnings.
   * Dúvida: Será apenas usado quando a secção de declarações está vazia? TBC
  */   

%option noyywrap
  /*
   * Commands to create the lexical analyser:
   * - lex -o tp2.c tp2.l
   * - cc tp2.c -o tp2 -ll
   * - ./tp2 < teste.txt
   */

  /***************/
  /* DECLARAÇÔES */
  /***************/

  /*
   * Exclusive state | Contexto exclusivo: %x
   * Inclusive state | Contexto inclusivo: %s
   */
%x MULTI_LINE_COMMENT COMMAND_ON COMMAND_TURN COMMAND_MOVE COMMAND_FLY 
%x SET_SHIP_1 SET_SHIP_2 SET_SHIP_3 SET_SHIP_4 SET_SHIP_5
%x SET_SPACE_1 SET_SPACE_2 SET_SPACE_3 SET_SPACE_4 SET_SPACE_5 SET_SPACE_6
%{
  #include <stdbool.h>
  #include <math.h>
  #include "tp3.tab.h"
  /* Constantes */
  const int DECIMAL = 6;
  /* Posicao inicial da nave */
  double x = 0.0f, y = 0.0f, z = 0.0f;
  double xMin = 0.0f, yMin = 0.0f;
  double xMax = 0.0f, yMax = 0.0f;
  /* Estado inicial da nave */
  bool on = false, landed = true, turn = false, move = false, fly = false;
  /* Info instrucoes ID, DIR, DG, NR1, NR2 */
  char * id, * dir;
  int dg, nr1, nr2;
  /* Estado corrente */
  double orientation = 0;
  /* Functions declaration */
  double setOrientation(int degree);
  double getRadians(double degree);
  double getRoundedValue(double base, int decimal);
  void setOnOff(int value);
  /* Parte 3 */
  int column = 1, ship_on;

%}



ID      [aeiouAEIOU][a-zA-Z][0-9][0-9][0-9]?
DIR     [LR]
DG      [1-9]|[1-9][0-9]|[12][0-9][0-9]|3[0-5][0-9]
NR1     [1-9][0-9]*
NR2     -?[1-9][0-9]*
NR3     -?[1-9][0-9]*|0
BNR     -?[0-9]+


 /* Parte 3 */
ON          [01]                  

%%

    /***************/
  /*   REGRAS    */
  /***************/
  /*
   * Inline Comment
   */
"\/\/".*$                         { printf("-- INFO: Inline comment: %s\n", yytext); }
  /*
   * Multiline Comment
   */
"/*"                              { BEGIN(MULTI_LINE_COMMENT); printf("-- INFO: Multiline comment start.\n"); }
<MULTI_LINE_COMMENT>.             { ; }
<MULTI_LINE_COMMENT>\r|\n|\r\n    { ; }
<MULTI_LINE_COMMENT>"*/"          { printf("-- INFO: Multiline comment end.\n"); BEGIN(INITIAL); }


  /*
   * "<On--"{ID}">"                  { printf("acao(ligar): %s\n", yytext); }
   */
"<On--"                           { BEGIN(COMMAND_ON); }
<COMMAND_ON>{ID}                  { id = strdup(yytext); }
<COMMAND_ON>">"                   {
                                    if (on) {
                                      printf("-- WARNING: A nave %s já se encontra ligada!\n", id);
                                    } else {
                                      on = true;
                                      printf("acao(ligar)\n");
                                      printf("-- INFO: Nave %s ligada com sucesso!\n", id);
                                    }
                                    BEGIN(INITIAL); 
                                    return ON;
                                  }
  /*
   * "<Off>"
   */
"<Off>"                           {
                                    /* Validar se é pedido para desligar a nave quando esta já se encontra desligada. */
                                    if(on) {
                                      /* Validar se é pedido para desligar quando não existe anteriormente uma instrução de <Land>. */
                                      if(landed) {
                                        on = false;
                                        printf("acao(desligar)\n");
                                        printf("-- INFO: Nave %s desligada com sucesso!\n", id);
                                      } else {
                                        printf("-- WARNING: Só é possível desligar a nave %s após a ter aterrado.", id);
                                      }
                                    } else {
                                      printf("-- WARNING: A nave %s já se encontra desligada!\n", id);
                                    }
                                    return OFF;
                                  }
    /*
   * "<Take-off>"
   */                                  
"<Take-Off>"                      {
                                    if(on) {
                                      landed = false;
                                      printf("-- INFO: Nave %s descolada com sucesso!\n-- Movimentos no plano vertical: ATIVADO\n-- Possibilidade de desligar a nave: DESABILITADO\n", id);
                                    } else {
                                      printf("-- WARNING: A nave %s encontra-se desligada. Não é possível descolar!\n", id);
                                    }
                                    return TAKEOFF;
                                  }
  /*
   * "<Land>"
   */
"<Land>"                          {
                                    if(on) {
                                      if(landed) {
                                        printf("-- WARNING: A nave %s já se encontra aterrada!\n", id);
                                      } else {
                                        /* Validar se é pedido para aterrar se a nave não estiver na posição 0 no plano vertical. */
                                        if (z == 0) {
                                          landed = true;
                                          printf("-- INFO: Nave %s aterrada com sucesso!\n-- Movimentos no plano vertical: DESABILITADO\n-- Possibilidade de desligar a nave: ATIVADO\n", id);
                                        } else {
                                          printf("-- WARNING: Não é possível aterrar a nave %s sem que esta se encontre na posição 0 do plano vertical!\n", id);
                                        }
                                      }
                                    } else {
                                      printf("-- WARNING: A nave %s encontra-se desligada e, consequentemente, aterrada!\n", id);
                                    }
                                    return LAND;
                                  }                               
  /*
   * "<Turn--{DIR}""--"{DG}">"       { printf("virar a nave: %s\n", yytext); }
   */
"<Turn--"                         {
                                    BEGIN(COMMAND_TURN);
                                    printf("--DUBUG: context COMMAND_TURN");
                                    turn = true;
                                  }
<COMMAND_TURN>{DIR}               { dir = strdup(yytext); }
<COMMAND_TURN>"--"                { ; }
<COMMAND_TURN>{DG}                {
                                    dg = atoi(yytext);
                                    if(strcmp(dir, "L") == 0) {
                                      orientation = setOrientation(orientation - dg);
                                    } else if(strcmp(dir, "R") == 0) {
                                      orientation = setOrientation(orientation + dg);
                                    } else {
                                      printf("-- WARNING: It is NOT supposed to be here...");
                                    }
                                  }
<COMMAND_TURN>{BNR}               {
                                    printf("-- WARNING: Invalid DG value (%d)! 'Turn' instruction ignored.\n", atoi(yytext));
                                    turn = false;
                                  }
<COMMAND_TURN>">"                 {
                                    if (turn) {
                                      printf("-- DEBUG: <Turn--%s--%d>, Orientação da Nave = %f\n", dir, dg, orientation);
                                    }
                                    BEGIN(INITIAL); 
                                    return TURN;
                                  }
  /*
   * "<Move--"{NR1}">"               { printf("move(x,y,z): %s\n", yytext); }
   */
"<Move--"                         {
                                    // TODO: CONTINUE HERE!!!
                                    BEGIN(COMMAND_MOVE);
                                    move = true;
                                  }
<COMMAND_MOVE>{NR1}               { nr1 = atoi(yytext); }
<COMMAND_MOVE>{BNR}               {
                                    printf("-- WARNING: Invalid NR1 value (%d)! 'Move' instruction ignored.\n", atoi(yytext));
                                    move = false;
                                  }
<COMMAND_MOVE>">"                 {
                                    if(move) {
                                      // Validation check
                                      float dx = nr1 * getRoundedValue(sin(getRadians(orientation)), DECIMAL);
                                      float dy = nr1 * getRoundedValue(cos(getRadians(orientation)), DECIMAL);
                                      if(on) {
                                        if (x+dx >= xMin && x+dx <= xMax && y+dy >= yMin && y+dy <= yMax) {
                                          printf("-- DEBUG: <Move--%d>, Orientação da Nave = %f\n", nr1, orientation);
                                          //
                                          // Set x
                                          //printf("-- DEBUG: old x = %f, nr1 = %d, sin(%fº) = %f\n", x, nr1, orientation, sin(getRadians(orientation)));
                                          x += dx;
                                          //printf("-- DEBUG: new x = %f\n", x);
                                          //
                                          // Set y
                                          //printf("-- DEBUG: old y = %f, nr1 = %d, cos(%fº) = %f\n", y, nr1, orientation, cos(getRadians(orientation)));
                                          y += dy;
                                          //printf("-- DEBUG: new y = %f\n", y);
                                          //
                                          printf("move(%lf, %lf, %lf)\n", x, y, z);
                                        } else {
                                          printf("-- WARNING: Comando inválido! Está tentar deslocar a nave para for do espaço permitido.\n");
                                        }
                                      } else {
                                        printf("-- WARNING: Comando inválido! A nave %s encontra-se desligada.\n", id);
                                      }
                                    }
                                    BEGIN(INITIAL);
                                    return MOVE; 
                                  }
  /*
   * "<Fly--"{NR2}">"                { printf("move(x,y,z): %s\n", yytext); }
   */
"<Fly--"                          {
                                    BEGIN(COMMAND_FLY);
                                    fly = true;
                                  }
<COMMAND_FLY>{NR2}                { nr2 = atoi(yytext); }
<COMMAND_FLY>{BNR}                {
                                    printf("-- WARNING: Invalid DG value (%d)! 'Fly' instruction ignored.\n", atoi(yytext));
                                    fly = false;
                                  }
<COMMAND_FLY>">"                  {
                                    if (fly) {
                                      // Validation check
                                      if(on) {
                                        if(landed) {
                                          // Validar se é pedido para voar quando não existe uma instrução de <Take-Off> que o possibilite
                                          printf("-- WARNING: Comando inválido! A nave %s encontra-se aterrada.\n", id);
                                        } else {
                                          // Validar se é recebido um valor de <Fly--NR2> que origine um movimento da nave para valores negativos de zz.
                                          if (z + nr2 < 0) {
                                            printf("-- WARNING: Comando inválido! O valor %d origina um movimento para um valor negativo de zz (%f).\n", nr2, z + nr2);
                                          } else {
                                            z += nr2;
                                            printf("move(%lf, %lf, %lf)\n", x, y, z);
                                          }
                                        }
                                      } else {
                                        printf("-- WARNING: Comando inválido! A nave %s encontra-se desligada.\n", id);
                                      }
                                    }
                                    BEGIN(INITIAL);
                                    return FLY; 
                                  }
  /*  Parte 3 
   * "<Set-Ship-->"
   */  
"<Set-Ship--"       { BEGIN(SET_SHIP_1); return SETSHIP;}
<SET_SHIP_1>{NR3}   { 
                        BEGIN(SET_SHIP_2);
                        yylval.numDou = atof(yytext);                      
                        return DOUBLE;
                    }
<SET_SHIP_2,SET_SHIP_3,SET_SHIP_4,SET_SHIP_5>"--"        { ; }
<SET_SHIP_2>{NR3}   { 
                        BEGIN(SET_SHIP_3);                        
                        yylval.numDou = atof(yytext); 
                        return DOUBLE;
                    }
<SET_SHIP_3>{NR2}   { 
                        BEGIN(SET_SHIP_4);
                        yylval.numDou = atof(yytext);
                        return DOUBLE;                     
                    }
<SET_SHIP_4>{DG}    {
                        BEGIN(SET_SHIP_5); 
                        yylval.numInt = atoi(yytext);
                        return INT;
                    }
<SET_SHIP_5>{ON}    {   
                        yylval.numInt = atoi(yytext); 
                        return INT;}
<SET_SHIP_5>">"     {
                        BEGIN(INITIAL); 
                        return GREATER;
                    }  
  /*  Parte 3 
   * "<Set-Space-->"
   */  
"<Set-Space--"       { BEGIN(SET_SPACE_1);  return SETSPACE; }
<SET_SPACE_1>{NR3}   { 
                        BEGIN(SET_SPACE_2);
                        yylval.numDou = atof(yytext);
                        return DOUBLE;                                                
                    }

<SET_SPACE_2,SET_SPACE_3,SET_SPACE_4>"--"        { ; }
<SET_SPACE_2>{NR3}   { 
                        BEGIN(SET_SPACE_3);
                        yylval.numDou = atof(yytext);                        
                        return DOUBLE;
                    }
<SET_SPACE_3>{NR3}   { 
                        BEGIN(SET_SPACE_4);
                        yylval.numDou = atof(yytext);                        
                        return DOUBLE;
                    }
<SET_SPACE_4>{NR3}    {
                        yylval.numDou = atof(yytext);                        
                        return DOUBLE;
                    }
<SET_SPACE_4>">"     {                    
                        BEGIN(INITIAL); 
                        return GREATER;
                    }  
{ID}        { 
                yylval.id=yytext;
                return ID;
            }            
START       { return START; }
END         { return END; }
"("         { return LPAREN; }
")"         { return RPAREN; }
":"         { return COLON; }
";"         { return SEMICOLON; }
">"         { return GREATER; }

  /*
   * Remaining 
   */
.                                 { ; }
\r|\n|\r\n                        { ; }
<<EOF>>                           {
                                    printf("-- INFO: Lexical analysis completed!\n");
                                    return 0;
                                  }

%%

/***************/
/*  ROTINAS C  */
/***************/

/*
 * Get orientation
 * @degree  the degree value to normalize in the interval [0-360[
 * @return  the orientation (i.e., normalized degree)
 */
double setOrientation(int degree) { return degree % 360; }

/*
 * Get radians 
 * @degree  the degree value to convert to radian
 * @return  the radian value
 */
double getRadians(double degree) { return degree * (M_PI / 180); }

/*
 * Get rounded value
 * @base      the base value
 * @decimal   the number of decimal parts
 * @return    rounded value 
 */
double getRoundedValue(double base, int decimal) { return ((int) round(base * pow(10, decimal)) / pow(10, decimal)); }

void setOnOff(int value) {
  if (value) on = true;
  else on = false;
}
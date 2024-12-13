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

%{
  #include <stdbool.h>
  #include <math.h>
  /* Constantes */
  const int DECIMAL = 6;
  /* Posicao inicial da nave */
  double x = 0.0f, y = 0.0f, z = 0.0f;
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
%}

  /*
   * NOTA: As intruções abaixo indicam ao flex para não gerar código C para as respetivas funções, evitando warnings.
   * Dúvida: Será apenas usado quando a secção de declarações está vazia? TBC
   * %option nounput
   * %option noinput
   * %option noyywrap
   */

ID      [aeiouAEIOU][a-zA-Z][0-9][0-9][0-9]?
DIR     [LR]
DG      [1-9]|[1-9][0-9]|[12][0-9][0-9]|3[0-5][0-9]
NR1     [1-9][0-9]*
NR2     -?[1-9][0-9]*
BNR     -?[0-9]+

 /*
  * Outra solução seria, p. ex:
  * VOGAL   [aeiouAEIOU]
  * LETRA   [a-zA-Z]
  * DIGITO  [0-9]
  * UNIDADE [1-9]
  * DEZENA  [0-5]
  * CENTENA [1-2]
  * ...
  * 
  * E nas regras:
  * "<On--"{VOGAL}{LETRA}{DIGITO}{DIGITO}">"          { printf("<On--ID>: %s\n", yytext); }
  * "<On--"{VOGAL}{LETRA}{DIGITO}{DIGITO}{DIGITO}">"  { printf("<On--ID>: %s\n", yytext); }
  * ...
  */

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
                                  }
  /*
   * "<Turn--{DIR}""--"{DG}">"       { printf("virar a nave: %s\n", yytext); }
   */
"<Turn--"                         {
                                    BEGIN(COMMAND_TURN);
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
                                      if(on) {
                                        printf("-- DEBUG: <Move--%d>, Orientação da Nave = %f\n", nr1, orientation);
                                        //
                                        // Set x
                                        //printf("-- DEBUG: old x = %f, nr1 = %d, sin(%fº) = %f\n", x, nr1, orientation, sin(getRadians(orientation)));
                                        x += nr1 * getRoundedValue(sin(getRadians(orientation)), DECIMAL);
                                        //printf("-- DEBUG: new x = %f\n", x);
                                        //
                                        // Set y
                                        //printf("-- DEBUG: old y = %f, nr1 = %d, cos(%fº) = %f\n", y, nr1, orientation, cos(getRadians(orientation)));
                                        y += nr1 * getRoundedValue(cos(getRadians(orientation)), DECIMAL);
                                        //printf("-- DEBUG: new y = %f\n", y);
                                        //
                                        printf("move(%lf, %lf, %lf)\n", x, y, z);
                                      } else {
                                        printf("-- WARNING: Comando inválido! A nave %s encontra-se desligada.\n", id);
                                      }
                                    }
                                    BEGIN(INITIAL); 
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
                                  }
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

/*
 * Main Function
 * @argc    the number of elements in 'argv' array
 * @argv    arguments array
 * @return  integer code if error; 0 otherwise
 */
int main(int argc, char * argv[]) {
  yylex();
  return 0;
}

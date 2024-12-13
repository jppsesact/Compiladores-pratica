/* 
Considere que a nave se poderá movimentar após receber as instruções identificadas, e que
estas são executadas instantaneamente, logo após serem recebidas, e de forma sequencial.
Adicionalmente, é assumido que:
• a nave se pode movimentar no plano horizontal tanto em terra como no ar
• é sempre obrigatória uma instrução que permita levantar voo, antes de serem
permitidos movimentos no plano vertical
Considere também que, no estado inicial, a nave se encontra desligada, na posição (x, y, z) =
(0, 0, 0) em que os 3 valores da tripla representam as coordenadas nos eixos xx, yy, e zz,
respetivamente, e que está virada na direção +yy, ou seja, recebendo uma instrução para
andar 1 posição, ficaria em (x , y, z) = (0 , 1, 0)

B. Crie um ficheiro de texto para teste, para ser usado como entrada do analisador léxico
desenvolvido, que represente uma versão do pergaminho encontrado pelos nossos
exploradores, e que contenha a sequência de instruções necessárias para que a nave consiga,
partindo do estado inicial, movimentar-se, passando pelas posições (50,50,0) e (0,0,50),
voltando por fim ao estado inicial (4 valores). */

// TESTE INLINE COMMENT

Ligar a nave: <On--AG369> | Nave GS369 ligada na posição (0,0,0)
Mover nave 50 posições no plano horizontal na direccao +yy: <Move--50> | Nave na posição (0,50,0) e direcção +yy
Virar a nave 90º para a direcção +xx: <Turn--R--90> | Nave na posicção (0, 50, 0) e direcção +xx
Mover nave 50 posições no plano horizontal na direcção +xx: <Move--50> | Nave na posicção (50, 50, 0) e direcção +xx
### NAVE NA POSICAO (50,50,0) ###
Permitir a descolagem da nave: <Take-Off> | Nave na posicção (50, 50, 0) e direcção +xx
Mover nave 50 posições no plano vertical na direcção +zz: <Fly--50> | Nave na posicção (50, 50, 50) e direcção +xx
Virar a nave 90º para direcção -yy: <Turn--R--90> | Nave na posicção (50, 50, 50) e direcção -yy
Mover nave 50 posições no plano horizontal na direcção -yy: <Move--50> | Nave na posicção (50, 0, 50) e direcção -yy
Virar a nave 90º para direcção -xx: <Turn--R--90> | Nave na posicção (50, 0, 50) e direcção -yy
Mover nave 50 posições no plano horizontal na direcção -xx: <Move--50> | Nave na posicção (0, 0, 50) e direcção -xx
### NAVE NA POSICAO (0,0,50) ###
Mover nave 50 posições no plano vertical na direcção -zz: <Fly---50> | Nave na posicção (0, 0, 0) e direcção -xx
Virar nave para posição inicial +yy: <Turn--R--90> | Nave na posicção (0, 0, 0) e direcção +yy
Permitir aterragem nave: <Land> | Nave na posicção (0, 0, 0) e direcção +yy
Desligar a nave: <Off> | Nave na posicção (0, 0, 0) e direcção +yy
### NAVE NA POSICAO INICIAL ###

OTHER TESTS
<On--AG36>
<Turn--R--360>
<Turn--R---450>
<Turn--R--0>
<Turn--R--20>
<Turn--R--45>
<Turn--L--90>
<Fly--0>
<Fly---0>
<Take-Off>
<Fly---100>
<Turn--L--359>
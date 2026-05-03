/* Apostas_Ctx
 * Author: Superframe Force
 * Creation date: 01/05/2026
 */
MACHINE
    Apostas_Ctx

SETS
    STATUS_EVENTO = {agendado, aberto, finalizado, cancelado, suspenso};
    STATUS_APOSTA = {pendente, ganha, perdida, devolvida, revogada_usuario};
    OPCAO_RESULTADO = {vitoria_A, empate, vitoria_B};
    STATUS_RETORNO = {sucesso, erro_saldo_insuficiente, erro_evento_invalido, erro_limite_excedido, erro_nao_encontrado, erro_estado_invalido}

CONSTANTS
    MAX_USERS,
    MAX_EVENTS,
    MAX_APOSTAS,
    TAXA_CASA,
    APOSTA_MINIMA

PROPERTIES
    /* Tipagem das Constantes */
    MAX_USERS : NAT1 &
    MAX_EVENTS : NAT1 &
    MAX_APOSTAS : NAT1 &
    TAXA_CASA : NAT &
    APOSTA_MINIMA : NAT1 &

    /* Valores Concretos (ajuste conforme a capacidade computacional do ProB) */
    MAX_USERS = 1000 &
    MAX_EVENTS = 100 &
    MAX_APOSTAS = 10000 &
    TAXA_CASA = 10 & /* Representa 10% de retenção do bolo */
    APOSTA_MINIMA = 5 /* Valor mínimo em moeda inteira */

END

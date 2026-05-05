/* Apostas_Ctx
 * Author: Superframe Force
 * Creation date: 01/05/2026
 */
MACHINE
    Apostas_Ctx

SETS
    STATUS_EVENTO = {agendado, aberto, finalizado, cancelado, suspenso};
    
    STATUS_APOSTA = {pendente, ganha, perdida, devolvida, revogada_usuario};
    
    OPCAO_RESULTADO = {vitoria_A, empate, vitoria_B, indefinido};
    
    STATUS_CONTA = {
        ativa, 
        sob_analise, 
        suspensa
    }

CONSTANTS
    MAX_USERS,
    MAX_EVENTS,
    MAX_APOSTAS,
    TAXA_CASA,
    APOSTA_MINIMA

PROPERTIES
    /* Tipagem das Constantes */
    MAX_USERS : NAT1 & MAX_USERS = 5 & 
    MAX_EVENTS : NAT1 & MAX_EVENTS = 5 & 
    MAX_APOSTAS : NAT1 & MAX_APOSTAS = 10 & 
    TAXA_CASA : NAT & TAXA_CASA = 10 & 
    APOSTA_MINIMA : NAT1 & APOSTA_MINIMA = 3

END

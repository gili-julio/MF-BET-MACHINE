/* Apostas
 * Author: Superframe Force
 * Creation date: 01/05/2026
 */
MACHINE
    Apostas

SEES
    Apostas_Ctx

VARIABLES
    saldo_casa,
    usuarios,
    saldo_usuario,
    eventos,
    status_evento,
    arrecadacao_evento,
    apostas,
    aposta_usuario,
    aposta_evento,
    aposta_valor,
    aposta_palpite,
    status_aposta_map,
    status_conta,
    resultado_evento,
    contador_aposta,
    contador_evento,
    contador_usuario
    
INVARIANT
    /* Tipagem Variáveis de Estado */
    saldo_casa : NAT &
    usuarios <: NAT &
    card(usuarios) <= MAX_USERS &
    saldo_usuario : usuarios --> NAT & 
    status_conta : usuarios --> STATUS_CONTA &

    contador_evento : NAT1 & 
    contador_evento <= MAX_EVENTS + 1 &
    
    contador_aposta : NAT1 & 
    contador_aposta <= MAX_APOSTAS + 1 &
    
    contador_usuario : NAT1 & 
    contador_usuario <= MAX_USERS + 1 &

    /* Tipagem Variáveis de Eventos */
    eventos <: NAT &
    card(eventos) <= MAX_EVENTS &
    status_evento : eventos --> STATUS_EVENTO &
    arrecadacao_evento : eventos --> NAT &
    
    /* Tipagem do Resultado */
    resultado_evento : eventos --> OPCAO_RESULTADO &

    /* Tipagem das Apostas */
    apostas <: NAT &
    card(apostas) <= MAX_APOSTAS &
    aposta_usuario : apostas --> usuarios &
    aposta_evento : apostas --> eventos &
    aposta_valor : apostas --> NAT1 & 
    aposta_palpite : apostas --> OPCAO_RESULTADO &
    status_aposta_map : apostas --> STATUS_APOSTA &
    
    /* Regras de Negócio */
    !ev.(ev : eventos => arrecadacao_evento(ev) >= 0) &
    
    /* 1. Regra de Vitória */
    !(ap).(ap : apostas & status_aposta_map(ap) = ganha => 
           aposta_evento(ap) : dom(resultado_evento) & 
           aposta_palpite(ap) = resultado_evento(aposta_evento(ap))) &

    /* 2. Regra de Derrota */
    !(ap).(ap : apostas & status_aposta_map(ap) = perdida => 
           aposta_evento(ap) : dom(resultado_evento) & 
           aposta_palpite(ap) /= resultado_evento(aposta_evento(ap))) &

    /* 3. Integridade Temporal de Eventos e Resultados */
    !(ev).(ev : eventos & status_evento(ev) /= finalizado => resultado_evento(ev) = indefinido) &
           
    /* 4. Integridade das Apostas */
    !(ap).(ap : apostas & status_aposta_map(ap) = pendente => 
           status_evento(aposta_evento(ap)) /= agendado) 

INITIALISATION
    saldo_casa := 0 ||
    usuarios := {} ||
    saldo_usuario := {} ||
    eventos := {} ||
    status_evento := {} ||
    arrecadacao_evento := {} ||
    apostas := {} ||
    aposta_usuario := {} ||
    aposta_evento := {} ||
    aposta_valor := {} ||
    aposta_palpite := {} ||
    status_aposta_map := {} ||
    status_conta := {} ||
    resultado_evento := {} ||
    contador_aposta := 1 ||
    contador_evento := 1 ||
    contador_usuario := 1
    
OPERATIONS

    /* --- Operações de Caixa e Gestão --- */

    aportar_saldo_casa(valor) =
    PRE valor : NAT
    THEN
        saldo_casa := saldo_casa + valor
    END;

    novo_user_id <-- cadastrar_usuario = 
    PRE contador_usuario <= MAX_USERS
    THEN 
        usuarios := usuarios \/ {contador_usuario} || 
        saldo_usuario(contador_usuario) := 0 || 
        status_conta(contador_usuario) := ativa || 
        novo_user_id := contador_usuario ||
        contador_usuario := contador_usuario + 1
    END;

    depositar(user_id, valor) =
    PRE 
        user_id : NAT &
        user_id : usuarios & 
        valor : NAT &
        status_conta(user_id) = ativa
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) + valor
    END;

    sacar(user_id, valor) =
    PRE 
        user_id : NAT &
        user_id : usuarios & 
        valor : NAT &
        status_conta(user_id) = ativa &
        saldo_usuario(user_id) >= valor
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) - valor
    END;

    /* --- Operações de Eventos --- */

    novo_evento_id <-- criar_evento = 
    PRE contador_evento <= MAX_EVENTS
    THEN 
        eventos := eventos \/ {contador_evento} || 
        status_evento(contador_evento) := agendado || 
        arrecadacao_evento(contador_evento) := 0 || 
        resultado_evento(contador_evento) := indefinido || 
        novo_evento_id := contador_evento ||
        contador_evento := contador_evento + 1
    END;

    abrir_evento(evento_id) =
    PRE 
        evento_id : NAT &
        evento_id : eventos &
        status_evento(evento_id) = agendado
    THEN
        status_evento(evento_id) := aberto
    END;

    nova_aposta_id <-- realizar_aposta(user_id, evento_id, palpite, valor) = 
    PRE 
        user_id : NAT &
        evento_id : NAT &
        user_id : usuarios & 
        evento_id : eventos & 
        palpite : OPCAO_RESULTADO & 
        palpite /= indefinido &
        valor : NAT & 
        valor >= APOSTA_MINIMA &
        contador_aposta <= MAX_APOSTAS &
        status_conta(user_id) = ativa &
        status_evento(evento_id) = aberto &
        saldo_usuario(user_id) >= valor
    THEN 
        apostas := apostas \/ {contador_aposta} || 
        aposta_usuario(contador_aposta) := user_id || 
        aposta_evento(contador_aposta) := evento_id || 
        aposta_valor(contador_aposta) := valor || 
        aposta_palpite(contador_aposta) := palpite || 
        status_aposta_map(contador_aposta) := pendente || 
        
        /* Fluxo Financeiro Simultâneo */ 
        saldo_usuario(user_id) := saldo_usuario(user_id) - valor || 
        arrecadacao_evento(evento_id) := arrecadacao_evento(evento_id) + valor || 
        
        nova_aposta_id := contador_aposta ||
        contador_aposta := contador_aposta + 1
    END;
    
    revogar_aposta(aposta_id) =
    PRE 
        aposta_id : NAT &
        aposta_id : apostas &
        (status_evento(aposta_evento(aposta_id)) = aberto or status_evento(aposta_evento(aposta_id)) = agendado) &
        status_aposta_map(aposta_id) = pendente
    THEN
        /* Devolve o dinheiro para o usuário */
        saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + aposta_valor(aposta_id) ||
        /* Retira o dinheiro do balaio do evento */
        arrecadacao_evento(aposta_evento(aposta_id)) := arrecadacao_evento(aposta_evento(aposta_id)) - aposta_valor(aposta_id) ||
        /* Atualiza o status da aposta para não ser mais cobrada */
        status_aposta_map(aposta_id) := revogada_usuario
    END;
    
    finalizar_evento(evento_id, resultado_vencedor) =
    PRE 
        evento_id : NAT &
        evento_id : eventos & 
        resultado_vencedor : OPCAO_RESULTADO &
        resultado_vencedor /= indefinido &
        status_evento(evento_id) = aberto
    THEN
        /* Verifica se EXISTE (#) pelo menos uma aposta neste evento com o palpite vencedor */
        IF (#xx.(xx : apostas & aposta_evento(xx) = evento_id & aposta_palpite(xx) = resultado_vencedor)) THEN
            /* Cenário Normal: Há vencedores. A casa recolhe apenas a sua comissão blindada. */
            saldo_casa := saldo_casa + ((arrecadacao_evento(evento_id) * TAXA_CASA) / 100) ||
            status_evento(evento_id) := finalizado ||
            resultado_evento(evento_id) := resultado_vencedor
        ELSE
            /* Cenário "Zebra": Ninguém acertou o palpite. A casa embolsa o bolo INTEIRO. */
            saldo_casa := saldo_casa + arrecadacao_evento(evento_id) ||
            status_evento(evento_id) := finalizado ||
            resultado_evento(evento_id) := resultado_vencedor
        END
    END;

    cancelar_evento(evento_id) =
    PRE 
        evento_id : NAT &
        evento_id : eventos & 
        status_evento(evento_id) = aberto
    THEN
        status_evento(evento_id) := cancelado
    END;
    
    suspender_evento(evento_id) =
    PRE 
        evento_id : NAT &
        evento_id : eventos & 
        status_evento(evento_id) = aberto
    THEN
        status_evento(evento_id) := suspenso
    END;

    retomar_evento(evento_id) =
    PRE 
        evento_id : NAT &
        evento_id : eventos & 
        status_evento(evento_id) = suspenso
    THEN
        status_evento(evento_id) := aberto
    END;
    
    resgatar_premio(aposta_id) = 
    PRE 
        aposta_id : NAT &
        aposta_id : apostas & 
        status_conta(aposta_usuario(aposta_id)) = ativa &
        status_evento(aposta_evento(aposta_id)) = finalizado &
        status_aposta_map(aposta_id) = pendente
    THEN 
        IF (aposta_palpite(aposta_id) = resultado_evento(aposta_evento(aposta_id))) THEN
            /* O usuário acertou: Cálculo interno utilizando SIGMA para as apostas vencedoras */ 
            ANY montante_liquido, total_vencedor WHERE
                montante_liquido : NAT &
                total_vencedor : NAT1 &
                montante_liquido = arrecadacao_evento(aposta_evento(aposta_id)) - ((arrecadacao_evento(aposta_evento(aposta_id)) * TAXA_CASA) / 100) &
                total_vencedor = SIGMA(xx).(xx : apostas & aposta_evento(xx) = aposta_evento(aposta_id) & aposta_palpite(xx) = resultado_evento(aposta_evento(aposta_id)) | aposta_valor(xx))
            THEN
                /* (Valor Apostado * Montante Líquido) / Total Apostado nas Vencedoras */
                saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + ((aposta_valor(aposta_id) * montante_liquido) / total_vencedor) || 
                status_aposta_map(aposta_id) := ganha
            END
        ELSE
            /* O usuário errou */
            status_aposta_map(aposta_id) := perdida
        END
    END;

    resgatar_reembolso(aposta_id) =
    PRE 
        aposta_id : NAT &
        aposta_id : apostas &
        status_evento(aposta_evento(aposta_id)) = cancelado &
        status_aposta_map(aposta_id) = pendente
    THEN
        saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + aposta_valor(aposta_id) ||
        status_aposta_map(aposta_id) := devolvida
    END;
    
    sacar_lucro_casa(valor) =
    PRE 
        valor : NAT &
        saldo_casa >= valor
    THEN
        saldo_casa := saldo_casa - valor
    END;
    
    /* --- Operações de Segurança e Auditoria --- */

    ativar_usuario(user_id) =
    PRE 
        user_id : NAT &
        user_id : usuarios &
        status_conta(user_id) /= ativa
    THEN
        status_conta(user_id) := ativa
    END;

    colocar_conta_em_analise(user_id) =
    PRE 
        user_id : NAT &
        user_id : usuarios &
        status_conta(user_id) /= sob_analise
    THEN
        status_conta(user_id) := sob_analise
    END;

    suspender_usuario(user_id) =
    PRE 
        user_id : NAT &
        user_id : usuarios &
        status_conta(user_id) /= suspensa
    THEN
        status_conta(user_id) := suspensa
    END;
    
    /* --- Consultas --- */
    
    saldo_atual <-- consultar_saldo_casa = 
    BEGIN 
        saldo_atual := saldo_casa 
    END;
    
    saldo_atual <-- consultar_saldo_usuario(user_id) = 
    PRE 
        user_id : NAT &
        user_id : usuarios 
    THEN 
        saldo_atual := saldo_usuario(user_id)
    END
END
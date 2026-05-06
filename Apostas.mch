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
    is_admin,
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
    is_admin : usuarios --> BOOL &

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
           status_evento(aposta_evento(ap)) /= agendado) &
       
    /* 5. Todo evento finalizado tem um resultado válido */
    !(ev).(ev : eventos & status_evento(ev) = finalizado => resultado_evento(ev) /= indefinido) &
    
    /* 6. Apostas só podem estar ganhas ou perdidas se o evento acabou */
    !(ap).(ap : apostas & status_aposta_map(ap) : {ganha, perdida} => status_evento(aposta_evento(ap)) = finalizado) &
    
    /* 7. Uma aposta só é devolvida se o evento foi cancelado */
    !(ap).(ap : apostas & status_aposta_map(ap) = devolvida => status_evento(aposta_evento(ap)) = cancelado) &
    
    /* 8. A arrecadação do evento deve bater com a soma das apostas ativas */
    !(ev).(ev : eventos & status_evento(ev) : {aberto, suspenso} => 
           arrecadacao_evento(ev) = SIGMA(ap).(ap : apostas & aposta_evento(ap) = ev & status_aposta_map(ap) = pendente | aposta_valor(ap)))

INITIALISATION
    saldo_casa := 0 ||
    usuarios := {} ||
    saldo_usuario := {} ||
    is_admin := {} ||
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

    /* --- GESTÃO DE USUÁRIOS E PERFIS --- */

    novo_user_id <-- cadastrar_usuario(is_admin_param) = 
    PRE 
        contador_usuario <= MAX_USERS &
        is_admin_param : BOOL
    THEN 
        usuarios := usuarios \/ {contador_usuario} || 
        saldo_usuario(contador_usuario) := 0 || 
        status_conta(contador_usuario) := ativa || 
        is_admin(contador_usuario) := is_admin_param ||
        novo_user_id := contador_usuario ||
        contador_usuario := contador_usuario + 1
    END;

    downgrade_usuario(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & is_admin(target_user_id) = TRUE 
        & target_user_id /= admin_id /* Um admin não pode rebaixar a si mesmo */
    THEN
        is_admin(target_user_id) := FALSE
    END;

    upgrade_usuario(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & is_admin(target_user_id) = FALSE
    THEN
        is_admin(target_user_id) := TRUE
    END;
    
    ativar_usuario(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & status_conta(target_user_id) /= ativa
    THEN
        status_conta(target_user_id) := ativa
    END;

    colocar_conta_em_analise(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & status_conta(target_user_id) /= sob_analise
    THEN
        status_conta(target_user_id) := sob_analise
    END;

    suspender_usuario(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & status_conta(target_user_id) /= suspensa
    THEN
        status_conta(target_user_id) := suspensa
    END;

    /* --- OPERAÇÕES DO APOSTADOR --- */

    depositar(user_id, valor) =
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & valor : NAT 
        & status_conta(user_id) = ativa
        & saldo_usuario(user_id) + valor : NAT
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) + valor
    END;

    sacar(user_id, valor) =
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & valor : NAT 
        & status_conta(user_id) = ativa 
        & saldo_usuario(user_id) >= valor
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) - valor
    END;

    nova_aposta_id <-- realizar_aposta(user_id, evento_id, palpite, valor) = 
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & evento_id : NAT 
        & evento_id : eventos 
        & palpite : OPCAO_RESULTADO 
        & palpite /= indefinido 
        & valor : NAT 
        & valor >= APOSTA_MINIMA 
        & contador_aposta <= MAX_APOSTAS 
        & status_conta(user_id) = ativa 
        & status_evento(evento_id) = aberto 
        & saldo_usuario(user_id) >= valor
    THEN 
        apostas := apostas \/ {contador_aposta} || 
        aposta_usuario(contador_aposta) := user_id || 
        aposta_evento(contador_aposta) := evento_id || 
        aposta_valor(contador_aposta) := valor || 
        aposta_palpite(contador_aposta) := palpite || 
        status_aposta_map(contador_aposta) := pendente || 
        
        saldo_usuario(user_id) := saldo_usuario(user_id) - valor || 
        arrecadacao_evento(evento_id) := arrecadacao_evento(evento_id) + valor || 
        
        nova_aposta_id := contador_aposta ||
        contador_aposta := contador_aposta + 1
    END;
    
    revogar_aposta(user_id, aposta_id) =
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & aposta_id : NAT 
        & aposta_id : apostas 
        & aposta_usuario(aposta_id) = user_id 
        & (status_evento(aposta_evento(aposta_id)) = aberto or status_evento(aposta_evento(aposta_id)) = agendado) 
        & status_aposta_map(aposta_id) = pendente
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) + aposta_valor(aposta_id) ||
        arrecadacao_evento(aposta_evento(aposta_id)) := arrecadacao_evento(aposta_evento(aposta_id)) - aposta_valor(aposta_id) ||
        status_aposta_map(aposta_id) := revogada_usuario
    END;

    resgatar_reembolso(user_id, aposta_id) =
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & aposta_id : NAT 
        & aposta_id : apostas 
        & aposta_usuario(aposta_id) = user_id 
        & status_evento(aposta_evento(aposta_id)) = cancelado 
        & status_aposta_map(aposta_id) = pendente
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) + aposta_valor(aposta_id) ||
        status_aposta_map(aposta_id) := devolvida
    END;

    saldo_atual <-- consultar_saldo_usuario(user_id) = 
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE
    THEN 
        saldo_atual := saldo_usuario(user_id)
    END;

    /* --- OPERAÇÕES DO ADMIN --- */

    aportar_saldo_casa(admin_id, valor) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & valor : NAT
        & saldo_casa + valor : NAT
    THEN
        saldo_casa := saldo_casa + valor
    END;

    sacar_lucro_casa(admin_id, valor) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & valor : NAT 
        & saldo_casa >= valor
    THEN
        saldo_casa := saldo_casa - valor
    END;

    novo_evento_id <-- criar_evento(admin_id) = 
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & contador_evento <= MAX_EVENTS
    THEN 
        eventos := eventos \/ {contador_evento} || 
        status_evento(contador_evento) := agendado || 
        arrecadacao_evento(contador_evento) := 0 || 
        resultado_evento(contador_evento) := indefinido || 
        novo_evento_id := contador_evento ||
        contador_evento := contador_evento + 1
    END;

    abrir_evento(admin_id, evento_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & evento_id : NAT 
        & evento_id : eventos 
        & status_evento(evento_id) = agendado
    THEN
        status_evento(evento_id) := aberto
    END;

    suspender_evento(admin_id, evento_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & evento_id : NAT 
        & evento_id : eventos 
        & status_evento(evento_id) = aberto
    THEN
        status_evento(evento_id) := suspenso
    END;

    retomar_evento(admin_id, evento_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & evento_id : NAT 
        & evento_id : eventos 
        & status_evento(evento_id) = suspenso
    THEN
        status_evento(evento_id) := aberto
    END;

    finalizar_evento(admin_id, evento_id, resultado_vencedor) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & evento_id : NAT 
        & evento_id : eventos 
        & resultado_vencedor : OPCAO_RESULTADO 
        & resultado_vencedor /= indefinido 
        & status_evento(evento_id) = aberto
    THEN
        IF (
                #xx.(xx : apostas & aposta_evento(xx) = evento_id 
                    & aposta_palpite(xx) = resultado_vencedor)
            ) THEN
            /* Cenário em que há vencedores.  */
            ANY montante_liquido, total_vencedor 
            WHERE
                montante_liquido : NAT 
                & total_vencedor : NAT1 
                & montante_liquido = arrecadacao_evento(evento_id) - ((arrecadacao_evento(evento_id) * TAXA_CASA) / 100) 
                & total_vencedor = SIGMA(xx).(xx : apostas 
                    & aposta_evento(xx) = evento_id 
                    & aposta_palpite(xx) = resultado_vencedor | aposta_valor(xx))
            THEN
                /* 1. Casa recolhe a taxa */
                saldo_casa := saldo_casa + ((arrecadacao_evento(evento_id) * TAXA_CASA) / 100) ||
                /* 2. Evento é fechado */
                status_evento(evento_id) := finalizado ||
                resultado_evento(evento_id) := resultado_vencedor ||
                
                /* 3. Apenas carteiras de usuários com apostas vencedoras recebem fundos via lambda */
                saldo_usuario := saldo_usuario 
                <+ %uu.(uu : usuarios 
                    & #ap.(ap : apostas 
                        & aposta_usuario(ap) = uu 
                        & aposta_evento(ap) = evento_id 
                        & aposta_palpite(ap) = resultado_vencedor) 
                    |saldo_usuario(uu) + ((SIGMA(ap).(ap : apostas 
                                & aposta_usuario(ap) = uu 
                                & aposta_evento(ap) = evento_id 
                                & aposta_palpite(ap) = resultado_vencedor | aposta_valor(ap))
                        ) * montante_liquido) / total_vencedor
                ) ||
                
                /* 4. Vencedoras ficam "ganhas", perdedoras ficam "perdidas" */
                status_aposta_map := status_aposta_map 
                <+ %ap.(ap : apostas & aposta_evento(ap) = evento_id & aposta_palpite(ap) = resultado_vencedor | ganha) 
                    <+ %ap.(ap : apostas & aposta_evento(ap) = evento_id & aposta_palpite(ap) /= resultado_vencedor | perdida)
            END
        ELSE
            /* Cenário em que ninguém acertou. A casa embolsa o bolo inteiro e marca todas como perdidas. */
            saldo_casa := saldo_casa + arrecadacao_evento(evento_id) ||
            status_evento(evento_id) := finalizado ||
            resultado_evento(evento_id) := resultado_vencedor ||
            status_aposta_map := status_aposta_map <+ %ap.(ap : apostas & aposta_evento(ap) = evento_id | perdida)
        END
    END;

    cancelar_evento(admin_id, evento_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & evento_id : NAT 
        & evento_id : eventos 
        & status_evento(evento_id) = aberto
    THEN
        status_evento(evento_id) := cancelado
    END;

    saldo_atual <-- consultar_saldo_casa(admin_id) = 
    PRE
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE
    THEN 
        saldo_atual := saldo_casa 
    END

END
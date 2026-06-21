/* Apostas
 * Author: Superframe Force
 * Creation date: 01/05/2026
 * Ajustado para sistema de odds
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
    odd_evento,
    apostas,
    aposta_usuario,
    aposta_evento,
    aposta_valor,
    aposta_palpite,
    aposta_odd,
    status_aposta_map,
    status_conta,
    resultado_evento,
    contador_aposta,
    contador_evento,
    contador_usuario
    
INVARIANT
    /* Tipagem Variaveis de Estado */
    saldo_casa : NAT &
    usuarios <: NAT1 &
    card(usuarios) <= MAX_USERS &
    saldo_usuario : usuarios --> NAT & 
    status_conta : usuarios --> STATUS_CONTA &
    is_admin : usuarios --> BOOL &
    (usuarios /= {} => TRUE : ran(is_admin)) &

    contador_evento : NAT1 &
    contador_evento <= MAX_EVENTS + 1 &
    eventos = 1..(contador_evento - 1) &
    
    contador_aposta : NAT1 & 
    contador_aposta <= MAX_APOSTAS + 1 &
    apostas = 1..(contador_aposta - 1) &
    
    contador_usuario : NAT1 & 
    contador_usuario <= MAX_USERS + 1 &
    usuarios = 1..(contador_usuario - 1) &

    /* Tipagem Variaveis de Eventos */
    eventos <: NAT1 &
    card(eventos) <= MAX_EVENTS &
    status_evento : eventos --> STATUS_EVENTO &
    arrecadacao_evento : eventos --> NAT &
    odd_evento : eventos --> ODD_MINIMA..ODD_MAXIMA &
    
    /* Tipagem do Resultado */
    resultado_evento : eventos --> OPCAO_RESULTADO &

    /* Tipagem das Apostas */
    apostas <: NAT1 &
    card(apostas) <= MAX_APOSTAS &
    aposta_usuario : apostas --> usuarios &
    aposta_evento : apostas --> eventos &
    aposta_valor : apostas --> NAT1 &
    !ap.(ap : apostas => aposta_valor(ap) >= APOSTA_MINIMA) &
    aposta_palpite : apostas --> OPCAO_RESULTADO - {indefinido} &
    aposta_odd : apostas --> ODD_MINIMA..ODD_MAXIMA &
    status_aposta_map : apostas --> STATUS_APOSTA &
    
    /* Regras de Negocio sem PARA TODO explicito */

    /* 1. Regra de Vitoria: aposta ganha tem palpite igual ao resultado do evento */
    (status_aposta_map~[{ganha}] <| aposta_palpite) =
        (status_aposta_map~[{ganha}] <| (aposta_evento ; resultado_evento)) &

    /* 2. Regra de Derrota: aposta perdida nao tem palpite igual ao resultado do evento */
    ((status_aposta_map~[{perdida}] <| aposta_palpite) /\
        (status_aposta_map~[{perdida}] <| (aposta_evento ; resultado_evento))) = {} &

    /* 3. Evento nao finalizado tem resultado indefinido */
    ran(status_evento~[STATUS_EVENTO - {finalizado}] <| resultado_evento) <: {indefinido} &
           
    /* 4. Integridade das Apostas: pendente apenas em evento aberto, suspenso ou cancelado */
    status_evento[aposta_evento[status_aposta_map~[{pendente}]]] <: {aberto, suspenso, cancelado} &
       
    /* 5. Todo evento finalizado tem resultado valido */
    ran(status_evento~[{finalizado}] <| resultado_evento) <: OPCAO_RESULTADO - {indefinido} &
    
    /* 6. Apostas ganhas ou perdidas apenas se o evento acabou */
    status_evento[aposta_evento[status_aposta_map~[{ganha, perdida}]]] <: {finalizado} &
    
    /* 7. Uma aposta so e devolvida se o evento foi cancelado */
    status_evento[aposta_evento[status_aposta_map~[{devolvida}]]] <: {cancelado} &
    
    /* 8. A arrecadacao de eventos abertos ou suspensos deve bater com a soma das apostas pendentes */
    ({ev | ev : eventos & status_evento(ev) : {aberto, suspenso}} <| arrecadacao_evento) =
        %ev.(ev : {evv | evv : eventos & status_evento(evv) : {aberto, suspenso}} |
            SIGMA(ap).(ap : apostas & aposta_evento(ap) = ev & status_aposta_map(ap) = pendente | aposta_valor(ap)))

INITIALISATION
    saldo_casa := 0 ||
    usuarios := {} ||
    saldo_usuario := {} ||
    is_admin := {} ||
    eventos := {} ||
    status_evento := {} ||
    arrecadacao_evento := {} ||
    odd_evento := {} ||
    apostas := {} ||
    aposta_usuario := {} ||
    aposta_evento := {} ||
    aposta_valor := {} ||
    aposta_palpite := {} ||
    aposta_odd := {} ||
    status_aposta_map := {} ||
    status_conta := {} ||
    resultado_evento := {} ||
    contador_aposta := 1 ||
    contador_evento := 1 ||
    contador_usuario := 1
    
OPERATIONS

    /* --- GESTAO DE USUARIOS E PERFIS --- */

    novo_user_id <-- cadastrar_usuario(is_admin_param) = 
    PRE 
        contador_usuario <= MAX_USERS &
        contador_usuario /: usuarios &
        is_admin_param : BOOL &
        (usuarios = {} => is_admin_param = TRUE) &
        (usuarios /= {} => is_admin_param = FALSE)
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
        & status_conta(admin_id) = ativa
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & is_admin(target_user_id) = TRUE 
        & target_user_id /= admin_id /* Um admin nao pode rebaixar a si mesmo */
        & card(is_admin~[{TRUE}]) >= 2
    THEN
        is_admin(target_user_id) := FALSE
    END;

    upgrade_usuario(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
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
        & status_conta(admin_id) = ativa
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
        & status_conta(admin_id) = ativa
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & target_user_id /= admin_id
        & status_conta(target_user_id) /= sob_analise
    THEN
        status_conta(target_user_id) := sob_analise
    END;

    suspender_usuario(admin_id, target_user_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
        & target_user_id : NAT 
        & target_user_id : usuarios 
        & target_user_id /= admin_id
        & status_conta(target_user_id) /= suspensa
    THEN
        status_conta(target_user_id) := suspensa
    END;

    /* --- OPERACOES DO APOSTADOR --- */

    depositar(user_id, valor) =
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & valor : NAT1 
        & status_conta(user_id) = ativa
    THEN
        saldo_usuario(user_id) := saldo_usuario(user_id) + valor
    END;

    sacar(user_id, valor) =
    PRE 
        user_id : NAT 
        & user_id : usuarios 
        & is_admin(user_id) = FALSE 
        & valor : NAT1 
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
        & valor : NAT1 
        & valor >= APOSTA_MINIMA 
        & contador_aposta <= MAX_APOSTAS 
        & contador_aposta /: apostas
        & status_conta(user_id) = ativa 
        & status_evento(evento_id) = aberto 
        & saldo_usuario(user_id) >= valor
    THEN 
        apostas := apostas \/ {contador_aposta} || 
        aposta_usuario(contador_aposta) := user_id || 
        aposta_evento(contador_aposta) := evento_id || 
        aposta_valor(contador_aposta) := valor || 
        aposta_palpite(contador_aposta) := palpite || 
        aposta_odd(contador_aposta) := odd_evento(evento_id) ||
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
        & status_evento(aposta_evento(aposta_id)) : {aberto, suspenso}
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

    odd_atual <-- consultar_odd_evento(evento_id) =
    PRE
        evento_id : NAT
        & evento_id : eventos
    THEN
        odd_atual := odd_evento(evento_id)
    END;

    odd_salva <-- consultar_odd_aposta(aposta_id) =
    PRE
        aposta_id : NAT
        & aposta_id : apostas
    THEN
        odd_salva := aposta_odd(aposta_id)
    END;

    /* --- OPERACOES DO ADMIN --- */

    aportar_saldo_casa(admin_id, valor) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
        & valor : NAT1
    THEN
        saldo_casa := saldo_casa + valor
    END;

    sacar_lucro_casa(admin_id, valor) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
        & valor : NAT1 
        & saldo_casa >= valor
    THEN
        saldo_casa := saldo_casa - valor
    END;

    novo_evento_id <-- criar_evento(admin_id) = 
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
        & contador_evento <= MAX_EVENTS
        & contador_evento /: eventos
    THEN 
        eventos := eventos \/ {contador_evento} || 
        status_evento(contador_evento) := agendado || 
        arrecadacao_evento(contador_evento) := 0 || 
        odd_evento(contador_evento) := ODD_PADRAO ||
        resultado_evento(contador_evento) := indefinido || 
        novo_evento_id := contador_evento ||
        contador_evento := contador_evento + 1
    END;

    abrir_evento(admin_id, evento_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
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
        & status_conta(admin_id) = ativa
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
        & status_conta(admin_id) = ativa
        & evento_id : NAT 
        & evento_id : eventos 
        & status_evento(evento_id) = suspenso
    THEN
        status_evento(evento_id) := aberto
    END;

    alterar_odd_evento(admin_id, evento_id, nova_odd) =
    PRE
        admin_id : NAT
        & admin_id : usuarios
        & is_admin(admin_id) = TRUE
        & status_conta(admin_id) = ativa
        & evento_id : NAT
        & evento_id : eventos
        & status_evento(evento_id) : {agendado, aberto, suspenso}
        & nova_odd : ODD_MINIMA..ODD_MAXIMA
    THEN
        odd_evento(evento_id) := nova_odd
    END;

    finalizar_evento(admin_id, evento_id, resultado_vencedor) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
        & evento_id : NAT 
        & evento_id : eventos 
        & resultado_vencedor : OPCAO_RESULTADO 
        & resultado_vencedor /= indefinido 
        & status_evento(evento_id) = aberto
    THEN
        status_evento(evento_id) := finalizado ||
        resultado_evento(evento_id) := resultado_vencedor ||

        /* Pagamento por odd salva no momento da aposta. Ex.: 130 representa odd 1.30 */
        saldo_usuario := %uu.(uu : usuarios |
            saldo_usuario(uu) +
            SIGMA(ap).(
                ap : apostas
                & aposta_usuario(ap) = uu
                & aposta_evento(ap) = evento_id
                & aposta_palpite(ap) = resultado_vencedor
                & status_aposta_map(ap) = pendente
                | (aposta_valor(ap) * aposta_odd(ap)) / 100
            )
        ) ||

        status_aposta_map := status_aposta_map
            <+ %ap.(ap : apostas
                & aposta_evento(ap) = evento_id
                & aposta_palpite(ap) = resultado_vencedor
                & status_aposta_map(ap) = pendente | ganha)
            <+ %ap.(ap : apostas
                & aposta_evento(ap) = evento_id
                & aposta_palpite(ap) /= resultado_vencedor
                & status_aposta_map(ap) = pendente | perdida)
    END;

    cancelar_evento(admin_id, evento_id) =
    PRE 
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE 
        & status_conta(admin_id) = ativa
        & evento_id : NAT 
        & evento_id : eventos 
        & status_evento(evento_id) : {aberto, suspenso}
    THEN
        status_evento(evento_id) := cancelado
    END;

    saldo_atual <-- consultar_saldo_casa(admin_id) = 
    PRE
        admin_id : NAT 
        & admin_id : usuarios 
        & is_admin(admin_id) = TRUE
        & status_conta(admin_id) = ativa
    THEN 
        saldo_atual := saldo_casa 
    END

END

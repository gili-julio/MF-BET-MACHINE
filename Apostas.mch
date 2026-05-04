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
    saldo_usuario : usuarios --> NAT & /* Garante que saldo(u) >= 0 para todo u no domínio */
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
    /* Funções Totais: Toda aposta cadastrada TEM que ter esses atributos */
    apostas <: NAT &
    card(apostas) <= MAX_APOSTAS &
    aposta_usuario : apostas --> usuarios &
    aposta_evento : apostas --> eventos &
    aposta_valor : apostas --> NAT1 & /* NAT1 garante que aposta > 0 */
    aposta_palpite : apostas --> OPCAO_RESULTADO &
    status_aposta_map : apostas --> STATUS_APOSTA &
    
    /* Regras de Negõcio */
   
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
    /* Se o evento NÃO está finalizado, ele não pode ter resultado no sistema */
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

    status <-- aportar_saldo_casa(valor) =
    PRE valor : NAT
    THEN
        /* Interface "Burra": A operação B aceita sempre, mas não quebra se algo der errado */
        saldo_casa := saldo_casa + valor ||
        status := sucesso
    END;

    status, novo_user_id <-- cadastrar_usuario = 
    BEGIN 
        IF (contador_usuario <= MAX_USERS) THEN 
            usuarios := usuarios \/ {contador_usuario} || 
            saldo_usuario(contador_usuario) := 0 || 
            status_conta(contador_usuario) := pendente_documento || 
            
            novo_user_id := contador_usuario ||
            contador_usuario := contador_usuario + 1 ||
            
            status := sucesso 
        ELSE 
            /* Se o limite de usuários foi atingido */
            status := erro_limite_excedido ||
            novo_user_id := 0 
        END 
    END;

    status <-- depositar(user_id, valor) =
    PRE user_id : NAT & valor : NAT
    THEN
        IF (user_id : usuarios) THEN
            IF (status_conta(user_id) = ativa or status_conta(user_id) = pendente_documento) THEN
                saldo_usuario(user_id) := saldo_usuario(user_id) + valor ||
                status := sucesso
            ELSE
                status := erro_conta_bloqueada
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    status <-- sacar(user_id, valor) =
    PRE user_id : NAT & valor : NAT
    THEN
        IF (user_id : usuarios) THEN
            IF (status_conta(user_id) = ativa) THEN
                IF (saldo_usuario(user_id) >= valor) THEN
                    saldo_usuario(user_id) := saldo_usuario(user_id) - valor ||
                    status := sucesso
                ELSE
                    status := erro_saldo_insuficiente
                END
            ELSE
                status := erro_conta_pendente_verificacao /*pode manter erro_conta_bloqueada se preferir generalizar */
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    /* --- Operações de Eventos --- */

    status, novo_evento_id <-- criar_evento = 
    BEGIN 
        IF (contador_evento <= MAX_EVENTS) THEN 
            eventos := eventos \/ {contador_evento} || 
            status_evento(contador_evento) := agendado || 
            arrecadacao_evento(contador_evento) := 0 || 
            resultado_evento(contador_evento) := indefinido || 
            
            novo_evento_id := contador_evento ||
            contador_evento := contador_evento + 1 ||
            
            status := sucesso 
        ELSE 
            status := erro_limite_excedido ||
            novo_evento_id := 0
        END 
    END;

    status <-- abrir_evento(evento_id) =
    PRE evento_id : NAT
    THEN
        IF (evento_id : eventos) THEN
            IF (status_evento(evento_id) = agendado) THEN
                status_evento(evento_id) := aberto ||
                status := sucesso
            ELSE
                status := erro_estado_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    status, nova_aposta_id <-- realizar_aposta(user_id, evento_id, palpite, valor) = 
    PRE 
        user_id : NAT & evento_id : NAT & palpite : OPCAO_RESULTADO & valor : NAT 
    THEN 
        IF (contador_aposta <= MAX_APOSTAS & user_id : usuarios & evento_id : eventos) THEN
            IF (status_conta(user_id) = ativa or status_conta(user_id) = pendente_documento) THEN 
                IF (status_evento(evento_id) = aberto & valor >= APOSTA_MINIMA & palpite /= indefinido) THEN 
                    IF (saldo_usuario(user_id) >= valor) THEN 
                        apostas := apostas \/ {contador_aposta} || 
                        aposta_usuario(contador_aposta) := user_id || 
                        aposta_evento(contador_aposta) := evento_id || 
                        aposta_valor(contador_aposta) := valor || 
                        aposta_palpite(contador_aposta) := palpite || 
                        status_aposta_map(contador_aposta) := pendente || 
                        
                        /* Atualiza Saldos */ 
                        saldo_usuario(user_id) := saldo_usuario(user_id) - valor || 
                        arrecadacao_evento(evento_id) := arrecadacao_evento(evento_id) + valor || 
                        
                        nova_aposta_id := contador_aposta ||
                        contador_aposta := contador_aposta + 1 ||
                        
                        status := sucesso 
                    ELSE 
                        status := erro_saldo_insuficiente ||
                        nova_aposta_id := 0
                    END 
                ELSE 
                    status := erro_evento_invalido ||
                    nova_aposta_id := 0
                END 
            ELSE 
                status := erro_conta_bloqueada ||
                nova_aposta_id := 0
            END 
        ELSE 
            status := erro_limite_excedido ||
            nova_aposta_id := 0
        END 
    END;
    
    status <-- revogar_aposta(aposta_id) =
    PRE aposta_id : NAT
    THEN
        IF (aposta_id : apostas) THEN
            /* Só pode cancelar se o evento ainda estiver ABERTo ou AGENDADO e a aposta PENDENTE */
            IF (status_evento(aposta_evento(aposta_id)) = aberto or status_evento(aposta_evento(aposta_id)) = agendado) THEN
                IF (status_aposta_map(aposta_id) = pendente) THEN
                    
                    /* Devolve o dinheiro para o usuário */
                    saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + aposta_valor(aposta_id) ||
                    
                    /* Retira o dinheiro do balaio do evento */
                    arrecadacao_evento(aposta_evento(aposta_id)) := arrecadacao_evento(aposta_evento(aposta_id)) - aposta_valor(aposta_id) ||
                    
                    /* Atualiza o status da aposta para não ser mais cobrada */
                    status_aposta_map(aposta_id) := revogada_usuario ||
                    
                    status := sucesso
                ELSE
                    status := erro_estado_invalido
                END
            ELSE
                status := erro_evento_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;
    
    status <-- finalizar_evento(evento_id, resultado_vencedor) =
    PRE evento_id : NAT & resultado_vencedor : OPCAO_RESULTADO
    THEN
        IF (evento_id : eventos & status_evento(evento_id) = aberto) THEN
            /* A casa recolhe comissão */
            saldo_casa := saldo_casa + ((arrecadacao_evento(evento_id) * TAXA_CASA) / 100) ||
            status_evento(evento_id) := finalizado ||
            resultado_evento(evento_id) := resultado_vencedor || /* <-- LINHA ADICIONADA */
            status := sucesso
        ELSE
            status := erro_evento_invalido
        END
    END;

    status <-- cancelar_evento(evento_id) =
    PRE evento_id : NAT
    THEN
        IF (evento_id : eventos & status_evento(evento_id) = aberto) THEN
            status_evento(evento_id) := cancelado ||
            status := sucesso
        ELSE
            status := erro_evento_invalido
        END
    END;
    
    status <-- suspender_evento(evento_id) =
    PRE evento_id : NAT
    THEN
        IF (evento_id : eventos) THEN
            IF (status_evento(evento_id) = aberto) THEN
                status_evento(evento_id) := suspenso ||
                status := sucesso
            ELSE
                status := erro_estado_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    status <-- retomar_evento(evento_id) =
    PRE evento_id : NAT
    THEN
        IF (evento_id : eventos) THEN
            IF (status_evento(evento_id) = suspenso) THEN
                status_evento(evento_id) := aberto ||
                status := sucesso
            ELSE
                status := erro_estado_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;
    
    status <-- resgatar_premio(aposta_id, premio_calculado) = 
    PRE aposta_id : NAT & premio_calculado : NAT THEN 
        IF (aposta_id : apostas) THEN 
            IF (status_conta(aposta_usuario(aposta_id)) = ativa) THEN 
                IF (status_evento(aposta_evento(aposta_id)) = finalizado) THEN 
                    IF (status_aposta_map(aposta_id) = pendente) THEN 
                        
                        /* Verifica se usuário ganhou ou perdeu aposta*/
                        IF (aposta_palpite(aposta_id) = resultado_evento(aposta_evento(aposta_id))) THEN
                            /* O usuário acertou: recebe sua parte e a aposta é ganha */ 
                            saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + premio_calculado || 
                            status_aposta_map(aposta_id) := ganha || 
                            status := sucesso 
                        ELSE
                            /* O usuário errou: perde a aposta e dinheiro fica na casa) */
                            status_aposta_map(aposta_id) := perdida ||
                            status := sucesso /* O usuário apenas errou o palpite */
                        END
    
                    ELSE 
                        status := erro_estado_invalido /* Já foi paga, perdida ou devolvida */ 
                    END 
                ELSE 
                    status := erro_evento_invalido /* Evento ainda não acabou */ 
                END 
            ELSE 
                status := erro_conta_pendente_verificacao 
            END 
        ELSE 
            status := erro_nao_encontrado 
        END 
    END;

    status <-- resgatar_reembolso(aposta_id) =
    PRE aposta_id : NAT
    THEN
        IF (aposta_id : apostas) THEN
            IF (status_evento(aposta_evento(aposta_id)) = cancelado) THEN
                IF (status_aposta_map(aposta_id) = pendente) THEN
                    /* Devolve exatamente o valor que o usuário apostou */
                    saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + aposta_valor(aposta_id) ||
                    status_aposta_map(aposta_id) := devolvida ||
                    status := sucesso
                ELSE
                    status := erro_estado_invalido
                END
            ELSE
                status := erro_evento_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;
    
    status <-- sacar_lucro_casa(valor) =
    PRE valor : NAT
    THEN
        IF (saldo_casa >= valor) THEN
            saldo_casa := saldo_casa - valor ||
            status := sucesso
        ELSE
            status := erro_saldo_insuficiente
        END
    END;
    
    /* --- Operações Avançadas de Segurança e Auditoria --- */

    status <-- verificar_documento_kyc(user_id) =
    PRE user_id : NAT
    THEN
        IF (user_id : usuarios) THEN
            /* O administrador aprova os documentos e ativa a conta */
            IF (status_conta(user_id) = pendente_documento or status_conta(user_id) = suspensa) THEN
                status_conta(user_id) := ativa ||
                status := sucesso
            ELSE
                status := erro_estado_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    status <-- colocar_conta_em_analise(user_id) =
    PRE user_id : NAT
    THEN
        IF (user_id : usuarios) THEN
            /* Impede que contas banidas sejam colocadas em análise, ou seja, banimento é definitivo */
            IF (status_conta(user_id) /= banida) THEN
                status_conta(user_id) := sob_analise ||
                status := sucesso
            ELSE
                status := erro_estado_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    status <-- banir_usuario_fraude(user_id) =
    PRE user_id : NAT
    THEN
        IF (user_id : usuarios) THEN
            /* Uma vez banida, a conta nunca mais sai desse estado na máquina. */
            IF (status_conta(user_id) /= banida) THEN
                status_conta(user_id) := banida ||
                status := sucesso
            ELSE
                status := erro_estado_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;
    
    
    
    saldo_atual <-- consultar_saldo_casa = 
    BEGIN 
        saldo_atual := saldo_casa 
    END;
    
    status, saldo_atual <-- consultar_saldo_usuario(user_id) = 
    PRE user_id : NAT THEN 
        IF (user_id : usuarios) THEN 
            saldo_atual := saldo_usuario(user_id) || 
            status := sucesso 
        ELSE 
            saldo_atual := 0 || 
            status := erro_nao_encontrado 
        END 
    END
END

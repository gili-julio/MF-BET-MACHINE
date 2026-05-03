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
    status_aposta_map

INVARIANT
    /* Tipagem Variáveis de Estado (Casa e Usuários) */
    saldo_casa : NAT &
    usuarios <: NAT &
    card(usuarios) <= MAX_USERS &
    saldo_usuario : usuarios --> NAT & /* Garante que saldo(u) >= 0 para todo u no domínio */

    /* Tipagem Variáveis de Eventos */
    eventos <: NAT &
    card(eventos) <= MAX_EVENTS &
    status_evento : eventos --> STATUS_EVENTO &
    arrecadacao_evento : eventos --> NAT &

    /* Regras de Negócio Críticas (Blindagem) */
    /* 1. Solvência da Casa: Garantido pelo fato de saldo_casa pertencer a NAT (Naturais >= 0) */
    /* 2. Consistência Financeira: Garantido pelo contradomínio NAT em saldo_usuario */
    /* 3. Integridade de Estado: (A ser verificado nas pré-condições ocultadas pela defesa) */
    
    !ev.(ev : eventos => arrecadacao_evento(ev) >= 0) &
    
    apostas <: NAT &
    card(apostas) <= MAX_APOSTAS &
    
    /* Funções Totais: Toda aposta cadastrada TEM que ter esses atributos */
    aposta_usuario : apostas --> usuarios &
    aposta_evento : apostas --> eventos &
    aposta_valor : apostas --> NAT1 & /* NAT1 garante que aposta > 0 */
    aposta_palpite : apostas --> OPCAO_RESULTADO &
    status_aposta_map : apostas --> STATUS_APOSTA

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
    status_aposta_map := {}

OPERATIONS

    /* --- Operações de Caixa e Gestão --- */

    status <-- aportar_saldo_casa(valor) =
    PRE valor : NAT
    THEN
        /* Interface "Burra": A operação B aceita sempre, mas não quebra se algo der errado */
        saldo_casa := saldo_casa + valor ||
        status := sucesso
    END;

    status <-- cadastrar_usuario(user_id) =
    PRE user_id : NAT
    THEN
        IF (user_id /: usuarios & card(usuarios) < MAX_USERS) THEN
            usuarios := usuarios \/ {user_id} ||
            saldo_usuario(user_id) := 0 ||
            status := sucesso
        ELSE
            status := erro_limite_excedido
        END
    END;

    status <-- depositar(user_id, valor) =
    PRE user_id : NAT & valor : NAT
    THEN
        IF (user_id : usuarios) THEN
            saldo_usuario(user_id) := saldo_usuario(user_id) + valor ||
            status := sucesso
        ELSE
            status := erro_nao_encontrado
        END
    END;

    status <-- sacar(user_id, valor) =
    PRE user_id : NAT & valor : NAT
    THEN
        IF (user_id : usuarios) THEN
            IF (saldo_usuario(user_id) >= valor) THEN
                saldo_usuario(user_id) := saldo_usuario(user_id) - valor ||
                status := sucesso
            ELSE
                status := erro_saldo_insuficiente
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;

    /* --- Operações de Eventos --- */

    status <-- criar_evento(evento_id) =
    PRE evento_id : NAT
    THEN
        IF (evento_id /: eventos & card(eventos) < MAX_EVENTS) THEN
            eventos := eventos \/ {evento_id} ||
            status_evento(evento_id) := agendado ||
            arrecadacao_evento(evento_id) := 0 ||
            status := sucesso
        ELSE
            status := erro_limite_excedido
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

    status <-- realizar_aposta(aposta_id, user_id, evento_id, palpite, valor) =
    PRE aposta_id : NAT & user_id : NAT & evento_id : NAT & palpite : OPCAO_RESULTADO & valor : NAT
    THEN
        IF (aposta_id /: apostas & card(apostas) < MAX_APOSTAS &
            user_id : usuarios & evento_id : eventos) THEN
            
            IF (status_evento(evento_id) = aberto & valor >= APOSTA_MINIMA) THEN
                IF (saldo_usuario(user_id) >= valor) THEN
                    /* Registra os dados da Aposta */
                    apostas := apostas \/ {aposta_id} ||
                    aposta_usuario(aposta_id) := user_id ||
                    aposta_evento(aposta_id) := evento_id ||
                    aposta_valor(aposta_id) := valor ||
                    aposta_palpite(aposta_id) := palpite ||
                    status_aposta_map(aposta_id) := pendente ||
                    
                    /* Fluxo Financeiro Simultâneo */
                    saldo_usuario(user_id) := saldo_usuario(user_id) - valor ||
                    arrecadacao_evento(evento_id) := arrecadacao_evento(evento_id) + valor ||
                    
                    status := sucesso
                ELSE
                    status := erro_saldo_insuficiente
                END
            ELSE
                status := erro_evento_invalido
            END
        ELSE
            status := erro_nao_encontrado
        END
    END;
    
    status <-- revogar_aposta(aposta_id) =
    PRE aposta_id : NAT
    THEN
        IF (aposta_id : apostas) THEN
            /* Só pode cancelar se o evento ainda estiver aberto ou agendado e a aposta pendente */
            IF (status_evento(aposta_evento(aposta_id)) = aberto or status_evento(aposta_evento(aposta_id)) = agendado) THEN
                IF (status_aposta_map(aposta_id) = pendente) THEN
                    
                    /* Devolve o dinheiro para o usuário */
                    saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + aposta_valor(aposta_id) ||
                    
                    /* Retira o dinheiro do bolo do evento */
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
            /* A casa recolhe sua comissão matematicamente blindada */
            saldo_casa := saldo_casa + ((arrecadacao_evento(evento_id) * TAXA_CASA) / 100) ||
            status_evento(evento_id) := finalizado ||
            /* Dica: Numa versão expandida, guardaríamos o resultado_vencedor em uma variável de estado */
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
    PRE aposta_id : NAT & premio_calculado : NAT
    THEN
        IF (aposta_id : apostas) THEN
            IF (status_evento(aposta_evento(aposta_id)) = finalizado) THEN
                IF (status_aposta_map(aposta_id) = pendente) THEN
                    /* O usuário recebe sua parte e a aposta é marcada como paga */
                    saldo_usuario(aposta_usuario(aposta_id)) := saldo_usuario(aposta_usuario(aposta_id)) + premio_calculado ||
                    status_aposta_map(aposta_id) := ganha ||
                    status := sucesso
                ELSE
                    status := erro_estado_invalido /* Já foi paga ou perdida */
                END
            ELSE
                status := erro_evento_invalido /* Evento ainda não acabou */
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
    END
END

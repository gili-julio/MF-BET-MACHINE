#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "Apostas.h"
#include "Apostas_Ctx.h"

static int32_t ler_int(const char *rotulo)
{
    char buffer[128];
    char *fim = NULL;
    long valor;

    for (;;)
    {
        printf("%s", rotulo);
        if (fgets(buffer, sizeof(buffer), stdin) == NULL)
        {
            printf("\nEntrada encerrada.\n");
            exit(0);
        }

        valor = strtol(buffer, &fim, 10);
        if (fim != buffer && (*fim == '\n' || *fim == '\0'))
        {
            return (int32_t)valor;
        }

        printf("Valor invalido. Digite um numero inteiro.\n");
    }
}

static int32_t ler_nat(const char *rotulo)
{
    int32_t valor;

    do
    {
        valor = ler_int(rotulo);
        if (valor < 0)
        {
            printf("Valor invalido. Digite um numero natural.\n");
        }
    } while (valor < 0);

    return valor;
}

static bool ler_bool(const char *rotulo)
{
    int32_t valor;

    do
    {
        valor = ler_int(rotulo);
        if (valor != 0 && valor != 1)
        {
            printf("Valor invalido. Use 1 para sim ou 0 para nao.\n");
        }
    } while (valor != 0 && valor != 1);

    return valor == 1;
}

static Apostas_Ctx__OPCAO_RESULTADO ler_resultado(const char *rotulo)
{
    int32_t valor;

    printf("0 - indefinido\n");
    printf("1 - vitoria_A\n");
    printf("2 - empate\n");
    printf("3 - vitoria_B\n");

    do
    {
        valor = ler_int(rotulo);
        if (valor < 0 || valor > 3)
        {
            printf("Opcao invalida.\n");
        }
    } while (valor < 0 || valor > 3);

    switch (valor)
    {
    case 1:
        return Apostas_Ctx__vitoria_A;
    case 2:
        return Apostas_Ctx__empate;
    case 3:
        return Apostas_Ctx__vitoria_B;
    default:
        return Apostas_Ctx__indefinido;
    }
}

static const char *texto_bool(bool valor)
{
    return valor ? "TRUE" : "FALSE";
}

static const char *texto_conta(Apostas_Ctx__STATUS_CONTA status)
{
    switch (status)
    {
    case Apostas_Ctx__ativa:
        return "ativa";
    case Apostas_Ctx__sob_analise:
        return "sob_analise";
    case Apostas_Ctx__suspensa:
        return "suspensa";
    default:
        return "desconhecido";
    }
}

static const char *texto_evento(Apostas_Ctx__STATUS_EVENTO status)
{
    switch (status)
    {
    case Apostas_Ctx__agendado:
        return "agendado";
    case Apostas_Ctx__aberto:
        return "aberto";
    case Apostas_Ctx__finalizado:
        return "finalizado";
    case Apostas_Ctx__cancelado:
        return "cancelado";
    case Apostas_Ctx__suspenso:
        return "suspenso";
    default:
        return "desconhecido";
    }
}

static const char *texto_aposta(Apostas_Ctx__STATUS_APOSTA status)
{
    switch (status)
    {
    case Apostas_Ctx__pendente:
        return "pendente";
    case Apostas_Ctx__ganha:
        return "ganha";
    case Apostas_Ctx__perdida:
        return "perdida";
    case Apostas_Ctx__devolvida:
        return "devolvida";
    case Apostas_Ctx__revogada_usuario:
        return "revogada_usuario";
    default:
        return "desconhecido";
    }
}

static const char *texto_resultado(Apostas_Ctx__OPCAO_RESULTADO resultado)
{
    switch (resultado)
    {
    case Apostas_Ctx__vitoria_A:
        return "vitoria_A";
    case Apostas_Ctx__empate:
        return "empate";
    case Apostas_Ctx__vitoria_B:
        return "vitoria_B";
    case Apostas_Ctx__indefinido:
        return "indefinido";
    default:
        return "desconhecido";
    }
}

static void imprimir_permitido(bool permitido)
{
    if (!permitido)
    {
        printf("Operacao nao permitida pelo modelo.\n");
    }
}

static void cadastrar_usuario(void)
{
    bool is_admin = ler_bool("Cadastrar como admin? (1/0): ");
    bool permitido;
    int32_t id;

    Apostas__pode_cadastrar_usuario(is_admin, &permitido);
    if (permitido)
    {
        Apostas__cadastrar_usuario(is_admin, &id);
        printf("Usuario cadastrado com id %d.\n", id);
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void depositar(void)
{
    int32_t user_id = ler_nat("ID do usuario: ");
    int32_t valor = ler_nat("Valor: ");
    bool permitido;

    Apostas__pode_depositar(user_id, valor, &permitido);
    if (permitido)
    {
        Apostas__depositar(user_id, valor);
        printf("Deposito realizado.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void sacar(void)
{
    int32_t user_id = ler_nat("ID do usuario: ");
    int32_t valor = ler_nat("Valor: ");
    bool permitido;

    Apostas__pode_sacar(user_id, valor, &permitido);
    if (permitido)
    {
        Apostas__sacar(user_id, valor);
        printf("Saque realizado.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void criar_evento(void)
{
    int32_t admin_id = ler_nat("ID do admin: ");
    bool permitido;
    int32_t evento_id;

    Apostas__pode_criar_evento(admin_id, &permitido);
    if (permitido)
    {
        Apostas__criar_evento(admin_id, &evento_id);
        printf("Evento criado com id %d.\n", evento_id);
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void abrir_evento(void)
{
    int32_t admin_id = ler_nat("ID do admin: ");
    int32_t evento_id = ler_nat("ID do evento: ");
    bool permitido;

    Apostas__pode_abrir_evento(admin_id, evento_id, &permitido);
    if (permitido)
    {
        Apostas__abrir_evento(admin_id, evento_id);
        printf("Evento aberto.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void alterar_odd_evento(void)
{
    int32_t admin_id = ler_nat("ID do admin: ");
    int32_t evento_id = ler_nat("ID do evento: ");
    int32_t nova_odd = ler_nat("Nova odd inteira (ex: 130 = 1.30): ");
    bool permitido;

    Apostas__pode_alterar_odd_evento(admin_id, evento_id, nova_odd, &permitido);
    if (permitido)
    {
        Apostas__alterar_odd_evento(admin_id, evento_id, nova_odd);
        printf("Odd alterada.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void realizar_aposta(void)
{
    int32_t user_id = ler_nat("ID do usuario: ");
    int32_t evento_id = ler_nat("ID do evento: ");
    Apostas_Ctx__OPCAO_RESULTADO palpite = ler_resultado("Palpite: ");
    int32_t valor = ler_nat("Valor: ");
    bool permitido;
    int32_t aposta_id;

    Apostas__pode_realizar_aposta(user_id, evento_id, palpite, valor, &permitido);
    if (permitido)
    {
        Apostas__realizar_aposta(user_id, evento_id, palpite, valor, &aposta_id);
        printf("Aposta realizada com id %d.\n", aposta_id);
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void revogar_aposta(void)
{
    int32_t user_id = ler_nat("ID do usuario: ");
    int32_t aposta_id = ler_nat("ID da aposta: ");
    bool permitido;

    Apostas__pode_revogar_aposta(user_id, aposta_id, &permitido);
    if (permitido)
    {
        Apostas__revogar_aposta(user_id, aposta_id);
        printf("Aposta revogada.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void cancelar_evento(void)
{
    int32_t admin_id = ler_nat("ID do admin: ");
    int32_t evento_id = ler_nat("ID do evento: ");
    bool permitido;

    Apostas__pode_cancelar_evento(admin_id, evento_id, &permitido);
    if (permitido)
    {
        Apostas__cancelar_evento(admin_id, evento_id);
        printf("Evento cancelado.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void resgatar_reembolso(void)
{
    int32_t user_id = ler_nat("ID do usuario: ");
    int32_t aposta_id = ler_nat("ID da aposta: ");
    bool permitido;

    Apostas__pode_resgatar_reembolso(user_id, aposta_id, &permitido);
    if (permitido)
    {
        Apostas__resgatar_reembolso(user_id, aposta_id);
        printf("Reembolso resgatado.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void finalizar_evento(void)
{
    int32_t admin_id = ler_nat("ID do admin: ");
    int32_t evento_id = ler_nat("ID do evento: ");
    Apostas_Ctx__OPCAO_RESULTADO resultado = ler_resultado("Resultado vencedor: ");
    bool permitido;

    Apostas__pode_finalizar_evento(admin_id, evento_id, resultado, &permitido);
    if (permitido)
    {
        Apostas__finalizar_evento(admin_id, evento_id, resultado);
        printf("Evento finalizado.\n");
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void consultar_saldo_usuario(void)
{
    int32_t user_id = ler_nat("ID do usuario: ");
    bool permitido;
    int32_t saldo;

    Apostas__pode_consultar_saldo_usuario(user_id, &permitido);
    if (permitido)
    {
        Apostas__consultar_saldo_usuario(user_id, &saldo);
        printf("Saldo do usuario %d: %d\n", user_id, saldo);
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void consultar_saldo_casa(void)
{
    int32_t admin_id = ler_nat("ID do admin: ");
    bool permitido;
    int32_t saldo;

    Apostas__pode_consultar_saldo_casa(admin_id, &permitido);
    if (permitido)
    {
        Apostas__consultar_saldo_casa(admin_id, &saldo);
        printf("Saldo da casa: %d\n", saldo);
    }
    else
    {
        imprimir_permitido(permitido);
    }
}

static void listar_estado(void)
{
    int32_t qtd_usuarios;
    int32_t qtd_eventos;
    int32_t qtd_apostas;
    int32_t i;

    Apostas__consultar_qtd_usuarios(&qtd_usuarios);
    Apostas__consultar_qtd_eventos(&qtd_eventos);
    Apostas__consultar_qtd_apostas(&qtd_apostas);

    printf("\nUsuarios (%d):\n", qtd_usuarios);
    for (i = 1; i <= qtd_usuarios; i++)
    {
        Apostas_Ctx__STATUS_CONTA conta;
        bool admin;
        bool pode_saldo;

        Apostas__consultar_status_conta(i, &conta);
        Apostas__consultar_is_admin(i, &admin);
        Apostas__pode_consultar_saldo_usuario(i, &pode_saldo);

        printf("  #%d conta=%s admin=%s", i, texto_conta(conta), texto_bool(admin));
        if (pode_saldo)
        {
            int32_t saldo;
            Apostas__consultar_saldo_usuario(i, &saldo);
            printf(" saldo=%d", saldo);
        }
        printf("\n");
    }

    printf("\nEventos (%d):\n", qtd_eventos);
    for (i = 1; i <= qtd_eventos; i++)
    {
        Apostas_Ctx__STATUS_EVENTO status;
        Apostas_Ctx__OPCAO_RESULTADO resultado;
        int32_t odd;

        Apostas__consultar_status_evento(i, &status);
        Apostas__consultar_resultado_evento(i, &resultado);
        Apostas__consultar_odd_evento(i, &odd);
        printf("  #%d status=%s resultado=%s odd=%d\n",
               i,
               texto_evento(status),
               texto_resultado(resultado),
               odd);
    }

    printf("\nApostas (%d):\n", qtd_apostas);
    for (i = 1; i <= qtd_apostas; i++)
    {
        Apostas_Ctx__STATUS_APOSTA status;
        Apostas_Ctx__OPCAO_RESULTADO palpite;
        int32_t dono;
        int32_t evento;
        int32_t valor;
        int32_t odd;

        Apostas__consultar_status_aposta(i, &status);
        Apostas__consultar_dono_aposta(i, &dono);
        Apostas__consultar_evento_aposta(i, &evento);
        Apostas__consultar_valor_aposta(i, &valor);
        Apostas__consultar_palpite_aposta(i, &palpite);
        Apostas__consultar_odd_aposta(i, &odd);

        printf("  #%d dono=%d evento=%d valor=%d palpite=%s odd=%d status=%s\n",
               i,
               dono,
               evento,
               valor,
               texto_resultado(palpite),
               odd,
               texto_aposta(status));
    }
}

static void menu(void)
{
    printf("\n=== MF BET MACHINE ===\n");
    printf("1  - Cadastrar usuario\n");
    printf("2  - Depositar\n");
    printf("3  - Sacar\n");
    printf("4  - Criar evento\n");
    printf("5  - Abrir evento\n");
    printf("6  - Alterar odd do evento\n");
    printf("7  - Realizar aposta\n");
    printf("8  - Revogar aposta\n");
    printf("9  - Cancelar evento\n");
    printf("10 - Resgatar reembolso\n");
    printf("11 - Finalizar evento\n");
    printf("12 - Consultar saldo usuario\n");
    printf("13 - Consultar saldo casa\n");
    printf("14 - Listar estado\n");
    printf("0  - Sair\n");
}

int main(void)
{
    int32_t opcao;

    Apostas_Ctx__INITIALISATION();
    Apostas__INITIALISATION();

    printf("Sistema inicializado.\n");
    printf("Dica: o primeiro usuario deve ser cadastrado como admin.\n");

    do
    {
        menu();
        opcao = ler_int("Opcao: ");

        switch (opcao)
        {
        case 1:
            cadastrar_usuario();
            break;
        case 2:
            depositar();
            break;
        case 3:
            sacar();
            break;
        case 4:
            criar_evento();
            break;
        case 5:
            abrir_evento();
            break;
        case 6:
            alterar_odd_evento();
            break;
        case 7:
            realizar_aposta();
            break;
        case 8:
            revogar_aposta();
            break;
        case 9:
            cancelar_evento();
            break;
        case 10:
            resgatar_reembolso();
            break;
        case 11:
            finalizar_evento();
            break;
        case 12:
            consultar_saldo_usuario();
            break;
        case 13:
            consultar_saldo_casa();
            break;
        case 14:
            listar_estado();
            break;
        case 0:
            printf("Encerrando.\n");
            break;
        default:
            printf("Opcao invalida.\n");
            break;
        }
    } while (opcao != 0);

    return 0;
}

# MF-BET-MACHINE

Especificação formal, em Método B, de uma casa de apostas com usuários, eventos,
odds fixadas no momento da aposta, cancelamentos, reembolsos e liquidação de
resultados.

## Componentes

- `Apostas_Ctx.mch`: conjuntos enumerados, limites e constantes do domínio.
- `Apostas.mch`: máquina abstrata e regras de segurança.
- `Apostas_Ref.ref`: primeiro refinamento, com representação concreta por
  contadores e arrays totais de tamanho limitado.

O refinamento substitui os conjuntos e funções de domínio variável da máquina
abstrata por arrays definidos sobre `1..MAX_USERS`, `1..MAX_EVENTS` e
`1..MAX_APOSTAS`. Ele ainda não é a implementação B0 necessária para geração de
código: a etapa seguinte deverá importar máquinas básicas de arrays e converter
a liquidação em massa em laços determinísticos.

## Modelo de estado

### Usuários

- `usuarios`: identificadores cadastrados.
- `saldo_usuario`: saldo disponível de cada usuário.
- `status_conta`: conta `ativa`, `sob_analise` ou `suspensa`.
- `is_admin`: perfil administrativo.
- `contador_usuario`: próximo identificador.

O primeiro usuário cadastrado deve ser administrador. Cadastros posteriores
criam usuários comuns, que podem ser promovidos por um administrador ativo. O
último administrador não pode ser rebaixado.

### Eventos

- `eventos`: identificadores dos eventos.
- `status_evento`: `agendado`, `aberto`, `suspenso`, `finalizado` ou `cancelado`.
- `resultado_evento`: resultado válido ou `indefinido`.
- `odd_evento`: odd atualmente oferecida.
- `arrecadacao_evento`: soma das apostas pendentes enquanto o evento estiver
  aberto ou suspenso.
- `contador_evento`: próximo identificador.

### Apostas

- `apostas`: identificadores das apostas.
- `aposta_usuario` e `aposta_evento`: proprietário e evento associado.
- `aposta_valor` e `aposta_palpite`: valor e resultado escolhido.
- `aposta_odd`: odd salva no instante da aposta.
- `status_aposta_map`: `pendente`, `ganha`, `perdida`, `devolvida` ou
  `revogada_usuario`.
- `contador_aposta`: próximo identificador.

## Regras garantidas pelos invariantes

1. Os conjuntos de IDs são exatamente os intervalos já alocados pelos contadores.
2. Saldos de usuários e da casa nunca são negativos.
3. Sempre existe pelo menos um administrador após o primeiro cadastro.
4. Toda aposta respeita o valor mínimo e possui palpite definido.
5. Apostas ganhas têm palpite igual ao resultado; apostas perdidas têm palpite
   diferente.
6. Eventos não finalizados possuem resultado `indefinido`; eventos finalizados
   possuem resultado definido.
7. Apostas ganhas ou perdidas pertencem a eventos finalizados.
8. Apostas devolvidas pertencem a eventos cancelados.
9. Apostas pendentes pertencem a eventos abertos, suspensos ou cancelados.
10. Em eventos abertos ou suspensos, a arrecadação é exatamente a soma das
    apostas pendentes.

## Fluxos principais

### Cadastro e administração

- `cadastrar_usuario`: cria o primeiro administrador ou um usuário comum.
- `upgrade_usuario` e `downgrade_usuario`: alteram o perfil sem permitir a
  remoção do último administrador.
- `ativar_usuario`, `colocar_conta_em_analise` e `suspender_usuario`: alteram o
  estado da conta. Um administrador não pode suspender ou colocar a própria
  conta em análise.

Operações administrativas exigem administrador com conta ativa.

### Operações do apostador

- `depositar` e `sacar`: alteram a carteira de um usuário comum ativo.
- `realizar_aposta`: exige evento aberto, saldo suficiente, valor mínimo e salva
  a odd corrente.
- `revogar_aposta`: estorna uma aposta pendente durante evento aberto ou
  suspenso.
- `resgatar_reembolso`: devolve uma aposta pendente quando o evento foi
  cancelado.
- `consultar_saldo_usuario`, `consultar_odd_evento` e `consultar_odd_aposta`:
  consultas sem alteração de estado.

### Operações sobre eventos

- `criar_evento`: cria evento agendado com odd padrão.
- `abrir_evento`, `suspender_evento` e `retomar_evento`: controlam a recepção de
  apostas.
- `alterar_odd_evento`: altera a odd para apostas futuras; apostas existentes
  mantêm sua odd salva.
- `cancelar_evento`: habilita reembolsos individuais.
- `finalizar_evento`: define o resultado, classifica apostas pendentes e credita
  automaticamente os vencedores.

O pagamento utiliza aritmética inteira:

```text
premio = (valor_apostado * odd_salva) / 100
```

Assim, `130` representa odd `1.30` e eventuais frações são truncadas.

## Abstração financeira da casa

`saldo_casa` é um caixa administrativo independente. Nesta versão:

- apostas não entram no saldo da casa;
- prêmios não são descontados do saldo da casa;
- apostas perdidas não são transferidas para o saldo da casa;
- não existe taxa da casa.

Logo, o modelo verifica a liquidação das carteiras e apostas, mas não modela
solvência ou lucro real da plataforma. Essa é uma limitação deliberada do escopo
atual.

## Refinamento concreto

O refinamento utiliza nomes próprios para distinguir a representação concreta
do estado abstrato:

- `qtd_usuarios`, `qtd_eventos` e `qtd_apostas` armazenam quantos
  elementos de cada array estão em uso;
- arrays de usuários guardam saldo, estado da conta e perfil administrativo;
- arrays de eventos guardam estado, arrecadação, odd e resultado;
- arrays de apostas guardam usuário, evento, valor, palpite, odd e estado.

As posições acima dos contadores recebem valores padrão e não pertencem ao
estado abstrato observável. Os invariantes de ligação fazem essa projeção, por
exemplo:

```text
usuarios = 1..qtd_usuarios
saldo_usuario = usuarios <| saldos_usuarios
eventos = 1..qtd_eventos
apostas = 1..qtd_apostas
```

As operações do refinamento mantêm as mesmas entradas e saídas da máquina
abstrata. Suas cláusulas `PRE` foram omitidas: as condições de chamada são as
estabelecidas pela operação abstrata e pelas obrigações de refinamento.

## Validação

Os componentes devem ser adicionados ao mesmo projeto do Atelier B usando seus
nomes internos:

- `Apostas_Ctx`
- `Apostas`
- `Apostas_Ref`

Na validação automática realizada com Atelier B Community Edition 24.04.2:

- contexto e máquina abstrata passaram no verificador de tipos;
- o refinamento passou no verificador de tipos;
- todas as operações do refinamento possuem corpo e saídas inicializadas;
- a inicialização concreta teve todas as suas 30 obrigações provadas;
- o refinamento gerou 169 obrigações, das quais 102 foram provadas
  automaticamente na força 3;
- as 67 obrigações restantes concentram-se na preservação das projeções dos
  arrays, nos somatórios e na liquidação em massa, exigindo lemas ou prova
  interativa.

Antes da entrega, os cenários principais também devem ser animados no ProB,
incluindo limites, revogação, cancelamento, reembolso e finalização.

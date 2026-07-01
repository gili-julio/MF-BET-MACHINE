# MF-BET-MACHINE

Especificação formal, em Método B, de uma casa de apostas com usuários, eventos,
odds fixadas no momento da aposta, cancelamentos, reembolsos e liquidação de
resultados.

## Componentes

- `Apostas_Ctx.mch`: conjuntos enumerados, limites e constantes do domínio.
- `Apostas.mch`: máquina abstrata e regras de segurança.
- `Apostas_Ref.ref`: primeiro refinamento, com representação concreta por
  contadores e arrays totais de tamanho limitado.
- `Apostas_Imp.imp`: implementação B0 com arrays concretos diretos e laços
  determinísticos.

O refinamento substitui os conjuntos e funções de domínio variável da máquina
abstrata por arrays definidos sobre `1..MAX_USERS`, `1..MAX_EVENTS` e
`1..MAX_APOSTAS`. A implementação materializa esses arrays como variáveis
concretas totais sobre intervalos fixos e converte a liquidação em massa em um
laço determinístico.

## Modelo de estado

### Decisão sobre identificadores

Usuários, eventos e apostas usam identificadores contíguos:

```text
usuarios = 1..contador_usuario
eventos = 1..contador_evento
apostas = 1..contador_aposta
```

O modelo não remove fisicamente esses elementos. Em vez disso, usa estados de
domínio, como conta `suspensa`, evento `cancelado` e aposta `revogada_usuario`
ou `devolvida`. Essa decisão simplifica o refinamento, evita buracos nos arrays
concretos e mantém a geração automática de C mais direta.

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
11. Saldos e arrecadações são limitados a `SALDO_MAXIMO = 1000000`.
12. Operações financeiras individuais são limitadas a
    `VALOR_OPERACAO_MAXIMO = 100000`.

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
- `consultar_saldo_usuario`, `consultar_odd_evento`, `consultar_odd_aposta` e
  demais `consultar_*`: consultas sem alteração de estado para apoiar a futura
  interface.

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

### Resumo das operações e condições principais

| Grupo | Operações | Quem chama | Condição principal |
| --- | --- | --- | --- |
| Cadastro e perfis | `cadastrar_usuario`, `upgrade_usuario`, `downgrade_usuario` | sistema/admin | limite de usuários, primeiro usuário admin, admin ativo |
| Conta de usuário | `ativar_usuario`, `colocar_conta_em_analise`, `suspender_usuario` | admin | admin ativo e conta alvo existente |
| Carteira | `depositar`, `sacar` | usuário comum | conta ativa, valor válido e saldo/limite suficiente |
| Apostas | `realizar_aposta`, `revogar_aposta`, `resgatar_reembolso` | usuário comum | evento/conta/aposta em estado compatível |
| Eventos | `criar_evento`, `abrir_evento`, `suspender_evento`, `retomar_evento`, `alterar_odd_evento`, `finalizar_evento`, `cancelar_evento` | admin | admin ativo e transição válida do evento |
| Caixa da casa | `aportar_saldo_casa`, `sacar_lucro_casa`, `consultar_saldo_casa` | admin | admin ativo e limite financeiro respeitado |
| Consultas | `consultar_*` | interface | identificador existente quando a consulta recebe ID |
| Verificações | `pode_*` | interface | retornam `TRUE` quando a operação contratual pode ser chamada |

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

- `qtd_usuarios`, `qtd_eventos` e `qtd_apostas` armazenam quantos elementos de
  cada array estão em uso;
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

## Implementação B0

`Apostas_Imp.imp` refina `Apostas_Ref` e mantém um único componente principal.
As estruturas de usuários, eventos e apostas são armazenadas em 13 arrays
concretos diretos, tipados como funções totais sobre intervalos fixos:
`0..MAX_USERS`, `0..MAX_EVENTS` e `0..MAX_APOSTAS`.

As operações simples são traduzidas em leituras `array(indice)` e escritas
`array(indice) := valor`. `finalizar_evento` percorre as apostas com `WHILE`,
credita cada vencedor e atualiza o estado de cada aposta. O laço possui
invariante de tipagem e variante decrescente.

A finalização só pode ocorrer quando todos os saldos resultantes permanecem
dentro de `SALDO_MAXIMO`. Os limites também garantem que multiplicações e
somatórios financeiros permaneçam abaixo de `MAXINT`.

### Operações `pode_*`

Cada operação pública com pré-condição possui uma consulta booleana
correspondente, como:

- `pode_depositar`;
- `pode_realizar_aposta`;
- `pode_finalizar_evento`;
- `pode_cancelar_evento`.

Essas consultas verificam as regras sem alterar o estado. A futura interface
deverá chamar primeiro `pode_*` e somente então executar a operação contratual,
sem reimplementar regras de negócio. As consultas possuem apenas pré-condições
de tipagem, necessárias para gerar assinaturas C concretas.

As operações `consultar_qtd_usuarios`, `consultar_qtd_eventos` e
`consultar_qtd_apostas` permitem que a interface percorra os intervalos de IDs
válidos sem conhecer diretamente os contadores internos. As demais consultas de
estado retornam dados já modelados na máquina, como perfil administrativo,
estado da conta, estado do evento, resultado e dados da aposta.

## Validação

Os componentes devem ser adicionados ao mesmo projeto do Atelier B usando seus
nomes internos. Ordem recomendada para carregar e verificar:

- `Apostas_Ctx`
- `Apostas`
- `Apostas_Ref`
- `Apostas_Imp`

`Apostas_Imp` não depende de máquinas auxiliares de array. Isso evita problema
de caminho de biblioteca e evita a limitação do tradutor C com importações
renomeadas.

Na validação automática realizada com Atelier B Community Edition 24.04.2:

- contexto e máquina abstrata passaram no verificador de tipos;
- o refinamento passou no verificador de tipos;
- a implementação passou no verificador de tipos;
- a implementação passou integralmente no `b0check`;
- a tradução C com `ComenCtrans Apostas_Imp C9X` foi validada após a troca para
  arrays concretos diretos;
- todas as operações do refinamento possuem corpo e saídas inicializadas;
- as obrigações de prova foram geradas com `po <componente> 0`;
- a prova automática completa não foi executada nesta rodada; as obrigações
  permanecem disponíveis para prova posterior.

A geração automática de C já é viável a partir de `Apostas_Imp`. A interface
manual ainda pertence à próxima etapa do projeto e deve acessar apenas os
headers gerados pelo Atelier B.

Antes da entrega, os cenários principais também devem ser animados no ProB,
incluindo limites, revogação, cancelamento, reembolso e finalização.

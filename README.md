# MF-BET-MACHINE
The bet machine write in B for discipline Métodos Formais

# 📘 Documentação Técnica: Máquina Principal (`Apostas.mch`)

Este documento detalha o estado, as regras de segurança e as operações do sistema formal de Casa de Apostas desenvolvido em Método B. A arquitetura adota o paradigma de **Design by Contract (Projeto por Contrato)** e implementa **Controle de Acesso Baseado em Funções (RBAC)**, garantindo a integridade matemática do estado e a segregação de privilégios estrutural.

---

## 1. Variáveis de Estado

As variáveis representam os dados que o sistema armazena e manipula na memória durante o seu ciclo de vida.

| Variável | Tipo Matemático | Descrição |
| :--- | :--- | :--- |
| `saldo_casa` | Escalar | Lucro total da plataforma acumulado através da retenção de taxas. |
| `usuarios` | Conjunto | IDs numéricos de todos os usuários cadastrados. |
| `saldo_usuario` | Função (`-->`) | Mapeia o ID de cada usuário ao valor atual da sua carteira. |
| `is_admin` | Função (`-->`) | Mapeia se o usuário é um Administrador (`TRUE`) ou Comum (`FALSE`). |
| `status_conta` | Função (`-->`) | Mapeia o ID do usuário ao seu nível de permissão (`ativa`, `sob_analise`, `suspensa`). |
| `eventos` | Conjunto | IDs numéricos de todos os eventos esportivos criados. |
| `status_evento` | Função (`-->`) | Mapeia cada evento ao seu estado (`agendado`, `aberto`, `suspenso`, `finalizado`, `cancelado`). |
| `arrecadacao_evento` | Função (`-->`) | O "Bolo" (montante total) arrecadado pelas apostas em um evento. |
| `resultado_evento` | Função (`-->`) | Mapeia cada evento finalizado ao seu resultado vencedor. |
| `apostas` | Conjunto | IDs numéricos de todos os bilhetes de aposta registrados. |
| `aposta_usuario` | Função (`-->`) | Vincula o ID de uma aposta ao ID do usuário dono. |
| `aposta_evento` | Função (`-->`) | Vincula o ID de uma aposta ao ID do evento alvo. |
| `aposta_valor` | Função (`-->`) | Quantia financeira investida no bilhete. |
| `aposta_palpite` | Função (`-->`) | Escolha de resultado feita na aposta (vitória, empate, etc.). |
| `status_aposta_map`| Função (`-->`) | Estado do bilhete (`pendente`, `ganha`, `perdida`, `devolvida`, `revogada_usuario`). |

*(Nota: Variáveis de contadores auto-incrementais garantem a exclusividade de IDs gerados dinamicamente).*

---

## 2. Invariantes de Segurança (Regras de Negócio Críticas)

Os invariantes são as propriedades matemáticas blindadas do sistema. O Atelier-B atesta que o software nunca entrará em um estado que quebre essas leis:

1. **Solvência da Casa de Apostas (`saldo_casa : NAT`):** Prova matematicamente que a plataforma nunca operará no vermelho.
2. **Consistência Financeira (`saldo_usuario : usuarios --> NAT`):** É impossível que um usuário possua saldo negativo.
3. **Regra de Vitória e Derrota:** Uma aposta `ganha` ou `perdida` deve estar matematicamente alinhada com o `resultado_evento`.
4. **Integridade Temporal:** O resultado de um evento que não está `finalizado` deve ser rigorosamente `indefinido`. Uma aposta só pode ser `pendente` se o evento estiver `agendado` ou `aberto`.
5. **Completude do Resultado:** Todo evento `finalizado` obrigatoriamente possui um resultado válido.
6. **Coerência de Resolução:** Apostas só assumem o estado de `ganha` ou `perdida` se o evento já foi encerrado.
7. **Coerência de Estorno:** Uma aposta só pode ser marcada como `devolvida` se o evento correspondente foi `cancelado`.
8. **Lastro Financeiro Totalizador (Prova de Ouro):** Enquanto o evento estiver aberto ou suspenso, a `arrecadacao_evento` é exatamente igual ao somatório (`SIGMA`) de todas as apostas pendentes vinculadas a ele. Nenhum centavo é criado ou destruído.

---

## 3. Operações do Sistema

As operações alteram o estado caso as restrições da cláusula `PRE` (incluindo o papel do usuário) sejam plenamente satisfeitas.

### 👤 Gestão de Usuários (Administradores)
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `cadastrar_usuario` | `is_admin_param` | Cria um usuário, define seu perfil (`TRUE` para Admin, `FALSE` para Comum) e retorna o ID. |
| `downgrade_usuario` | `admin_id, target_user_id` | Rebaixa um Administrador para Usuário Comum. Um Admin não pode rebaixar a si mesmo. |
| `upgrade_usuario` | `admin_id, target_user_id` | Promove um Usuário Comum a Administrador. |
| `ativar_usuario` | `admin_id, target_user_id` | Restaura a conta para `ativa`, liberando fluxos de caixa e apostas. |
| `colocar_conta_em_analise`| `admin_id, target_user_id` | Altera a conta para `sob_analise` para investigar transações atípicas. |
| `suspender_usuario` | `admin_id, target_user_id` | Congela a conta. Impede interações com eventos e saques. |

### 🎰 Operações do Apostador (Usuários Comuns)
*Todas as operações deste bloco exigem que o usuário seja dono da carteira/aposta, possua conta `ativa` e `is_admin = FALSE`.*

| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `depositar` | `user_id, valor` | Adiciona fundos à carteira do apostador. |
| `sacar` | `user_id, valor` | Deduz fundos da carteira. Exige saldo suficiente. |
| `realizar_aposta` | `user_id, evento_id, palpite, valor` | Vincula a aposta, debita do usuário e soma ao "Bolo" do evento. |
| `revogar_aposta` | `user_id, aposta_id` | Direito de arrependimento antes do evento iniciar. Estorna os fundos e deduz do bolo do evento. |
| `resgatar_reembolso`| `user_id, aposta_id` | **Modelo Pull:** O usuário resgata o valor apostado de volta à carteira caso o evento tenha sido cancelado pela casa. |
| `consultar_saldo_usuario`| `user_id` | Retorna o saldo disponível na carteira. |

### 🏢 Operações da Plataforma (Administradores)
*Todas as operações deste bloco exigem identificação e credencial `is_admin = TRUE`.*

| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `aportar_saldo_casa` | `admin_id, valor` | Injeta capital diretamente no cofre da casa. |
| `sacar_lucro_casa` | `admin_id, valor` | Retira lucros acumulados do `saldo_casa`. |
| `criar_evento` | `admin_id` | Registra um evento `agendado`, zera o bolo e retorna o ID. |
| `abrir_evento` | `admin_id, evento_id` | Habilita o recebimento de apostas no evento. |
| `suspender_evento` | `admin_id, evento_id` | Bloqueia temporariamente um evento `aberto` (ex: revisão do VAR). |
| `retomar_evento` | `admin_id, evento_id` | Desbloqueia um evento `suspenso`. |
| `cancelar_evento` | `admin_id, evento_id` | Aborta o evento, marcando-o como `cancelado` para habilitar os estornos dos usuários. |
| `consultar_saldo_casa` | `admin_id` | Consulta o saldo do cofre da plataforma. |

### ⚡ Liquidação Automatizada de Prêmios
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `finalizar_evento` | `admin_id, evento_id, resultado_vencedor` | Encerra o evento. O rateio do bolo é calculado internamente pelo sistema via quantificador `SIGMA`. **Pagamento em Massa:** A plataforma distribui automaticamente os lucros diretamente nas carteiras das apostas vencedoras via Função Lambda (`<+` e `%uu`), eliminando a necessidade de os usuários solicitarem saque de prêmios. Em caso de "Zebra" (nenhum ganhador), a casa retém o bolo total. |
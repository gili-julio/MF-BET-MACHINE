# MF-BET-MACHINE
The bet machine write in B for discipline Métodos Formais

# 📘 Documentação Técnica: Máquina Principal (`Apostas.mch`)

Este documento detalha o estado, as regras de segurança e as operações do sistema formal de Casa de Apostas desenvolvido em Método B. A arquitetura adota o paradigma de **Design by Contract (Projeto por Contrato)**, onde a máquina abstrata garante a integridade matemática do estado exigindo o cumprimento estrito de Pré-Condições (`PRE`) antes de liberar qualquer operação.

---

## 1. Variáveis de Estado

As variáveis representam os dados que o sistema armazena e manipula na memória durante o seu ciclo de vida.

| Variável | Tipo Matemático | Descrição |
| :--- | :--- | :--- |
| `saldo_casa` | Escalar | Lucro total da plataforma acumulado através da retenção de taxas. |
| `usuarios` | Conjunto | IDs numéricos de todos os usuários cadastrados. |
| `saldo_usuario` | Função (`-->`) | Mapeia o ID de cada usuário ao valor atual da sua carteira. |
| `status_conta` | Função (`-->`) | Mapeia o ID do usuário ao seu nível de permissão (`ativa`, `sob_analise`, `suspensa`). |
| `eventos` | Conjunto | IDs numéricos de todos os eventos esportivos criados. |
| `status_evento` | Função (`-->`) | Mapeia cada evento ao seu estado (`agendado`, `aberto`, `suspenso`, `finalizado`, `cancelado`). |
| `arrecadacao_evento` | Função (`-->`) | O "Bolo" (montante total) arrecadado pelas apostas em um evento. |
| `apostas` | Conjunto | IDs numéricos de todos os bilhetes de aposta registrados. |
| `aposta_usuario` | Função (`-->`) | Vincula o ID de uma aposta ao ID do usuário dono. |
| `aposta_evento` | Função (`-->`) | Vincula o ID de uma aposta ao ID do evento alvo. |
| `aposta_valor` | Função (`-->`) | Quantia financeira investida no bilhete. |
| `aposta_palpite` | Função (`-->`) | Escolha de resultado feita na aposta (vitória, empate, etc.). |
| `status_aposta_map`| Função (`-->`) | Estado do bilhete (`pendente`, `ganha`, `perdida`, `devolvida`, `revogada_usuario`). |

*(Nota: Variáveis de contadores auto-incrementais como `contador_aposta` garantem a exclusividade de IDs gerados dinamicamente).*

---

## 2. Invariantes de Segurança (Regras de Negócio)

Os invariantes são as propriedades matemáticas blindadas do sistema. O Atelier-B atesta que o software nunca entrará em um estado que quebre essas leis:

*   **Tipagem e Limites de Capacidade:** O sistema trava a quantidade máxima de entidades (`card <= MAX`), prevenindo estouro de memória.
*   **Solvência da Casa de Apostas (`saldo_casa : NAT`):** Obriga o saldo da casa a pertencer aos Números Naturais. Prova matematicamente que a plataforma nunca operará no vermelho.
*   **Consistência Financeira (`saldo_usuario : usuarios --> NAT`):** É impossível que um usuário saque ou aposte um valor maior do que possui.
*   **Integridade dos Eventos (`arrecadacao_evento(ev) >= 0`):** O montante de um evento nunca pode ser negativo.
*   **Integridade das Apostas (`aposta_valor : apostas --> NAT1`):** A exclusão do zero (`NAT1`) prova que não existem apostas gratuitas; toda aposta exige fundos reais.
*   **Regras Universais de Resolução:** Uma aposta só pode ser designada como `ganha` ou `perdida` se estiver matematicamente alinhada com o resultado final do evento.

---

## 3. Operações do Sistema

As operações alteram o estado caso as restrições da cláusula `PRE` sejam plenamente satisfeitas. 

### 💰 Operações de Caixa e Gestão
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `aportar_saldo_casa` | `valor` | Injeta capital inicial ou de emergência diretamente no cofre da casa. |
| `sacar_lucro_casa` | `valor` | O administrador da plataforma retira lucros acumulados do `saldo_casa`. |
| `cadastrar_usuario` | *(Nenhum)* | Insere um novo usuário, inicializa sua carteira zerada, ativa a conta e retorna o ID gerado. |
| `depositar` | `user_id, valor` | Adiciona fundos à carteira. **Exige conta `ativa`.** |
| `sacar` | `user_id, valor` | Deduz fundos da carteira. **Exige conta `ativa` e saldo suficiente.** |

### 🏆 Operações de Eventos e Arrecadação
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `criar_evento` | *(Nenhum)* | Registra um evento como `agendado`, zera o bolo e retorna o ID. |
| `abrir_evento` | `evento_id` | Muda o status para `aberto`, habilitando o recebimento de apostas. |
| `suspender_evento` | `evento_id` | Bloqueia temporariamente um evento `aberto` (ex: revisão do VAR). |
| `retomar_evento` | `evento_id` | Desbloqueia um evento `suspenso`, voltando-o para `aberto`. |
| `realizar_aposta` | `user_id, evento_id, palpite, valor` | Vincula a aposta, debita do usuário e soma ao "Bolo" do evento. **Exige conta `ativa`.** Retorna o ID do bilhete. |
| `revogar_aposta` | `aposta_id` | Permite cancelar o bilhete antes do encerramento do evento. Devolve o dinheiro à carteira e subtrai do "Bolo". |
| `finalizar_evento` | `evento_id, resultado_vencedor` | Encerra o evento. Calcula a `TAXA_CASA`. **Cenário Zebra:** Se ninguém acertar, a casa recolhe 100% do bolo; se houver vencedores, retém apenas a taxa administrativa. |
| `cancelar_evento` | `evento_id` | Aborta o evento, marcando-o como `cancelado` para habilitar estornos completos. |

### 💸 Operações de Liquidação (Padrão Pull)
A arquitetura delega o resgate ao apostador, distribuindo a carga de forma descentralizada.

| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `resgatar_premio` | `aposta_id` | Vencedor resgata o prêmio. O rateio do bolo é calculado internamente pelo sistema via quantificador `SIGMA` (Totalizador). Errar o palpite altera o status para `perdida`. |
| `resgatar_reembolso`| `aposta_id` | Devolve o valor exato apostado de volta à carteira caso o evento associado tenha sido cancelado. |

### 🛡️ Operações de Segurança e Auditoria
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `ativar_usuario` | `user_id` | Restaura as permissões de uma conta para `ativa`, liberando fluxos de caixa e apostas. |
| `colocar_conta_em_analise`| `user_id` | Altera o status para `sob_analise` a fim de investigar transações atípicas. |
| `suspender_usuario` | `user_id` | Altera o status para `suspensa`. Congela todos os fundos do usuário, bloqueando interações com eventos e saques. |

### 📊 Operações de Consulta
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `consultar_saldo_casa` | *(Nenhum)* | Retorna o saldo total armazenado no cofre da plataforma. |
| `consultar_saldo_usuario`| `user_id` | Retorna o valor atual disponível na carteira de um usuário específico. |
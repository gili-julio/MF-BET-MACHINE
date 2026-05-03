# MF-BET-MACHINE
The bet machine write in B for discipline Métodos Formais

# 📘 Documentação Técnica: Máquina Principal (`Apostas.mch`)

Este documento detalha o estado, as regras de segurança e as operações do sistema formal de Casa de Apostas desenvolvido em Método B. A arquitetura adota o modelo de **"Interface Burra"**, onde a máquina abstrata B garante a integridade matemática do estado e devolve códigos de status para a camada de aplicação.

---

## 1. Variáveis de Estado

As variáveis representam os dados que o sistema armazena e manipula na memória durante o seu ciclo de vida.

| Variável | Tipo Matemático | Descrição |
| :--- | :--- | :--- |
| `saldo_casa` | Escalar | Lucro total da plataforma acumulado através da retenção de taxas. |
| `usuarios` | Conjunto | IDs numéricos de todos os usuários cadastrados. |
| `saldo_usuario` | Função (`-->`) | Mapeia o ID de cada usuário ao valor atual da sua carteira. |
| `status_conta` | Função (`-->`) | Mapeia o ID do usuário ao seu ciclo KYC (`pendente_documento`, `ativa`, `sob_analise`, `suspensa`, `banida`). |
| `eventos` | Conjunto | IDs numéricos de todos os eventos esportivos criados. |
| `status_evento` | Função (`-->`) | Mapeia cada evento ao seu estado (`agendado`, `aberto`, `suspenso`, `finalizado`, `cancelado`). |
| `arrecadacao_evento` | Função (`-->`) | O "Bolo" (montante total) arrecadado pelas apostas em um evento. |
| `apostas` | Conjunto | IDs numéricos de todos os bilhetes de aposta registrados. |
| `aposta_usuario` | Função (`-->`) | Vincula o ID de uma aposta ao ID do usuário dono. |
| `aposta_evento` | Função (`-->`) | Vincula o ID de uma aposta ao ID do evento alvo. |
| `aposta_valor` | Função (`-->`) | Quantia financeira investida no bilhete. |
| `aposta_palpite` | Função (`-->`) | Escolha de resultado feita na aposta (vitória, empate, etc.). |
| `status_aposta_map`| Função (`-->`) | Estado do bilhete (`pendente`, `ganha`, `perdida`, `devolvida`, `revogada_usuario`). |

---

## 2. Invariantes de Segurança (Regras de Negócio)

Os invariantes são as propriedades matemáticas blindadas do sistema. Se uma operação tentar violar qualquer uma dessas regras, o Atelier-B acusará falha na prova.

*   **Tipagem e Limites de Capacidade:** O sistema trava a quantidade máxima de entidades (`card <= MAX`), prevenindo estouro de memória.
*   **Solvência da Casa de Apostas (`saldo_casa : NAT`):** Obriga o saldo da casa a pertencer aos Números Naturais. Prova matematicamente que a plataforma nunca operará no vermelho.
*   **Consistência Financeira (`saldo_usuario : usuarios --> NAT`):** É impossível que um usuário saque ou aposte um valor maior do que possui. A operação é travada antes de negativar o saldo.
*   **Integridade dos Eventos (`arrecadacao_evento(ev) >= 0`):** O montante de um evento nunca pode ser negativo.
*   **Integridade das Apostas (`aposta_valor : apostas --> NAT1`):** A exclusão do zero (`NAT1`) prova que não existem apostas gratuitas; toda aposta exige fundos reais.
*   **Completude Relacional:** As funções totais obrigam que toda aposta e todo usuário possuam propriedades obrigatórias vinculadas. O sistema não permite entidades "órfãs".

---

## 3. Operações do Sistema

Todas as operações alteram o estado respeitando os Invariantes e retornam um código de `status`. O fluxo financeiro possui travas estritas de **KYC (Know Your Customer)**.

### 💰 Operações de Caixa e Gestão
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `aportar_saldo_casa` | `valor` | Injeta capital inicial ou de emergência diretamente no cofre da casa. |
| `sacar_lucro_casa` | `valor` | O administrador da plataforma retira os lucros acumulados do `saldo_casa`. |
| `cadastrar_usuario` | `user_id` | Insere um novo usuário e inicializa sua carteira zerada. **A conta nasce como `pendente_documento`.** |
| `depositar` | `user_id, valor` | Adiciona fundos à carteira. **Permitido para contas `ativa` ou `pendente_documento`.** |
| `sacar` | `user_id, valor` | Deduz fundos da carteira. **Exige conta `ativa` (Documento Aprovado).** Retorna erro se tentar sacar sem ter enviado documentos. |

### 🏆 Operações de Eventos e Arrecadação
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `criar_evento` | `evento_id` | Registra um evento como `agendado` e zera seu bolo de arrecadação. |
| `abrir_evento` | `evento_id` | Muda o status para `aberto`, habilitando o recebimento de apostas. |
| `suspender_evento` | `evento_id` | Bloqueia temporariamente um evento `aberto` (ex: revisão do VAR). |
| `retomar_evento` | `evento_id` | Desbloqueia um evento `suspenso`, voltando-o para `aberto`. |
| `realizar_aposta` | `aposta_id, user_id, evento_id, palpite, valor` | Vincula a aposta, debita do usuário e soma ao "Bolo" do evento. **Permitido para contas `ativa` ou `pendente_documento`.** |
| `revogar_aposta` | `aposta_id` | Permite cancelar o bilhete antes do encerramento. Devolve o dinheiro à carteira e subtrai do "Bolo". |
| `finalizar_evento` | `evento_id, resultado_vencedor` | Encerra o evento. Calcula a `TAXA_CASA` sobre o bolo e a transfere irrevogavelmente para o `saldo_casa`. |
| `cancelar_evento` | `evento_id` | Aborta o evento, marcando-o como `cancelado` para habilitar estornos. |

### 💸 Operações de Liquidação (Padrão Pull)
| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `resgatar_premio` | `aposta_id, premio_calculado` | Vencedor saca sua fração do prêmio. **Exige conta `ativa`**. Se estiver pendente de documento, o prêmio fica travado. |
| `resgatar_reembolso`| `aposta_id` | Devolve o valor exato apostado se o evento foi cancelado. |

### 🛡️ Operações Avançadas de Segurança e KYC
A arquitetura implementa um controle de estado irreversível para fraudadores, bloqueando matematicamente a saída de capital do sistema.

| Operação | Parâmetros | Descrição |
| :--- | :--- | :--- |
| `verificar_documento_kyc`| `user_id` | O administrador aprova o envio de documentos. Altera a conta de `pendente_documento` (ou `suspensa`) para `ativa`, liberando a função de saque. |
| `colocar_conta_em_analise`| `user_id` | Altera o status para `sob_analise` para investigar ganhos suspeitos. Congela todas as transações. |
| `banir_usuario_fraude` | `user_id` | **Buraco Negro de Estado:** Altera o status para `banida` de forma permanente. O usuário perde irreversivelmente o acesso aos fundos, pois a máquina não fornece operação de saída deste estado. |
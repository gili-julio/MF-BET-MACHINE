Normalised(
THEORY MagicNumberX IS
  MagicNumber(Machine(Apostas))==(3.5)
END
&
THEORY UpperLevelX IS
  First_Level(Machine(Apostas))==(Machine(Apostas));
  Level(Machine(Apostas))==(0)
END
&
THEORY LoadedStructureX IS
  Machine(Apostas)
END
&
THEORY ListSeesX IS
  List_Sees(Machine(Apostas))==(Apostas_Ctx)
END
&
THEORY ListUsesX IS
  List_Uses(Machine(Apostas))==(?)
END
&
THEORY ListIncludesX IS
  Inherited_List_Includes(Machine(Apostas))==(?);
  List_Includes(Machine(Apostas))==(?)
END
&
THEORY ListPromotesX IS
  List_Promotes(Machine(Apostas))==(?)
END
&
THEORY ListExtendsX IS
  List_Extends(Machine(Apostas))==(?)
END
&
THEORY ListVariablesX IS
  External_Context_List_Variables(Machine(Apostas))==(?);
  Context_List_Variables(Machine(Apostas))==(?);
  Abstract_List_Variables(Machine(Apostas))==(?);
  Local_List_Variables(Machine(Apostas))==(status_aposta_map,aposta_palpite,aposta_valor,aposta_evento,aposta_usuario,apostas,arrecadacao_evento,status_evento,eventos,saldo_usuario,usuarios,saldo_casa);
  List_Variables(Machine(Apostas))==(status_aposta_map,aposta_palpite,aposta_valor,aposta_evento,aposta_usuario,apostas,arrecadacao_evento,status_evento,eventos,saldo_usuario,usuarios,saldo_casa);
  External_List_Variables(Machine(Apostas))==(status_aposta_map,aposta_palpite,aposta_valor,aposta_evento,aposta_usuario,apostas,arrecadacao_evento,status_evento,eventos,saldo_usuario,usuarios,saldo_casa)
END
&
THEORY ListVisibleVariablesX IS
  Inherited_List_VisibleVariables(Machine(Apostas))==(?);
  Abstract_List_VisibleVariables(Machine(Apostas))==(?);
  External_List_VisibleVariables(Machine(Apostas))==(?);
  Expanded_List_VisibleVariables(Machine(Apostas))==(?);
  List_VisibleVariables(Machine(Apostas))==(?);
  Internal_List_VisibleVariables(Machine(Apostas))==(?)
END
&
THEORY ListInvariantX IS
  Gluing_Seen_List_Invariant(Machine(Apostas))==(btrue);
  Gluing_List_Invariant(Machine(Apostas))==(btrue);
  Expanded_List_Invariant(Machine(Apostas))==(btrue);
  Abstract_List_Invariant(Machine(Apostas))==(btrue);
  Context_List_Invariant(Machine(Apostas))==(btrue);
  List_Invariant(Machine(Apostas))==(saldo_casa: NAT & usuarios <: NAT & card(usuarios)<=MAX_USERS & saldo_usuario: usuarios --> NAT & eventos <: NAT & card(eventos)<=MAX_EVENTS & status_evento: eventos --> STATUS_EVENTO & arrecadacao_evento: eventos --> NAT & !ev.(ev: eventos => arrecadacao_evento(ev)>=0) & apostas <: NAT & card(apostas)<=MAX_APOSTAS & aposta_usuario: apostas --> usuarios & aposta_evento: apostas --> eventos & aposta_valor: apostas --> NAT1 & aposta_palpite: apostas --> OPCAO_RESULTADO & status_aposta_map: apostas --> STATUS_APOSTA)
END
&
THEORY ListAssertionsX IS
  Expanded_List_Assertions(Machine(Apostas))==(btrue);
  Abstract_List_Assertions(Machine(Apostas))==(btrue);
  Context_List_Assertions(Machine(Apostas))==(btrue);
  List_Assertions(Machine(Apostas))==(btrue)
END
&
THEORY ListCoverageX IS
  List_Coverage(Machine(Apostas))==(btrue)
END
&
THEORY ListExclusivityX IS
  List_Exclusivity(Machine(Apostas))==(btrue)
END
&
THEORY ListInitialisationX IS
  Expanded_List_Initialisation(Machine(Apostas))==(saldo_casa,usuarios,saldo_usuario,eventos,status_evento,arrecadacao_evento,apostas,aposta_usuario,aposta_evento,aposta_valor,aposta_palpite,status_aposta_map:=0,{},{},{},{},{},{},{},{},{},{},{});
  Context_List_Initialisation(Machine(Apostas))==(skip);
  List_Initialisation(Machine(Apostas))==(saldo_casa:=0 || usuarios:={} || saldo_usuario:={} || eventos:={} || status_evento:={} || arrecadacao_evento:={} || apostas:={} || aposta_usuario:={} || aposta_evento:={} || aposta_valor:={} || aposta_palpite:={} || status_aposta_map:={})
END
&
THEORY ListParametersX IS
  List_Parameters(Machine(Apostas))==(?)
END
&
THEORY ListInstanciatedParametersX IS
  List_Instanciated_Parameters(Machine(Apostas),Machine(Apostas_Ctx))==(?)
END
&
THEORY ListConstraintsX IS
  List_Context_Constraints(Machine(Apostas))==(btrue);
  List_Constraints(Machine(Apostas))==(btrue)
END
&
THEORY ListOperationsX IS
  Internal_List_Operations(Machine(Apostas))==(aportar_saldo_casa,cadastrar_usuario,depositar,sacar,criar_evento,abrir_evento,realizar_aposta,finalizar_evento,cancelar_evento,resgatar_premio,resgatar_reembolso);
  List_Operations(Machine(Apostas))==(aportar_saldo_casa,cadastrar_usuario,depositar,sacar,criar_evento,abrir_evento,realizar_aposta,finalizar_evento,cancelar_evento,resgatar_premio,resgatar_reembolso)
END
&
THEORY ListInputX IS
  List_Input(Machine(Apostas),aportar_saldo_casa)==(valor);
  List_Input(Machine(Apostas),cadastrar_usuario)==(user_id);
  List_Input(Machine(Apostas),depositar)==(user_id,valor);
  List_Input(Machine(Apostas),sacar)==(user_id,valor);
  List_Input(Machine(Apostas),criar_evento)==(evento_id);
  List_Input(Machine(Apostas),abrir_evento)==(evento_id);
  List_Input(Machine(Apostas),realizar_aposta)==(aposta_id,user_id,evento_id,palpite,valor);
  List_Input(Machine(Apostas),finalizar_evento)==(evento_id,resultado_vencedor);
  List_Input(Machine(Apostas),cancelar_evento)==(evento_id);
  List_Input(Machine(Apostas),resgatar_premio)==(aposta_id,premio_calculado);
  List_Input(Machine(Apostas),resgatar_reembolso)==(aposta_id)
END
&
THEORY ListOutputX IS
  List_Output(Machine(Apostas),aportar_saldo_casa)==(status);
  List_Output(Machine(Apostas),cadastrar_usuario)==(status);
  List_Output(Machine(Apostas),depositar)==(status);
  List_Output(Machine(Apostas),sacar)==(status);
  List_Output(Machine(Apostas),criar_evento)==(status);
  List_Output(Machine(Apostas),abrir_evento)==(status);
  List_Output(Machine(Apostas),realizar_aposta)==(status);
  List_Output(Machine(Apostas),finalizar_evento)==(status);
  List_Output(Machine(Apostas),cancelar_evento)==(status);
  List_Output(Machine(Apostas),resgatar_premio)==(status);
  List_Output(Machine(Apostas),resgatar_reembolso)==(status)
END
&
THEORY ListHeaderX IS
  List_Header(Machine(Apostas),aportar_saldo_casa)==(status <-- aportar_saldo_casa(valor));
  List_Header(Machine(Apostas),cadastrar_usuario)==(status <-- cadastrar_usuario(user_id));
  List_Header(Machine(Apostas),depositar)==(status <-- depositar(user_id,valor));
  List_Header(Machine(Apostas),sacar)==(status <-- sacar(user_id,valor));
  List_Header(Machine(Apostas),criar_evento)==(status <-- criar_evento(evento_id));
  List_Header(Machine(Apostas),abrir_evento)==(status <-- abrir_evento(evento_id));
  List_Header(Machine(Apostas),realizar_aposta)==(status <-- realizar_aposta(aposta_id,user_id,evento_id,palpite,valor));
  List_Header(Machine(Apostas),finalizar_evento)==(status <-- finalizar_evento(evento_id,resultado_vencedor));
  List_Header(Machine(Apostas),cancelar_evento)==(status <-- cancelar_evento(evento_id));
  List_Header(Machine(Apostas),resgatar_premio)==(status <-- resgatar_premio(aposta_id,premio_calculado));
  List_Header(Machine(Apostas),resgatar_reembolso)==(status <-- resgatar_reembolso(aposta_id))
END
&
THEORY ListOperationGuardX END
&
THEORY ListPreconditionX IS
  List_Precondition(Machine(Apostas),aportar_saldo_casa)==(valor: NAT);
  List_Precondition(Machine(Apostas),cadastrar_usuario)==(user_id: NAT);
  List_Precondition(Machine(Apostas),depositar)==(user_id: NAT & valor: NAT);
  List_Precondition(Machine(Apostas),sacar)==(user_id: NAT & valor: NAT);
  List_Precondition(Machine(Apostas),criar_evento)==(evento_id: NAT);
  List_Precondition(Machine(Apostas),abrir_evento)==(evento_id: NAT);
  List_Precondition(Machine(Apostas),realizar_aposta)==(aposta_id: NAT & user_id: NAT & evento_id: NAT & palpite: OPCAO_RESULTADO & valor: NAT);
  List_Precondition(Machine(Apostas),finalizar_evento)==(evento_id: NAT & resultado_vencedor: OPCAO_RESULTADO);
  List_Precondition(Machine(Apostas),cancelar_evento)==(evento_id: NAT);
  List_Precondition(Machine(Apostas),resgatar_premio)==(aposta_id: NAT & premio_calculado: NAT);
  List_Precondition(Machine(Apostas),resgatar_reembolso)==(aposta_id: NAT)
END
&
THEORY ListSubstitutionX IS
  Expanded_List_Substitution(Machine(Apostas),resgatar_reembolso)==(aposta_id: NAT | aposta_id: apostas ==> (status_evento(aposta_evento(aposta_id)) = cancelado ==> (status_aposta_map(aposta_id) = pendente ==> saldo_usuario,status_aposta_map,status:=saldo_usuario<+{aposta_usuario(aposta_id)|->saldo_usuario(aposta_usuario(aposta_id))+aposta_valor(aposta_id)},status_aposta_map<+{aposta_id|->devolvida},sucesso [] not(status_aposta_map(aposta_id) = pendente) ==> status:=erro_estado_invalido) [] not(status_evento(aposta_evento(aposta_id)) = cancelado) ==> status:=erro_evento_invalido) [] not(aposta_id: apostas) ==> status:=erro_nao_encontrado);
  Expanded_List_Substitution(Machine(Apostas),resgatar_premio)==(aposta_id: NAT & premio_calculado: NAT | aposta_id: apostas ==> (status_evento(aposta_evento(aposta_id)) = finalizado ==> (status_aposta_map(aposta_id) = pendente ==> saldo_usuario,status_aposta_map,status:=saldo_usuario<+{aposta_usuario(aposta_id)|->saldo_usuario(aposta_usuario(aposta_id))+premio_calculado},status_aposta_map<+{aposta_id|->ganha},sucesso [] not(status_aposta_map(aposta_id) = pendente) ==> status:=erro_estado_invalido) [] not(status_evento(aposta_evento(aposta_id)) = finalizado) ==> status:=erro_evento_invalido) [] not(aposta_id: apostas) ==> status:=erro_nao_encontrado);
  Expanded_List_Substitution(Machine(Apostas),cancelar_evento)==(evento_id: NAT | evento_id: eventos & status_evento(evento_id) = aberto ==> status_evento,status:=status_evento<+{evento_id|->cancelado},sucesso [] not(evento_id: eventos & status_evento(evento_id) = aberto) ==> status:=erro_evento_invalido);
  Expanded_List_Substitution(Machine(Apostas),finalizar_evento)==(evento_id: NAT & resultado_vencedor: OPCAO_RESULTADO | evento_id: eventos & status_evento(evento_id) = aberto ==> saldo_casa,status_evento,status:=saldo_casa+arrecadacao_evento(evento_id)*TAXA_CASA/100,status_evento<+{evento_id|->finalizado},sucesso [] not(evento_id: eventos & status_evento(evento_id) = aberto) ==> status:=erro_evento_invalido);
  Expanded_List_Substitution(Machine(Apostas),realizar_aposta)==(aposta_id: NAT & user_id: NAT & evento_id: NAT & palpite: OPCAO_RESULTADO & valor: NAT | aposta_id/:apostas & card(apostas)<MAX_APOSTAS & user_id: usuarios & evento_id: eventos ==> (status_evento(evento_id) = aberto & valor>=APOSTA_MINIMA ==> (saldo_usuario(user_id)>=valor ==> apostas,aposta_usuario,aposta_evento,aposta_valor,aposta_palpite,status_aposta_map,saldo_usuario,arrecadacao_evento,status:=apostas\/{aposta_id},aposta_usuario<+{aposta_id|->user_id},aposta_evento<+{aposta_id|->evento_id},aposta_valor<+{aposta_id|->valor},aposta_palpite<+{aposta_id|->palpite},status_aposta_map<+{aposta_id|->pendente},saldo_usuario<+{user_id|->saldo_usuario(user_id)-valor},arrecadacao_evento<+{evento_id|->arrecadacao_evento(evento_id)+valor},sucesso [] not(saldo_usuario(user_id)>=valor) ==> status:=erro_saldo_insuficiente) [] not(status_evento(evento_id) = aberto & valor>=APOSTA_MINIMA) ==> status:=erro_evento_invalido) [] not(aposta_id/:apostas & card(apostas)<MAX_APOSTAS & user_id: usuarios & evento_id: eventos) ==> status:=erro_nao_encontrado);
  Expanded_List_Substitution(Machine(Apostas),abrir_evento)==(evento_id: NAT | evento_id: eventos ==> (status_evento(evento_id) = agendado ==> status_evento,status:=status_evento<+{evento_id|->aberto},sucesso [] not(status_evento(evento_id) = agendado) ==> status:=erro_estado_invalido) [] not(evento_id: eventos) ==> status:=erro_nao_encontrado);
  Expanded_List_Substitution(Machine(Apostas),criar_evento)==(evento_id: NAT | evento_id/:eventos & card(eventos)<MAX_EVENTS ==> eventos,status_evento,arrecadacao_evento,status:=eventos\/{evento_id},status_evento<+{evento_id|->agendado},arrecadacao_evento<+{evento_id|->0},sucesso [] not(evento_id/:eventos & card(eventos)<MAX_EVENTS) ==> status:=erro_limite_excedido);
  Expanded_List_Substitution(Machine(Apostas),sacar)==(user_id: NAT & valor: NAT | user_id: usuarios ==> (saldo_usuario(user_id)>=valor ==> saldo_usuario,status:=saldo_usuario<+{user_id|->saldo_usuario(user_id)-valor},sucesso [] not(saldo_usuario(user_id)>=valor) ==> status:=erro_saldo_insuficiente) [] not(user_id: usuarios) ==> status:=erro_nao_encontrado);
  Expanded_List_Substitution(Machine(Apostas),depositar)==(user_id: NAT & valor: NAT | user_id: usuarios ==> saldo_usuario,status:=saldo_usuario<+{user_id|->saldo_usuario(user_id)+valor},sucesso [] not(user_id: usuarios) ==> status:=erro_nao_encontrado);
  Expanded_List_Substitution(Machine(Apostas),cadastrar_usuario)==(user_id: NAT | user_id/:usuarios & card(usuarios)<MAX_USERS ==> usuarios,saldo_usuario,status:=usuarios\/{user_id},saldo_usuario<+{user_id|->0},sucesso [] not(user_id/:usuarios & card(usuarios)<MAX_USERS) ==> status:=erro_limite_excedido);
  Expanded_List_Substitution(Machine(Apostas),aportar_saldo_casa)==(valor: NAT | saldo_casa,status:=saldo_casa+valor,sucesso);
  List_Substitution(Machine(Apostas),aportar_saldo_casa)==(saldo_casa:=saldo_casa+valor || status:=sucesso);
  List_Substitution(Machine(Apostas),cadastrar_usuario)==(IF user_id/:usuarios & card(usuarios)<MAX_USERS THEN usuarios:=usuarios\/{user_id} || saldo_usuario(user_id):=0 || status:=sucesso ELSE status:=erro_limite_excedido END);
  List_Substitution(Machine(Apostas),depositar)==(IF user_id: usuarios THEN saldo_usuario(user_id):=saldo_usuario(user_id)+valor || status:=sucesso ELSE status:=erro_nao_encontrado END);
  List_Substitution(Machine(Apostas),sacar)==(IF user_id: usuarios THEN IF saldo_usuario(user_id)>=valor THEN saldo_usuario(user_id):=saldo_usuario(user_id)-valor || status:=sucesso ELSE status:=erro_saldo_insuficiente END ELSE status:=erro_nao_encontrado END);
  List_Substitution(Machine(Apostas),criar_evento)==(IF evento_id/:eventos & card(eventos)<MAX_EVENTS THEN eventos:=eventos\/{evento_id} || status_evento(evento_id):=agendado || arrecadacao_evento(evento_id):=0 || status:=sucesso ELSE status:=erro_limite_excedido END);
  List_Substitution(Machine(Apostas),abrir_evento)==(IF evento_id: eventos THEN IF status_evento(evento_id) = agendado THEN status_evento(evento_id):=aberto || status:=sucesso ELSE status:=erro_estado_invalido END ELSE status:=erro_nao_encontrado END);
  List_Substitution(Machine(Apostas),realizar_aposta)==(IF aposta_id/:apostas & card(apostas)<MAX_APOSTAS & user_id: usuarios & evento_id: eventos THEN IF status_evento(evento_id) = aberto & valor>=APOSTA_MINIMA THEN IF saldo_usuario(user_id)>=valor THEN apostas:=apostas\/{aposta_id} || aposta_usuario(aposta_id):=user_id || aposta_evento(aposta_id):=evento_id || aposta_valor(aposta_id):=valor || aposta_palpite(aposta_id):=palpite || status_aposta_map(aposta_id):=pendente || saldo_usuario(user_id):=saldo_usuario(user_id)-valor || arrecadacao_evento(evento_id):=arrecadacao_evento(evento_id)+valor || status:=sucesso ELSE status:=erro_saldo_insuficiente END ELSE status:=erro_evento_invalido END ELSE status:=erro_nao_encontrado END);
  List_Substitution(Machine(Apostas),finalizar_evento)==(IF evento_id: eventos & status_evento(evento_id) = aberto THEN saldo_casa:=saldo_casa+arrecadacao_evento(evento_id)*TAXA_CASA/100 || status_evento(evento_id):=finalizado || status:=sucesso ELSE status:=erro_evento_invalido END);
  List_Substitution(Machine(Apostas),cancelar_evento)==(IF evento_id: eventos & status_evento(evento_id) = aberto THEN status_evento(evento_id):=cancelado || status:=sucesso ELSE status:=erro_evento_invalido END);
  List_Substitution(Machine(Apostas),resgatar_premio)==(IF aposta_id: apostas THEN IF status_evento(aposta_evento(aposta_id)) = finalizado THEN IF status_aposta_map(aposta_id) = pendente THEN saldo_usuario(aposta_usuario(aposta_id)):=saldo_usuario(aposta_usuario(aposta_id))+premio_calculado || status_aposta_map(aposta_id):=ganha || status:=sucesso ELSE status:=erro_estado_invalido END ELSE status:=erro_evento_invalido END ELSE status:=erro_nao_encontrado END);
  List_Substitution(Machine(Apostas),resgatar_reembolso)==(IF aposta_id: apostas THEN IF status_evento(aposta_evento(aposta_id)) = cancelado THEN IF status_aposta_map(aposta_id) = pendente THEN saldo_usuario(aposta_usuario(aposta_id)):=saldo_usuario(aposta_usuario(aposta_id))+aposta_valor(aposta_id) || status_aposta_map(aposta_id):=devolvida || status:=sucesso ELSE status:=erro_estado_invalido END ELSE status:=erro_evento_invalido END ELSE status:=erro_nao_encontrado END)
END
&
THEORY ListConstantsX IS
  List_Valuable_Constants(Machine(Apostas))==(?);
  Inherited_List_Constants(Machine(Apostas))==(?);
  List_Constants(Machine(Apostas))==(?)
END
&
THEORY ListSetsX IS
  Set_Definition(Machine(Apostas),STATUS_RETORNO)==({sucesso,erro_saldo_insuficiente,erro_evento_invalido,erro_limite_excedido,erro_nao_encontrado,erro_estado_invalido});
  Context_List_Enumerated(Machine(Apostas))==(STATUS_EVENTO,STATUS_APOSTA,OPCAO_RESULTADO,STATUS_RETORNO);
  Context_List_Defered(Machine(Apostas))==(?);
  Context_List_Sets(Machine(Apostas))==(STATUS_EVENTO,STATUS_APOSTA,OPCAO_RESULTADO,STATUS_RETORNO);
  List_Valuable_Sets(Machine(Apostas))==(?);
  Inherited_List_Enumerated(Machine(Apostas))==(?);
  Inherited_List_Defered(Machine(Apostas))==(?);
  Inherited_List_Sets(Machine(Apostas))==(?);
  List_Enumerated(Machine(Apostas))==(?);
  List_Defered(Machine(Apostas))==(?);
  List_Sets(Machine(Apostas))==(?);
  Set_Definition(Machine(Apostas),OPCAO_RESULTADO)==({vitoria_A,empate,vitoria_B});
  Set_Definition(Machine(Apostas),STATUS_APOSTA)==({pendente,ganha,perdida,devolvida});
  Set_Definition(Machine(Apostas),STATUS_EVENTO)==({agendado,aberto,finalizado,cancelado})
END
&
THEORY ListHiddenConstantsX IS
  Abstract_List_HiddenConstants(Machine(Apostas))==(?);
  Expanded_List_HiddenConstants(Machine(Apostas))==(?);
  List_HiddenConstants(Machine(Apostas))==(?);
  External_List_HiddenConstants(Machine(Apostas))==(?)
END
&
THEORY ListPropertiesX IS
  Abstract_List_Properties(Machine(Apostas))==(btrue);
  Context_List_Properties(Machine(Apostas))==(MAX_USERS: NAT1 & MAX_EVENTS: NAT1 & MAX_APOSTAS: NAT1 & TAXA_CASA: NAT & APOSTA_MINIMA: NAT1 & MAX_USERS = 1000 & MAX_EVENTS = 100 & MAX_APOSTAS = 10000 & TAXA_CASA = 10 & APOSTA_MINIMA = 5 & STATUS_EVENTO: FIN(INTEGER) & not(STATUS_EVENTO = {}) & STATUS_APOSTA: FIN(INTEGER) & not(STATUS_APOSTA = {}) & OPCAO_RESULTADO: FIN(INTEGER) & not(OPCAO_RESULTADO = {}) & STATUS_RETORNO: FIN(INTEGER) & not(STATUS_RETORNO = {}));
  Inherited_List_Properties(Machine(Apostas))==(btrue);
  List_Properties(Machine(Apostas))==(btrue)
END
&
THEORY ListSeenInfoX IS
  Seen_Internal_List_Operations(Machine(Apostas),Machine(Apostas_Ctx))==(?);
  Seen_Context_List_Enumerated(Machine(Apostas))==(?);
  Seen_Context_List_Invariant(Machine(Apostas))==(btrue);
  Seen_Context_List_Assertions(Machine(Apostas))==(btrue);
  Seen_Context_List_Properties(Machine(Apostas))==(btrue);
  Seen_List_Constraints(Machine(Apostas))==(btrue);
  Seen_List_Operations(Machine(Apostas),Machine(Apostas_Ctx))==(?);
  Seen_Expanded_List_Invariant(Machine(Apostas),Machine(Apostas_Ctx))==(btrue)
END
&
THEORY ListANYVarX IS
  List_ANY_Var(Machine(Apostas),aportar_saldo_casa)==(?);
  List_ANY_Var(Machine(Apostas),cadastrar_usuario)==(?);
  List_ANY_Var(Machine(Apostas),depositar)==(?);
  List_ANY_Var(Machine(Apostas),sacar)==(?);
  List_ANY_Var(Machine(Apostas),criar_evento)==(?);
  List_ANY_Var(Machine(Apostas),abrir_evento)==(?);
  List_ANY_Var(Machine(Apostas),realizar_aposta)==(?);
  List_ANY_Var(Machine(Apostas),finalizar_evento)==(?);
  List_ANY_Var(Machine(Apostas),cancelar_evento)==(?);
  List_ANY_Var(Machine(Apostas),resgatar_premio)==(?);
  List_ANY_Var(Machine(Apostas),resgatar_reembolso)==(?)
END
&
THEORY ListOfIdsX IS
  List_Of_Ids(Machine(Apostas)) == (? | ? | status_aposta_map,aposta_palpite,aposta_valor,aposta_evento,aposta_usuario,apostas,arrecadacao_evento,status_evento,eventos,saldo_usuario,usuarios,saldo_casa | ? | aportar_saldo_casa,cadastrar_usuario,depositar,sacar,criar_evento,abrir_evento,realizar_aposta,finalizar_evento,cancelar_evento,resgatar_premio,resgatar_reembolso | ? | seen(Machine(Apostas_Ctx)) | ? | Apostas);
  List_Of_HiddenCst_Ids(Machine(Apostas)) == (? | ?);
  List_Of_VisibleCst_Ids(Machine(Apostas)) == (?);
  List_Of_VisibleVar_Ids(Machine(Apostas)) == (? | ?);
  List_Of_Ids_SeenBNU(Machine(Apostas)) == (?: ?);
  List_Of_Ids(Machine(Apostas_Ctx)) == (MAX_USERS,MAX_EVENTS,MAX_APOSTAS,TAXA_CASA,APOSTA_MINIMA,STATUS_EVENTO,STATUS_APOSTA,OPCAO_RESULTADO,STATUS_RETORNO,agendado,aberto,finalizado,cancelado,pendente,ganha,perdida,devolvida,vitoria_A,empate,vitoria_B,sucesso,erro_saldo_insuficiente,erro_evento_invalido,erro_limite_excedido,erro_nao_encontrado,erro_estado_invalido | ? | ? | ? | ? | ? | ? | ? | Apostas_Ctx);
  List_Of_HiddenCst_Ids(Machine(Apostas_Ctx)) == (? | ?);
  List_Of_VisibleCst_Ids(Machine(Apostas_Ctx)) == (MAX_USERS,MAX_EVENTS,MAX_APOSTAS,TAXA_CASA,APOSTA_MINIMA);
  List_Of_VisibleVar_Ids(Machine(Apostas_Ctx)) == (? | ?);
  List_Of_Ids_SeenBNU(Machine(Apostas_Ctx)) == (?: ?)
END
&
THEORY VariablesEnvX IS
  Variables(Machine(Apostas)) == (Type(status_aposta_map) == Mvl(SetOf(btype(INTEGER,?,?)*etype(STATUS_APOSTA,0,3)));Type(aposta_palpite) == Mvl(SetOf(btype(INTEGER,?,?)*etype(OPCAO_RESULTADO,0,2)));Type(aposta_valor) == Mvl(SetOf(btype(INTEGER,?,?)*btype(INTEGER,1,MAXINT)));Type(aposta_evento) == Mvl(SetOf(btype(INTEGER,?,?)*btype(INTEGER,?,?)));Type(aposta_usuario) == Mvl(SetOf(btype(INTEGER,?,?)*btype(INTEGER,?,?)));Type(apostas) == Mvl(SetOf(btype(INTEGER,?,?)));Type(arrecadacao_evento) == Mvl(SetOf(btype(INTEGER,?,?)*btype(INTEGER,0,MAXINT)));Type(status_evento) == Mvl(SetOf(btype(INTEGER,?,?)*etype(STATUS_EVENTO,0,3)));Type(eventos) == Mvl(SetOf(btype(INTEGER,?,?)));Type(saldo_usuario) == Mvl(SetOf(btype(INTEGER,?,?)*btype(INTEGER,0,MAXINT)));Type(usuarios) == Mvl(SetOf(btype(INTEGER,?,?)));Type(saldo_casa) == Mvl(btype(INTEGER,?,?)))
END
&
THEORY OperationsEnvX IS
  Operations(Machine(Apostas)) == (Type(resgatar_reembolso) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?));Type(resgatar_premio) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?)*btype(INTEGER,?,?));Type(cancelar_evento) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?));Type(finalizar_evento) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?)*etype(OPCAO_RESULTADO,?,?));Type(realizar_aposta) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?)*btype(INTEGER,?,?)*btype(INTEGER,?,?)*etype(OPCAO_RESULTADO,?,?)*btype(INTEGER,?,?));Type(abrir_evento) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?));Type(criar_evento) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?));Type(sacar) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?)*btype(INTEGER,?,?));Type(depositar) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?)*btype(INTEGER,?,?));Type(cadastrar_usuario) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?));Type(aportar_saldo_casa) == Cst(etype(STATUS_RETORNO,?,?),btype(INTEGER,?,?)))
END
&
THEORY TCIntRdX IS
  predB0 == OK;
  extended_sees == KO;
  B0check_tab == KO;
  local_op == OK;
  abstract_constants_visible_in_values == KO;
  project_type == SOFTWARE_TYPE;
  event_b_deadlockfreeness == KO;
  variant_clause_mandatory == KO;
  event_b_coverage == KO;
  event_b_exclusivity == KO;
  genFeasibilityPO == KO
END
)

Normalised(
THEORY MagicNumberX IS
  MagicNumber(Machine(Apostas_Ctx))==(3.5)
END
&
THEORY UpperLevelX IS
  First_Level(Machine(Apostas_Ctx))==(Machine(Apostas_Ctx));
  Level(Machine(Apostas_Ctx))==(0)
END
&
THEORY LoadedStructureX IS
  Machine(Apostas_Ctx)
END
&
THEORY ListSeesX IS
  List_Sees(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListUsesX IS
  List_Uses(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListIncludesX IS
  Inherited_List_Includes(Machine(Apostas_Ctx))==(?);
  List_Includes(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListPromotesX IS
  List_Promotes(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListExtendsX IS
  List_Extends(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListVariablesX IS
  External_Context_List_Variables(Machine(Apostas_Ctx))==(?);
  Context_List_Variables(Machine(Apostas_Ctx))==(?);
  Abstract_List_Variables(Machine(Apostas_Ctx))==(?);
  Local_List_Variables(Machine(Apostas_Ctx))==(?);
  List_Variables(Machine(Apostas_Ctx))==(?);
  External_List_Variables(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListVisibleVariablesX IS
  Inherited_List_VisibleVariables(Machine(Apostas_Ctx))==(?);
  Abstract_List_VisibleVariables(Machine(Apostas_Ctx))==(?);
  External_List_VisibleVariables(Machine(Apostas_Ctx))==(?);
  Expanded_List_VisibleVariables(Machine(Apostas_Ctx))==(?);
  List_VisibleVariables(Machine(Apostas_Ctx))==(?);
  Internal_List_VisibleVariables(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListInvariantX IS
  Gluing_Seen_List_Invariant(Machine(Apostas_Ctx))==(btrue);
  Gluing_List_Invariant(Machine(Apostas_Ctx))==(btrue);
  Expanded_List_Invariant(Machine(Apostas_Ctx))==(btrue);
  Abstract_List_Invariant(Machine(Apostas_Ctx))==(btrue);
  Context_List_Invariant(Machine(Apostas_Ctx))==(btrue);
  List_Invariant(Machine(Apostas_Ctx))==(btrue)
END
&
THEORY ListAssertionsX IS
  Expanded_List_Assertions(Machine(Apostas_Ctx))==(btrue);
  Abstract_List_Assertions(Machine(Apostas_Ctx))==(btrue);
  Context_List_Assertions(Machine(Apostas_Ctx))==(btrue);
  List_Assertions(Machine(Apostas_Ctx))==(btrue)
END
&
THEORY ListCoverageX IS
  List_Coverage(Machine(Apostas_Ctx))==(btrue)
END
&
THEORY ListExclusivityX IS
  List_Exclusivity(Machine(Apostas_Ctx))==(btrue)
END
&
THEORY ListInitialisationX IS
  Expanded_List_Initialisation(Machine(Apostas_Ctx))==(skip);
  Context_List_Initialisation(Machine(Apostas_Ctx))==(skip);
  List_Initialisation(Machine(Apostas_Ctx))==(skip)
END
&
THEORY ListParametersX IS
  List_Parameters(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListInstanciatedParametersX END
&
THEORY ListConstraintsX IS
  List_Context_Constraints(Machine(Apostas_Ctx))==(btrue);
  List_Constraints(Machine(Apostas_Ctx))==(btrue)
END
&
THEORY ListOperationsX IS
  Internal_List_Operations(Machine(Apostas_Ctx))==(?);
  List_Operations(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListInputX END
&
THEORY ListOutputX END
&
THEORY ListHeaderX END
&
THEORY ListOperationGuardX END
&
THEORY ListPreconditionX END
&
THEORY ListSubstitutionX END
&
THEORY ListConstantsX IS
  List_Valuable_Constants(Machine(Apostas_Ctx))==(MAX_USERS,MAX_EVENTS,MAX_APOSTAS,TAXA_CASA,APOSTA_MINIMA);
  Inherited_List_Constants(Machine(Apostas_Ctx))==(?);
  List_Constants(Machine(Apostas_Ctx))==(MAX_USERS,MAX_EVENTS,MAX_APOSTAS,TAXA_CASA,APOSTA_MINIMA)
END
&
THEORY ListSetsX IS
  Set_Definition(Machine(Apostas_Ctx),STATUS_EVENTO)==({agendado,aberto,finalizado,cancelado});
  Context_List_Enumerated(Machine(Apostas_Ctx))==(?);
  Context_List_Defered(Machine(Apostas_Ctx))==(?);
  Context_List_Sets(Machine(Apostas_Ctx))==(?);
  List_Valuable_Sets(Machine(Apostas_Ctx))==(?);
  Inherited_List_Enumerated(Machine(Apostas_Ctx))==(?);
  Inherited_List_Defered(Machine(Apostas_Ctx))==(?);
  Inherited_List_Sets(Machine(Apostas_Ctx))==(?);
  List_Enumerated(Machine(Apostas_Ctx))==(STATUS_EVENTO,STATUS_APOSTA,OPCAO_RESULTADO,STATUS_RETORNO);
  List_Defered(Machine(Apostas_Ctx))==(?);
  List_Sets(Machine(Apostas_Ctx))==(STATUS_EVENTO,STATUS_APOSTA,OPCAO_RESULTADO,STATUS_RETORNO);
  Set_Definition(Machine(Apostas_Ctx),STATUS_APOSTA)==({pendente,ganha,perdida,devolvida});
  Set_Definition(Machine(Apostas_Ctx),OPCAO_RESULTADO)==({vitoria_A,empate,vitoria_B});
  Set_Definition(Machine(Apostas_Ctx),STATUS_RETORNO)==({sucesso,erro_saldo_insuficiente,erro_evento_invalido,erro_limite_excedido,erro_nao_encontrado,erro_estado_invalido})
END
&
THEORY ListHiddenConstantsX IS
  Abstract_List_HiddenConstants(Machine(Apostas_Ctx))==(?);
  Expanded_List_HiddenConstants(Machine(Apostas_Ctx))==(?);
  List_HiddenConstants(Machine(Apostas_Ctx))==(?);
  External_List_HiddenConstants(Machine(Apostas_Ctx))==(?)
END
&
THEORY ListPropertiesX IS
  Abstract_List_Properties(Machine(Apostas_Ctx))==(btrue);
  Context_List_Properties(Machine(Apostas_Ctx))==(btrue);
  Inherited_List_Properties(Machine(Apostas_Ctx))==(btrue);
  List_Properties(Machine(Apostas_Ctx))==(MAX_USERS: NAT1 & MAX_EVENTS: NAT1 & MAX_APOSTAS: NAT1 & TAXA_CASA: NAT & APOSTA_MINIMA: NAT1 & MAX_USERS = 1000 & MAX_EVENTS = 100 & MAX_APOSTAS = 10000 & TAXA_CASA = 10 & APOSTA_MINIMA = 5 & STATUS_EVENTO: FIN(INTEGER) & not(STATUS_EVENTO = {}) & STATUS_APOSTA: FIN(INTEGER) & not(STATUS_APOSTA = {}) & OPCAO_RESULTADO: FIN(INTEGER) & not(OPCAO_RESULTADO = {}) & STATUS_RETORNO: FIN(INTEGER) & not(STATUS_RETORNO = {}))
END
&
THEORY ListSeenInfoX END
&
THEORY ListANYVarX END
&
THEORY ListOfIdsX IS
  List_Of_Ids(Machine(Apostas_Ctx)) == (MAX_USERS,MAX_EVENTS,MAX_APOSTAS,TAXA_CASA,APOSTA_MINIMA,STATUS_EVENTO,STATUS_APOSTA,OPCAO_RESULTADO,STATUS_RETORNO,agendado,aberto,finalizado,cancelado,pendente,ganha,perdida,devolvida,vitoria_A,empate,vitoria_B,sucesso,erro_saldo_insuficiente,erro_evento_invalido,erro_limite_excedido,erro_nao_encontrado,erro_estado_invalido | ? | ? | ? | ? | ? | ? | ? | Apostas_Ctx);
  List_Of_HiddenCst_Ids(Machine(Apostas_Ctx)) == (? | ?);
  List_Of_VisibleCst_Ids(Machine(Apostas_Ctx)) == (MAX_USERS,MAX_EVENTS,MAX_APOSTAS,TAXA_CASA,APOSTA_MINIMA);
  List_Of_VisibleVar_Ids(Machine(Apostas_Ctx)) == (? | ?);
  List_Of_Ids_SeenBNU(Machine(Apostas_Ctx)) == (?: ?)
END
&
THEORY SetsEnvX IS
  Sets(Machine(Apostas_Ctx)) == (Type(STATUS_EVENTO) == Cst(SetOf(etype(STATUS_EVENTO,0,3)));Type(STATUS_APOSTA) == Cst(SetOf(etype(STATUS_APOSTA,0,3)));Type(OPCAO_RESULTADO) == Cst(SetOf(etype(OPCAO_RESULTADO,0,2)));Type(STATUS_RETORNO) == Cst(SetOf(etype(STATUS_RETORNO,0,5))))
END
&
THEORY ConstantsEnvX IS
  Constants(Machine(Apostas_Ctx)) == (Type(agendado) == Cst(etype(STATUS_EVENTO,0,3));Type(aberto) == Cst(etype(STATUS_EVENTO,0,3));Type(finalizado) == Cst(etype(STATUS_EVENTO,0,3));Type(cancelado) == Cst(etype(STATUS_EVENTO,0,3));Type(pendente) == Cst(etype(STATUS_APOSTA,0,3));Type(ganha) == Cst(etype(STATUS_APOSTA,0,3));Type(perdida) == Cst(etype(STATUS_APOSTA,0,3));Type(devolvida) == Cst(etype(STATUS_APOSTA,0,3));Type(vitoria_A) == Cst(etype(OPCAO_RESULTADO,0,2));Type(empate) == Cst(etype(OPCAO_RESULTADO,0,2));Type(vitoria_B) == Cst(etype(OPCAO_RESULTADO,0,2));Type(sucesso) == Cst(etype(STATUS_RETORNO,0,5));Type(erro_saldo_insuficiente) == Cst(etype(STATUS_RETORNO,0,5));Type(erro_evento_invalido) == Cst(etype(STATUS_RETORNO,0,5));Type(erro_limite_excedido) == Cst(etype(STATUS_RETORNO,0,5));Type(erro_nao_encontrado) == Cst(etype(STATUS_RETORNO,0,5));Type(erro_estado_invalido) == Cst(etype(STATUS_RETORNO,0,5));Type(MAX_USERS) == Cst(btype(INTEGER,?,?));Type(MAX_EVENTS) == Cst(btype(INTEGER,?,?));Type(MAX_APOSTAS) == Cst(btype(INTEGER,?,?));Type(TAXA_CASA) == Cst(btype(INTEGER,?,?));Type(APOSTA_MINIMA) == Cst(btype(INTEGER,?,?)))
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

//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zElimRes
Função que executa a eliminação de resíduo de forma automática
@type  Function
@author Atilio
@since 03/09/2021
/*/

User Function zElimRes(param_name)
    Local aArea
    Local lContinua   := .F.
    Private lJob      := .F.

    //Se o ambiente não estiver em pé, sobe para usar de maneira automática
    If Select("SX2") == 0
        lJob := .T.
        lContinua := .T.
		RPCSetEnv("99", "01", "", "", "", "")
    EndIf
    aArea := GetArea()

    //Se não for modo automático, mostra uma pergunta
    If ! lJob
        lContinua := MsgYesNo("Deseja executar a eliminação de resíduo automática?", "Atenção")
    EndIf

    //Se for continuar, faz a chamada para a realização das baixas
    If lContinua
        Processa({|| fElimina()}, "Eliminando...")
    EndIf
Return

Static Function fElimina()
    Local cInicio   := Time()
    Local cTermino  := ""
    Local cTotal    := ""
    Local cMensagem := ""
    Local cTitulo   := ""
    Local cPerg     := "MTA235"

    //Define os parâmetros
    fSetValue(cPerg, "MV_PAR01", 100)                                 //Percentual máximo
    fSetValue(cPerg, "MV_PAR02", MonthSub(Date(), 2))                 //Data de Emissão De
    fSetValue(cPerg, "MV_PAR03", Date())                              //Data de Emissão Até
    fSetValue(cPerg, "MV_PAR04", "000000")                            //Solicitação / Pedido De
    fSetValue(cPerg, "MV_PAR05", "ZZZZZZ")                            //Solicitação / Pedido Até
    fSetValue(cPerg, "MV_PAR06", Space(TamSX3("B1_COD")[1]))          //Produto De
    fSetValue(cPerg, "MV_PAR07", Replicate("Z", TamSX3("B1_COD")[1])) //Produto Até
    fSetValue(cPerg, "MV_PAR08", 1)                                   //Eliminar resíduo por (1=Pedido de Compra; 2=Aut de Entrega; 3=Pedido/Aut Entrega; 4=Contr. Parceria; 5=Solic. Compras)
    fSetValue(cPerg, "MV_PAR09", Space(TamSX3("A2_COD")[1]))          //Fornecedor De
    fSetValue(cPerg, "MV_PAR10", Replicate("Z", TamSX3("A2_COD")[1])) //Fornecedor Até
    fSetValue(cPerg, "MV_PAR11", MonthSub(Date(), 2))                 //Data de Entrega De
    fSetValue(cPerg, "MV_PAR12", Date())                              //Data de Entrega Até
    fSetValue(cPerg, "MV_PAR13", 2)                                   //Elimina SC com OP (1=Sim; 2=Não)
    fSetValue(cPerg, "MV_PAR14", "    ")                              //Item De
    fSetValue(cPerg, "MV_PAR15", "ZZZZ")                              //Item Até
    fSetValue(cPerg, "MV_PAR16", 2)                                   //Contabiliza Pedido (1=Sim; 2=Não)
    fSetValue(cPerg, "MV_PAR17", 2)                                   //Mostrar Lançamento Contábil (1=Sim; 2=Não)

    //Coloca a pergunta para a memória
    Pergunte(cPerg, .F.)

    //Chama a rotina padrão
    lMsErroAuto := .F.
    MsExecAuto({|x| MATA235(x)}, .T.)
    cTermino := Time()
    cTotal   := ElapTime(cInicio, cTermino)

    //Se houver erro
    If lMsErroAuto
        //Se não for Job, exibe a mensagem de erro
        If ! lJob
            MostraErro()
        EndIf
    Else
        //Se não for Job, exibe mensagem de término
        If ! lJob
            cTitulo   := "Processamento terminado"
            cMensagem := "Começou às <b>"     + cInicio  + "</b><br>"
            cMensagem += "Terminou às <b>"    + cTermino + "</b><br>"
            cMensagem += "Tempo Total de <b>" + cTotal   + "</b><br>"

            FWAlertSuccess(cMensagem, cTitulo)
        EndIf
    EndIf
Return

Static Function fSetValue(cPergunta, cParametro, xConteudo)
    //Tratativa, se houver a função nova criada pela TOTVS aciona ela, do contrário, aciona a customizada
    If ExistBlock("SetMVValue")
        SetMVValue(cPergunta, cParametro, xConteudo)
    Else
        u_zAtuPerg(cPergunta, cParametro, xConteudo)
    EndIf
Return

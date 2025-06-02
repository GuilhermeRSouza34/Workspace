//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zTransPed
Fun��o para tranfer�ncia do pedido entre as filiais
@type  Function
@author Atilio
@since 07/08/2021
/*/

User Function zTransPed()
    Local aArea := GetArea()
    Local aPergs  := {}
    Local cMensagem := "ATEN��O - Ao realizar esse procedimento, o pedido na -ORIGEM- ser� exclu�do, e ser� inclu�do um novo pedido na filial -DESTINO-"
    Private nRecOri := SC5->(RecNo())
    Private cFilOri := SC5->C5_FILIAL
    Private cPedOri := SC5->C5_NUM
    Private cFilDes := Space(Len(cFilOri))

    //Somente ser� poss�vel fazer, se a rotina for acionada pelo Pedido de Vendas
    If FWIsInCallStack("MATA410")
        //Somente pedidos que ainda n�o tiveram nota poder�o ser transferidos
        If Empty(SC5->C5_NOTA)
            //Adiciona os par�metros
            aAdd(aPergs, {09, cMensagem, 200, 40, .T.}) //01
            aAdd(aPergs, {01, "Filial Origem",  cFilOri, "", ".F.", "",    ".F.", 50,  .F.}) //02
            aAdd(aPergs, {01, "Pedido Origem",  cPedOri, "", ".F.", "",    ".F.", 80,  .F.}) //03
            aAdd(aPergs, {01, "Filial Destino", cFilDes, "", ".T.", "SM0", ".T.", 50,  .T.}) //04

            //Se a pergunta for confirmada
            If ParamBox(aPergs, "Informe os par�metros", /*aRet*/, /*bValid*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
                cFilOri := MV_PAR02
                cPedOri := MV_PAR03
                cFilDes := MV_PAR04

                Processa({|| fTransfere()}, "Transferindo")
            EndIf
        Else
            MsgStop("Transfira um pedido que ainda n�o teve a NF emitida!", "Aten��o")
        EndIf
    EndIf

    RestArea(aArea)
Return

Static Function fTransfere()
    Local aArea    := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSC6 := SC6->(GetArea())
    Local aAreaSB1 := SB1->(GetArea())
    Local cFilOk   := ""
    Local cPedOk   := ""
    Local aCabPV   := {}
    Local aItensNov := {}
    Local aItensDel := {}
    Local aItemAux := {}
    Local cItem    := "01"

    ProcRegua(0)

    //Preenche o array do cabe�alho no destino
    IncProc("Adicionando cabe�alho")
    aAdd(aCabPV, {"C5_TIPO"   , SC5->C5_TIPO	, Nil}) // Tipo de pedido
    aAdd(aCabPV, {"C5_CLIENTE", SC5->C5_CLIENTE	, Nil}) // Codigo do cliente
    aAdd(aCabPV, {"C5_LOJACLI", SC5->C5_LOJACLI	, Nil}) // Loja do cliente
    aAdd(aCabPV, {"C5_TIPOCLI", SC5->C5_TIPOCLI	, Nil}) // Tipo Cliente
    aAdd(aCabPV, {"C5_EMISSAO", SC5->C5_EMISSAO	, Nil}) // Data Emissao
    aAdd(aCabPV, {"C5_TRANSP" , SC5->C5_TRANSP	, Nil}) // Transportador
    aAdd(aCabPV, {"C5_CONDPAG", SC5->C5_CONDPAG	, Nil}) // Condicao Pagamento
    aAdd(aCabPV, {"C5_MOEDA"  , SC5->C5_MOEDA   , Nil}) // Moeda
    aAdd(aCabPV, {"C5_VEND1"  , SC5->C5_VEND1	, Nil}) // Vendedor
    aAdd(aCabPV, {"C5_TPFRETE", SC5->C5_TPFRETE , Nil}) // Tipo de frete
    aAdd(aCabPV, {"C5_TXMOEDA", SC5->C5_TXMOEDA , Nil}) // TxMoeda
    aAdd(aCabPV, {"C5_TPCARGA", SC5->C5_TPCARGA , Nil}) // Tipo de carga

    //Preenche o array dos itens no destino
    DbSelectArea("SC6")
    SC6->(DbSetOrder(1)) // Filial + Pedido + Item
    SC6->(DbSeek(cFilOri + cPedOri))
    While ! SC6->(EoF()) .And. SC6->C6_FILIAL + SC6->C6_NUM == cFilOri + cPedOri
        IncProc("Adicionando o item " + SC6->C6_ITEM)
        
        //Deixa a tabela de produtos posicionada
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1)) //Filial + C�digo do Produto
        SB1->(DbSeek(FWxFilial('SB1') + SC6->C6_PRODUTO))

        //Adiciona o item na origem (ser� usado para a exclus�o do pedido)
        aItemAux := {}
        aAdd(aItemAux,{"C6_ITEM",    SC6->C6_ITEM       , Nil})
        aAdd(aItemAux,{"C6_PRODUTO", SC6->C6_PRODUTO    , Nil})
        aAdd(aItemAux,{"C6_QTDVEN" , SC6->C6_QTDVEN		, Nil})
        aAdd(aItemAux,{"C6_PRUNIT" , SC6->C6_PRUNIT     , Nil})
        aAdd(aItemAux,{"C6_PRCVEN" , SC6->C6_PRCVEN     , Nil})
        aAdd(aItemAux,{"C6_TES"    , SC6->C6_TES        , Nil})
        aAdd(aItemAux,{"C6_QTDLIB" , 0            	 	, Nil})
        aAdd(aItensDel, aItemAux)

        //Adiciona o item (no novo pedido que ser� incluido)
        aItemAux := {}
        aAdd(aItemAux,{"C6_ITEM",    cItem              , Nil})
        aAdd(aItemAux,{"C6_PRUNIT" , SC6->C6_PRUNIT     , Nil}) // Valor Unitario
        aAdd(aItemAux,{"C6_PRCVEN" , SC6->C6_PRCVEN     , Nil}) // Preco de Venda
		aAdd(aItemAux,{"C6_PRODUTO", SC6->C6_PRODUTO    , Nil}) // Codigo do Produto
		aAdd(aItemAux,{"C6_UM"     , SC6->C6_UM	 	 	, Nil}) // Unidade de Medida Primar.     
		aAdd(aItemAux,{"C6_QTDVEN" , SC6->C6_QTDVEN		, Nil}) // Quantidade Vendida		
		aAdd(aItemAux,{"C6_ENTREG" , Date()   	 	    , Nil}) // Data da Entrega
		aAdd(aItemAux,{"C6_QTDLIB" , 0            	 	, Nil}) // Quantidade Liberada
		aAdd(aItemAux,{"C6_LOCAL"  , SC6->C6_LOCAL	 	, Nil}) // Almoxarifado
		aAdd(aItemAux,{"C6_QTDEMP" , 0				 	, Nil}) // Quantidade Empenhada
		aAdd(aItensNov, aItemAux)

        cItem := Soma1(cItem)
        SC6->(DbSkip())
    EndDo

    ProcRegua(3)

    //Inicia o controle de transa��o
    Begin Transaction

        //Muda para a filial Destino
        cFilAnt := cFilDes //Filial
        cNumEmp := cEmpAnt + cFilAnt //Grupo + Filial
        OpenFile(cNumEmp)

        //Inclui o pedido no destino
        IncProc("[Parte 1 de 3] Realizando a inclus�o na filial destino")
        lMsErroAuto := .F.
        MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabPV, aItensNov, 3)

        //Volta para a filial Origem
        cFilAnt := cFilOri //Filial
        cNumEmp := cEmpAnt + cFilAnt //Grupo + Filial
        OpenFile(cNumEmp)

        //Se deu erro
        If lMsErroAuto

            //Mostra a mensagem e cancela a transa��o
            MostraErro()
            DisarmTransaction()
            
        //Se deu tudo certo
        Else
            //Armazena as informa��es do pedido que deu certo
            cFilOk := SC5->C5_FILIAL
            cPedOK := SC5->C5_NUM

            //Posiciona no pedido da Origem
            SC5->(DbGoTo(nRecOri))

            //Exclui as libera��es
            IncProc("[Parte 2 de 3] Excluindo as libera��es na origem")
            lMsErroAuto := .F.
            
            //Se conseguir posicionar nos itens do pedido
            If SC6->(DbSeek(FWxFilial('SC6') + SC5->C5_NUM))
                aAreaAux := SC6->(GetArea())
        
                //Percorre todos os itens
                While ! SC6->(EoF()) .And. SC6->C6_FILIAL = FWxFilial('SC6') .And. SC6->C6_NUM == SC5->C5_NUM
                    //Posiciona na libera��o do item do pedido e estorna a libera��o
                    SC9->(DbSeek(FWxFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM))
                    While  (!SC9->(Eof())) .AND. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == FWxFilial('SC9')+SC6->(C6_NUM+C6_ITEM)
                        SC9->(a460Estorna(.T.))
                        SC9->(DbSkip())
                    EndDo
        
                    SC6->(DbSkip())
                EndDo
                RestArea(aAreaAux)
            EndIf

            //Monta o cabe�alho da exclus�o
            IncProc("[Parte 3 de 3] Excluindo o pedido na origem")
            aCabPV := {}
            aAdd(aCabPV, {"C5_NUM", SC5->C5_NUM, Nil})

            //Aciona a exclus�o do pedido
            lMsErroAuto := .F.
            MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabPV, aItensDel, 5)

            //Se houve erro, mostra a mensagem e disarma a transa��o
            If lMsErroAuto
                MostraErro()
                DisarmTransaction()
                
            Else
                FWAlertSuccess("Pedido <b>" + cPedOK + "</b> gerado na filial <b>" + cFilOk + "</b>", "Processamento terminado")
            EndIf
        EndIf
    End Transaction

    RestArea(aAreaSB1)
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aArea)
Return

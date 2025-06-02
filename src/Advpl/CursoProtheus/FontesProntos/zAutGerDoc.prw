#Include "totvs.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} zAutGerDoc
    
    Realiza processos de libera��o a transmiss�o da NF-e de forma automatica.
    > Libera��o
    > Gera��o de documento de sa�da
    > Transmiss�o de NF-e
    > Impress�o da NF-e em PDF

    @type  Function
    @author S�livan Simoes (sulivansimoes@gmail.com)
    @since 10/01/2022
    @version 1.0
    @example
        u_zAutGerDoc()    
/*/
User Function zAutGerDoc()

    Local aArea := GetArea()
    Local aAreaSC9 := SC9->(GetArea())
    Local aAreaSE4 := SE4->(GetArea())
    Local aAreaSB1 := SB1->(GetArea())
    Local aAreaSB2 := SB2->(GetArea())
    Local aAreaSF4 := SF4->(GetArea())
    Local aAreaSC5 := SC5->(GetArea())

    If MsgYesNo('Essa a��o far� todo processo, desde a libera��o do pedido at� a gera��o da NF-e. Deseja continuar?',;
                'Facilitador de finaliza��o de pedido')

        Processa({|| fAutGerDoc() },'Processando','processando...')
    EndIf

    RestArea(aAreaSC5)
    RestArea(aAreaSF4)
    RestArea(aAreaSB2)
    RestArea(aAreaSB1)
    RestArea(aAreaSE4)
    RestArea(aAreaSC9)
    RestArea(aArea)
Return

//-------------------------------------
/*/{Protheus.doc}  fAutGerDoc()
Realiza processamento geral 
@author  	S�livan
@return 	Nil
/*/
//-------------------------------------
Static Function fAutGerDoc()
    
    Private cDoc_   := ""
    Private cSerie_ := SuperGetMV("MV_X_SERNF", .T., "1")
    
    ProcRegua(5)

    IncProc('Liberando itens do pedido de venda: '+SC5->C5_NUM)
    fLiberaPed()

    IncProc('Gerando documento de sa�da para o pedido: '+SC5->C5_NUM)
    If fGeraDoc()

        IncProc('Transmitindo NF-e para o pedido: '+SC5->C5_NUM)
        If fTransNFe()

            IncProc('Imprimindo NF-e : '+cDoc_)
            fGerDanfe()
        EndIf
    EndIf
Return

//-------------------------------------
/*/{Protheus.doc}  fLiberaPed()
Realiza libera��o do pedido de venda.
Atualmente a Totvs n�o fornece um Execauto ou funcinalidade especifica para realizar tal a��o.
@author  	S�livan
@return 	Nil
/*/
//-------------------------------------
Static Function fLiberaPed()

    Begin Transaction
        //Seta pedido indicando libera��o
        If RecLock("SC5", .F.)
            SC5->C5_LIBEROK := 'S'            
            MsUnlock()
        EndIf

        DbSelectArea('SC6')
        SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
        SC6->(DbGoTop())
        SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
        While !SC6->(Eof()) .And. SC5->C5_NUM == SC6->C6_NUM

            MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.)
            SC6->(DbSkip())   
        Enddo
    End Transaction
Return

//-------------------------------------
/*/{Protheus.doc}  fGeraDoc()
Gera documento de sa�da para o pedido de venda.
@author  	S�livan
@return 	Nil
@see        https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=578374528
/*/
//-------------------------------------
Static Function fGeraDoc()

    Local aPvlDocS   := {}
    Local nPrcVen    := 0    
    Local cEmbExp    := ""
    Local cBkpFunName:= FunName()
    Local lRetorno   := .T.

    SC6->(dbSetOrder(1))
    SC6->(MsSeek(FWxFilial("SC6")+SC5->C5_NUM))

    //� necess�rio carregar o grupo de perguntas MT460A, se n�o ser� executado com os valores default.
    Pergunte("MT460A",.F.)

    // Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Sa�da
    While SC6->(!Eof() .And. C6_FILIAL == FWxFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM

        SC9->(DbSetOrder(1))
        SC9->(MsSeek(FWxFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

        SE4->(DbSetOrder(1))
        SE4->(MsSeek(FWxFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

        SB1->(DbSetOrder(1))
        SB1->(MsSeek(FWxFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

        SB2->(DbSetOrder(1))
        SB2->(MsSeek(FWxFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

        SF4->(DbSetOrder(1))
        SF4->(MsSeek(FWxFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

        nPrcVen := SC9->C9_PRCVEN
        If ( SC5->C5_MOEDA <> 1 )
            nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
        EndIf

		If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
        	AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
                        	SC9->C9_ITEM,;
                        	SC9->C9_SEQUEN,;
                        	SC9->C9_QTDLIB,;
                        	nPrcVen,;
                        	SC9->C9_PRODUTO,;
                        	.F.,;
                        	SC9->(RecNo()),;
                        	SC5->(RecNo()),;
                        	SC6->(RecNo()),;
                        	SE4->(RecNo()),;
                        	SB1->(RecNo()),;
                        	SB2->(RecNo()),;
                        	SF4->(RecNo())})
		EndIf

        SC6->(DbSkip())
    EndDo

    If Len(aPvlDocS) > 0

	    SetFunName("MATA461")
        cDoc_ := MaPvlNfs(/*aPvlNfs*/        aPvlDocS,; // 01 - Array com os itens a serem gerados
                        /*cSerie_NFS*/       cSerie_,;  // 02 - Serie da Nota Fiscal
                        /*lMostraCtb*/      .F.,;       // 03 - Mostra Lan�amento Cont�bil
                        /*lAglutCtb*/       .F.,;       // 04 - Aglutina Lan�amento Cont�bil
                        /*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
                        /*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
                        /*lReajuste*/       .F.,;       // 07 - Reajuste de pre�o na Nota Fiscal
                        /*nCalAcrs*/        0,;         // 08 - Tipo de Acr�scimo Financeiro
                        /*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
                        /*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarra��o Cliente x Produto
                        /*lECF*/            .F.,;       // 11 - Cupom Fiscal
                        /*cEmbExp*/         cEmbExp,;   // 12 - N�mero do Embarque de Exporta��o
                        /*bAtuFin*/         {||},;      // 13 - Bloco de C�digo para complemento de atualiza��o dos t�tulos financeiros
                        /*bAtuPGerNF*/      {||},;      // 14 - Bloco de C�digo para complemento de atualiza��o dos dados ap�s a gera��o da Nota Fiscal
                        /*bAtuPvl*/         {||},;      // 15 - Bloco de C�digo de atualiza��o do Pedido de Venda antes da gera��o da Nota Fiscal
                        /*bFatSE1*/         {|| .T. },; // 16 - Bloco de C�digo para indicar se o valor do Titulo a Receber ser� gravado no campo F2_VALFAT quando o par�metro MV_TMSMFAT estiver com o valor igual a "2".
                        /*dDataMoe*/        dDatabase,; // 17 - Data da cota��o para convers�o dos valores da Moeda do Pedido de Venda para a Moeda Forte
                        /*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais
        
        If !Empty(cDoc_)
            FwLogMsg("INFO", /*cTransactionId*/, "zAutoGerDoc", FunName(), "", "01", "Documento de Sa�da: " + cSerie_ + "-" + cDoc_ + ", gerado com sucesso!!!", 0, 0, {})
        EndIf
    Else
        lRetorno := .F.
        Help(NIL, NIL, "zAutGerDoc", NIL, "Documento de sa�da para o pedido "+Alltrim(SC5->C5_NUM)+" n�o pode ser gerado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique se o pedido n�o possui bloqueio de Cr�dito, Estoque ou bloqueio por regra. Realize o desbloqueio e repita o processo novamente." })
    EndIf

    SetFunName(cBkpFunName)
Return lRetorno

//-------------------------------------
/*/{Protheus.doc}  fTransNFe()
Realiza transmiss�o e monitoramento da NF-e gerada.
@author  	S�livan
@return 	Logical, .T. caso tenha conseguido transmitir a NF-e, .F. caso contr�rio.
@obs        Fun��o SpedNFeRe2 e ChamaMonit est�o presentes em SPEDNFE
/*/
//-------------------------------------
Static Function fTransNFe()
    
    Local aArea          := GetArea()
    Local aParam         := Array(5)
    Local nMaxTentativas := 2
    Local nTentatiavas   := 0
   
    Private  bFiltraBrw //Uso interno da fun��o SpedNFeRe2
    
    //Transmite NF-e
    SpedNFeRe2(cSerie_, cDoc_, cDoc_, /*lCTe*/, /*lRetorno*/, /*aNotas*/)

    //Monitora NF-e
    While nTentatiavas < nMaxTentativas .And. fNFNaoAutorizada()
        
        //Aguarda alguns segundos para monitorar.
        Sleep(2000) 
        
        aParam[01] := PadR( cSerie_, Len(SerieNfId("SF2",2,"F2_SERIE") ))
        aParam[02] := cDoc_
        aParam[03] := cDoc_

        ChamaMonit(aParam, /*nTpMonitor*/, /*cModelo*/, /*lCte*/ , /*lMsg*/, /*lMDFe*/, /*lTMS*/)

        nTentatiavas++
    EndDo
    RestArea(aArea)
Return !fNFNaoAutorizada()

//-------------------------------------
/*/{Protheus.doc}  fNFNaoAutorizada()
Verifica se NF-e est� autorizada ou n�o.
@author  	S�livan
@return 	Logical, .T. caso N�O esteja  autorizada, .F. caso constr�rio
/*/
//-------------------------------------
Static Function fNFNaoAutorizada()    
Return Empty(Posicione("SF2",1,FWxFilial("SF2")+cDoc_+cSerie_,"F2_DAUTNFE"))

//-------------------------------------
/*/{Protheus.doc}  fGerDanfe()
Realiza impress�o da Danfe em pdf em um pasta.

@author  	Daniel Atilio (cria��o da fun��o original)
@author     S�livan (respons�vel por adaptar a fun��o para fim especifico)
@param cNota, characters, Nota que ser� buscada
@param cSerie, characters, S�rie da Nota
@param cPasta, characters, Pasta que ter� o PDF salvo
@param cNomdanf, characters, Nome que o pdf ter�, se n�o for informado ser� utilizado um conteudo default.
@param lServer, logical, Indica impress�o via Server (.REL N�o ser� copiado para o Client). Default � .F.
@return 	Nil
@obs        Fun��o SpedNFeRe2 presente em SPEDNFE
/*/
//-------------------------------------
Static Function fGerDanfe(cNota, cSerie, cPasta, cNomdanf, lServer)

    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := GetSx3Cache("F2_DOC"  ,"X3_TAMANHO")
    Local nTamSerie := GetSx3Cache("F2_SERIE","X3_TAMANHO")
    Local cPergunt  := "NFSIGW"
    
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux

    Default cNota   := cDoc_
    Default cSerie  := cSerie_
    Default cPasta  := GetTempPath()
    Default cNomdanf:= cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")  
    Default lServer := .F. 

    //Se existir nota
    If ! Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
         
        //Se o �ltimo caracter da pasta n�o for barra, ser� barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf         
        
        cArquivo:= cNomdanf
                 
        //Define as perguntas da DANFE
        Pergunte(cPergunt,.F.)
        SetMVValue( cPergunt, "MV_PAR01", PadR(cNota ,  nTamNota)) //Nota Inicial       
        SetMVValue( cPergunt, "MV_PAR02", PadR(cNota ,  nTamNota)) //Nota Inicial
        SetMVValue( cPergunt, "MV_PAR03", PadR(cSerie, nTamSerie)) //S�rie da Nota
        SetMVValue( cPergunt, "MV_PAR04", 2						 ) //NF de Saida
        SetMVValue( cPergunt, "MV_PAR05", 2						 ) //Frente e Verso = N�o
        SetMVValue( cPergunt, "MV_PAR06", 2						 ) //DANFE simplificado = Nao            
            
        //Chamo de novo pra carregar na mem�ria
        Pergunte(cPergunt,.F.)
                                   
        //Cria a Danfe
        oDanfe := FWMSPrinter():New(cArquivo+".pdf", IMP_PDF, .F., cPasta, .T.,  ,  ,  ,.F.,  ,.F.,.F.)
        oDanfe:cPathPDF := cPasta                
        			         
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
         
        //For�a a impress�o em PDF
        oDanfe:nDevice  := 6
        oDanfe:lServer  := lServer
        oDanfe:lViewPDF := .T.        
         
        //Vari�veis obrigat�rias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
         
        If FindFunction("U_DanfeProc")
            //Chamando a impress�o da danfe no RDMAKE        
            u_DanfeProc(@oDanfe, @lEnd, cIdent, Nil, Nil, .F., .F.)        
            oDanfe:Preview()
        Else
            Help(NIL, NIL, "zAutGerDoc", NIL, "N�o conseguiu imprimir a danfe. N�o encontrou rdmake da danfe!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Contate o departamento t�cnico. Rdmake de impress�o da danfe n�o est� compilada." })
        EndIf
    EndIf
    FreeObj(oDanfe)
    RestArea(aArea)
Return

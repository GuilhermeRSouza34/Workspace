//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Vari�veis utilizadas no fonte inteiro
Static nPadLeft   := 0                                                                     //Alinhamento a Esquerda
Static nPadRight  := 1                                                                     //Alinhamento a Direita
Static nPadCenter := 2                                                                     //Alinhamento Centralizado
Static nPosCod    := 0000                                                                  //Posi��o Inicial da Coluna de C�digo do Produto 
Static nPosDesc   := 0000                                                                  //Posi��o Inicial da Coluna de Descri��o
Static nPosUnid   := 0000                                                                  //Posi��o Inicial da Coluna de Unidade de Medida
Static nPosQuan   := 0000                                                                  //Posi��o Inicial da Coluna de Quantidade
Static nPosVUni   := 0000                                                                  //Posi��o Inicial da Coluna de Valor Unitario
Static nPosVTot   := 0000                                                                  //Posi��o Inicial da Coluna de Valor Total
Static nPosBIcm   := 0000                                                                  //Posi��o Inicial da Coluna de Base Calculo ICMS
Static nPosVIcm   := 0000                                                                  //Posi��o Inicial da Coluna de Valor ICMS
Static nPosVIPI   := 0000                                                                  //Posi��o Inicial da Coluna de Valor Ipi
Static nPosAIcm   := 0000                                                                  //Posi��o Inicial da Coluna de Aliquota ICMS
Static nPosAIpi   := 0000                                                                  //Posi��o Inicial da Coluna de Aliquota IPI
Static nPosSTUn   := 0000                                                                  //Posi��o Inicial da Coluna de Valor Unit�rio ST
Static nPosSTVl   := 0000                                                                  //Posi��o Inicial da Coluna de Valor Unit�rio + ST
Static nPosSTBa   := 0000                                                                  //Posi��o Inicial da Coluna de Base do ST
Static nPosSTTo   := 0000                                                                  //Posi��o Inicial da Coluna de Valor Total ST
Static nTamFundo  := 15                                                                    //Altura de fundo dos blocos com t�tulo
Static cEmpEmail  := Alltrim(SuperGetMV("MV_X_EMAIL", .F., "email@empresa.com.br"))        //Par�metro com o e-Mail da empresa
Static cEmpSite   := Alltrim(SuperGetMV("MV_X_HPAGE", .F., "http://www.empresa.com.br"))   //Par�metro com o site da empresa
Static nCorAzul   := RGB(062, 179, 206)                                                    //Cor Azul usada nos T�tulos
Static cNomeFont  := "Arial"                                                               //Nome da Fonte Padr�o
Static oFontDet   := Nil                                                                   //Fonte utilizada na impress�o dos itens
Static oFontDetN  := Nil                                                                   //Fonte utilizada no cabe�alho dos itens
Static oFontRod   := Nil                                                                   //Fonte utilizada no rodap� da p�gina
Static oFontTit   := Nil                                                                   //Fonte utilizada no T�tulo das se��es
Static oFontCab   := Nil                                                                   //Fonte utilizada na impress�o dos textos dentro das se��es
Static oFontCabN  := Nil                                                                   //Fonte negrita utilizada na impress�o dos textos dentro das se��es
Static cMaskPad   := "@E 999,999.99"                                                       //M�scara padr�o de valor 
Static cMaskTel   := "@R (99) 99999999"                                                    //M�scara de telefone / fax
Static cMaskCNPJ  := "@R 99.999.999/9999-99"                                               //M�scara de CNPJ
Static cMaskCEP   := "@R 99999-999"                                                        //M�scara de CEP
Static cMaskCPF   := "@R 999.999.999-99"                                                   //M�scara de CPF
Static cMaskQtd   := PesqPict("SC6", "C6_QTDVEN")                                          //M�scara de quantidade
Static cMaskPrc   := PesqPict("SC6", "C6_PRCVEN")                                          //M�scara de pre�o
Static cMaskVlr   := PesqPict("SC6", "C6_VALOR")                                           //M�scara de valor
Static cMaskFrete := PesqPict("SC5", "C5_FRETE")                                           //M�scara de frete
Static cMaskPBru  := PesqPict("SC5", "C5_PBRUTO")                                          //M�scara de peso bruto
Static cMaskPLiq  := PesqPict("SC5", "C5_PESOL")                                           //M�scara de peso liquido

/*/{Protheus.doc} zRPedVen
Impress�o gr�fica gen�rica de Pedido de Venda (em pdf)
@type function
@version 1.0
	@example
	u_zRPedVen()
/*/

User Function zRPedVen()
	Local aArea      := GetArea()
	Local aAreaC5    := SC5->(GetArea())
	Local aPergs     := {}
	Local aRetorn    := {}
	Local oProcess   := Nil
	//Vari�veis usadas nas outras fun��es
	Private cLogoEmp := fLogoEmp()
	Private cPedDe   := SC5->C5_NUM
	Private cPedAt   := SC5->C5_NUM
	Private cLayout  := "1"
	Private cTipoBar := "3"
	Private cImpDupl := "1"
	Private cZeraPag := "1"
	
	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Pedido De",  cPedDe, "", ".T.", "SC5", ".T.", 80, .T.})
	aAdd(aPergs, {1, "Pedido At�", cPedAt, "", ".T.", "SC5", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Layout",                         Val(cLayout),  {"1=Dados com ST",     "2=Dados com IPI"},                                       100, ".T.", .F.})
	aAdd(aPergs, {2, "C�digo de Barras",               Val(cTipoBar), {"1=N�mero do Pedido", "2=Filial + N�mero do Pedido", "3=Sem C�digo de Barras"}, 100, ".T.", .F.})
	aAdd(aPergs, {2, "Imprimir Previs�o Duplicatas",   Val(cImpDupl), {"1=Sim",              "2=N�o"},                                                 100, ".T.", .F.})
	aAdd(aPergs, {2, "Zera a P�gina ao trocar Pedido", Val(cZeraPag), {"1=Sim",              "2=N�o"},                                                 100, ".T.", .F.})
	
	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os par�metros", @aRetorn, , , , , , , , .F., .F.)
		cPedDe   := aRetorn[1]
		cPedAt   := aRetorn[2]
		cLayout  := cValToChar(aRetorn[3])
		cTipoBar := cValToChar(aRetorn[4])
		cImpDupl := cValToChar(aRetorn[5])
		cZeraPag := cValToChar(aRetorn[6])
		
		//Fun��o que muda alinhamento e fontes
		fMudaLayout()
		
		//Chama o processamento do relat�rio
		oProcess := MsNewProcess():New({|| fMontaRel(@oProcess) }, "Impress�o Pedidos de Venda", "Processando", .F.)
		oProcess:Activate()
	EndIf
	
	RestArea(aAreaC5)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Fun��o principal que monta o relat�rio                       |
 *---------------------------------------------------------------------*/

Static Function fMontaRel(oProc)
	//Vari�veis usada no controle das r�guas
	Local nTotIte       := 0
	Local nItAtu        := 0
	Local nTotPed       := 0
	Local nPedAtu       := 0
	//Consultas SQL
	Local cQryPed       := ""
	Local cQryIte       := ""
	//Valores de Impostos
	Local nBasICM       := 0
	Local nValICM       := 0
	Local nValIPI       := 0
	Local nAlqICM       := 0
	Local nAlqIPI       := 0
	Local nValSol       := 0
	Local nBasSol       := 0
	Local nPrcUniSol    := 0
	Local nTotSol       := 0
	//Vari�veis do Relat�rio
	Local cNomeRel      := "pedido_venda_"+FunName()+"_"+RetCodUsr()+"_"+dToS(Date())+"_"+StrTran(Time(), ":", "-")
	Private oPrintPvt
	Private cHoraEx     := Time()
	Private nPagAtu     := 1
	Private aDuplicatas := {}
	//Linhas e colunas
	Private nLinAtu     := 0
	Private nLinFin     := 780
	Private nColIni     := 010
	Private nColFin     := 550
	Private nColMeio    := (nColFin-nColIni)/2
	//Totalizadores
	Private nTotFrete   := 0
	Private nValorTot   := 0
	Private nTotalST    := 0
	Private nTotVal     := 0
	Private nTotIPI     := 0
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(DbGoTop())
	DbSelectArea("SC5")
	
	//Criando o objeto de impress�o
	oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
	oPrintPvt:cPathPDF := GetTempPath()
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetPortrait()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)
	
	//Selecionando os pedidos
	cQryPed := " SELECT "                                        + CRLF
	cQryPed += "    C5_FILIAL, "                                 + CRLF
	cQryPed += "    C5_NUM, "                                    + CRLF
	cQryPed += "    C5_EMISSAO, "                                + CRLF
	cQryPed += "    C5_CLIENTE, "                                + CRLF
	cQryPed += "    C5_LOJACLI, "                                + CRLF
	cQryPed += "    ISNULL(A1_NREDUZ, '') AS A1_NREDUZ, "        + CRLF
	cQryPed += "    ISNULL(A1_PESSOA, '') AS A1_PESSOA, "        + CRLF
	cQryPed += "    ISNULL(A1_CGC, '') AS A1_CGC, "              + CRLF
	cQryPed += "    C5_CONDPAG, "                                + CRLF
	cQryPed += "    ISNULL(E4_DESCRI, '') AS E4_DESCRI, "        + CRLF
	cQryPed += "    C5_TRANSP, "                                 + CRLF
	cQryPed += "    ISNULL(A4_NREDUZ, '') AS A4_NREDUZ, "        + CRLF
	cQryPed += "    C5_VEND1, "                                  + CRLF
	cQryPed += "    ISNULL(A3_NREDUZ, '') AS A3_NREDUZ, "        + CRLF
	cQryPed += "    C5_TPFRETE, "                                + CRLF
	cQryPed += "    C5_FRETE, "                                  + CRLF
	cQryPed += "    C5_PESOL, "                                  + CRLF
	cQryPed += "    C5_PBRUTO, "                                 + CRLF
	cQryPed += "    C5_MENNOTA, "                                + CRLF
	cQryPed += "    SC5.R_E_C_N_O_ AS C5REC "                    + CRLF
	cQryPed += " FROM "                                          + CRLF
	cQryPed += "    "+RetSQLName("SC5")+" SC5 "                  + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( "   + CRLF
	cQryPed += "        A1_FILIAL   = '"+FWxFilial("SA1")+"' "   + CRLF
	cQryPed += "        AND A1_COD  = SC5.C5_CLIENTE "           + CRLF
	cQryPed += "        AND A1_LOJA = SC5.C5_LOJACLI "           + CRLF
	cQryPed += "        AND SA1.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SE4")+" SE4 ON ( "   + CRLF
	cQryPed += "        E4_FILIAL     = '"+FWxFilial("SE4")+"' " + CRLF
	cQryPed += "        AND E4_CODIGO = SC5.C5_CONDPAG "         + CRLF
	cQryPed += "        AND SE4.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA4")+" SA4 ON ( "   + CRLF
	cQryPed += "        A4_FILIAL  = '"+FWxFilial("SA4")+"' "    + CRLF
	cQryPed += "        AND A4_COD = SC5.C5_TRANSP "             + CRLF
	cQryPed += "        AND SA4.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( "   + CRLF
	cQryPed += "        A3_FILIAL  = '"+FWxFilial("SA3")+"' "    + CRLF
	cQryPed += "        AND A3_COD = SC5.C5_VEND1 "              + CRLF
	cQryPed += "        AND SA3.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += " WHERE "                                         + CRLF
	cQryPed += "    C5_FILIAL   = '"+FWxFilial("SC5")+"' "       + CRLF
	cQryPed += "    AND C5_NUM >= '"+cPedDe+"' "                 + CRLF
	cQryPed += "    AND C5_NUM <= '"+cPedAt+"' "                 + CRLF
	cQryPed += "    AND SC5.D_E_L_E_T_ = ' ' "                   + CRLF
	TCQuery cQryPed New Alias "QRY_PED"
	TCSetField("QRY_PED", "C5_EMISSAO", "D")
	Count To nTotPed
	oProc:SetRegua1(nTotPed)
	
	//Somente se houver pedidos
	If nTotPed != 0
	
		//Enquanto houver pedidos
		QRY_PED->(DbGoTop())
		While ! QRY_PED->(EoF())
			If cZeraPag == "1"
				nPagAtu := 1
			EndIf
			nPedAtu++
			oProc:IncRegua1("Processando o pedido "+cValToChar(nPedAtu)+" de "+cValToChar(nTotPed)+"...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")
			
			//Imprime o cabe�alho
			fImpCab()
			
			//Inicializa os calculos de impostos
			nItAtu   := 0
			nTotIte  := 0
			nTotalST := 0
			nTotIPI  := 0
			SC5->(DbGoTo(QRY_PED->C5REC))
			MaFisIni(SC5->C5_CLIENTE,;                   // 01 - Codigo Cliente/Fornecedor
				SC5->C5_LOJACLI,;                        // 02 - Loja do Cliente/Fornecedor
				Iif(SC5->C5_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
				SC5->C5_TIPO,;                           // 04 - Tipo da NF
				SC5->C5_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
				MaFisRelImp("MT100", {"SF2", "SD2"}),;   // 06 - Relacao de Impostos que suportados no arquivo
				,;                                       // 07 - Tipo de complemento
				,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
				"SB1",;                                  // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				"MATA461")                               // 10 - Nome da rotina que esta utilizando a funcao
			
			//Seleciona agora os itens do pedido
			cQryIte := " SELECT "                                      + CRLF
			cQryIte += "    C6_PRODUTO, "                              + CRLF
			cQryIte += "    ISNULL(B1_DESC, '') AS B1_DESC, "          + CRLF
			cQryIte += "    C6_UM, "                                   + CRLF
			cQryIte += "    C6_ENTREG, "                               + CRLF
			cQryIte += "    C6_TES, "                                  + CRLF
			cQryIte += "    C6_QTDVEN, "                               + CRLF
			cQryIte += "    C6_PRCVEN, "                               + CRLF
			cQryIte += "    C6_VALDESC, "                              + CRLF
			cQryIte += "    C6_NFORI, "                                + CRLF
			cQryIte += "    C6_SERIORI, "                              + CRLF
			cQryIte += "    C6_VALOR "                                 + CRLF
			cQryIte += " FROM "                                        + CRLF
			cQryIte += "    "+RetSQLName("SC6")+" SC6 "                + CRLF
			cQryIte += "    LEFT JOIN "+RetSQLName("SB1")+" SB1 ON ( " + CRLF
			cQryIte += "        B1_FILIAL = '"+FWxFilial("SB1")+"' "   + CRLF
			cQryIte += "        AND B1_COD = SC6.C6_PRODUTO "          + CRLF
			cQryIte += "        AND SB1.D_E_L_E_T_ = ' ' "             + CRLF
			cQryIte += "    ) "                                        + CRLF
			cQryIte += " WHERE "                                       + CRLF
			cQryIte += "    C6_FILIAL = '"+FWxFilial("SC6")+"' "       + CRLF
			cQryIte += "    AND C6_NUM = '"+QRY_PED->C5_NUM+"' "       + CRLF
			cQryIte += "    AND SC6.D_E_L_E_T_ = ' ' "                 + CRLF
			cQryIte += " ORDER BY "                                    + CRLF
			cQryIte += "    C6_ITEM "                                  + CRLF
			TCQuery cQryIte New Alias "QRY_ITE"
			TCSetField("QRY_ITE", "C6_ENTREG", "D")
			Count To nTotIte
			nValorTot := 0
			oProc:SetRegua2(nTotIte)
			
			//Enquanto houver itens
			QRY_ITE->(DbGoTop())
			While ! QRY_ITE->(EoF())
				nItAtu++
				oProc:IncRegua2("Calculando impostos - item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")
				
				//Pega os tratamentos de impostos
				SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->C6_PRODUTO))
				MaFisAdd(QRY_ITE->C6_PRODUTO,;    // 01 - Codigo do Produto                    ( Obrigatorio )
					QRY_ITE->C6_TES,;             // 02 - Codigo do TES                        ( Opcional )
					QRY_ITE->C6_QTDVEN,;          // 03 - Quantidade                           ( Obrigatorio )
					QRY_ITE->C6_PRCVEN,;          // 04 - Preco Unitario                       ( Obrigatorio )
					QRY_ITE->C6_VALDESC,;         // 05 - Desconto
					QRY_ITE->C6_NFORI,;           // 06 - Numero da NF Original                ( Devolucao/Benef )
					QRY_ITE->C6_SERIORI,;         // 07 - Serie da NF Original                 ( Devolucao/Benef )
					0,;                           // 08 - RecNo da NF Original no arq SD1/SD2
					0,;                           // 09 - Valor do Frete do Item               ( Opcional )
					0,;                           // 10 - Valor da Despesa do item             ( Opcional )
					0,;                           // 11 - Valor do Seguro do item              ( Opcional )
					0,;                           // 12 - Valor do Frete Autonomo              ( Opcional )
					QRY_ITE->C6_VALOR,;           // 13 - Valor da Mercadoria                  ( Obrigatorio )
					0,;                           // 14 - Valor da Embalagem                   ( Opcional )
					SB1->(RecNo()),;              // 15 - RecNo do SB1
					0)                            // 16 - RecNo do SF4
				
				nQtdPeso := QRY_ITE->C6_QTDVEN*SB1->B1_PESO
				MaFisLoad("IT_VALMERC", QRY_ITE->C6_VALOR, nItAtu)				
				MaFisAlt("IT_PESO", nQtdPeso, nItAtu)
				
				QRY_ITE->(DbSkip())
			EndDo
			
			//Altera dados da Nota
			MaFisAlt("NF_FRETE", SC5->C5_FRETE)
			MaFisAlt("NF_SEGURO", SC5->C5_SEGURO)
			MaFisAlt("NF_DESPESA", SC5->C5_DESPESA) 
			MaFisAlt("NF_AUTONOMO", SC5->C5_FRETAUT)
			If SC5->C5_DESCONT > 0
				MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC")-0.01, SC5->C5_DESCONT+MaFisRet(, "NF_DESCONTO")) )
			EndIf
			If SC5->C5_PDESCAB > 0
				MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC")*SC5->C5_PDESCAB/100, "C6_VALOR") + MaFisRet(, "NF_DESCONTO"))
			EndIf
			
			//Enquanto houver itens
			oProc:IncRegua2("...")
			oProc:SetRegua2(nTotIte)
			nItAtu := 0
			QRY_ITE->(DbGoTop())
			While ! QRY_ITE->(EoF())
				nItAtu++
				oProc:IncRegua2("Imprimindo item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")
				
				//Pega os tratamentos de impostos
				SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->C6_PRODUTO))
				
				//Pega os valores
				nBasICM    := MaFisRet(nItAtu, "IT_BASEICM")
				nValICM    := MaFisRet(nItAtu, "IT_VALICM")
				nValIPI    := MaFisRet(nItAtu, "IT_VALIPI")
				nAlqICM    := MaFisRet(nItAtu, "IT_ALIQICM")
				nAlqIPI    := MaFisRet(nItAtu, "IT_ALIQIPI")
				nValSol    := (MaFisRet(nItAtu, "IT_VALSOL") / QRY_ITE->C6_QTDVEN) 
				nBasSol    := MaFisRet(nItAtu, "IT_BASESOL")
				nPrcUniSol := QRY_ITE->C6_PRCVEN + nValSol
				nTotSol    := nPrcUniSol * QRY_ITE->C6_QTDVEN
				nTotalST   += MaFisRet(nItAtu, "IT_VALSOL")
				nTotIPI    += nValIPI
				
				//Imprime os dados
				If cLayout == "1"
					oPrintPvt:SayAlign(nLinAtu, nPosCod, QRY_ITE->C6_PRODUTO,                                oFontDet, 040, 35, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosDesc, QRY_ITE->B1_DESC,                                  oFontDet, 200, 07, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosQuan, Alltrim(Transform(QRY_ITE->C6_QTDVEN, cMaskQtd)),  oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVUni, Alltrim(Transform(QRY_ITE->C6_PRCVEN, cMaskPrc)),  oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosSTUn, Alltrim(Transform(nValSol, cMaskPad)),             oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosSTVl, Alltrim(Transform(nPrcUniSol, cMaskPrc)),          oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosSTBa, Alltrim(Transform(nBasSol, cMaskPad)),             oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosSTTo, Alltrim(Transform(nTotSol, cMaskVlr)),             oFontDet, 050, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVTot, Alltrim(Transform(QRY_ITE->C6_VALOR, cMaskVlr)),   oFontDet, 050, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosBIcm, Alltrim(Transform(nBasICM, cMaskPad)),             oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVIcm, Alltrim(Transform(nValICM, cMaskPad)),             oFontDet, 025, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosAIcm, Alltrim(Transform(nAlqICM, cMaskPad)),             oFontDet, 025, 07, , nPadRight, )
				Else
					oPrintPvt:SayAlign(nLinAtu, nPosCod, QRY_ITE->C6_PRODUTO,                                oFontDet, 040, 07, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosDesc, QRY_ITE->B1_DESC,                                  oFontDet, 200, 07, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosUnid, QRY_ITE->C6_UM,                                    oFontDet, 030, 07, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosQuan, Alltrim(Transform(QRY_ITE->C6_QTDVEN, cMaskQtd)),  oFontDet, 030, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVUni, Alltrim(Transform(QRY_ITE->C6_PRCVEN, cMaskPrc)),  oFontDet, 030, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVTot, Alltrim(Transform(QRY_ITE->C6_VALOR, cMaskVlr)),   oFontDet, 060, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosBIcm, Alltrim(Transform(nBasICM, cMaskPad)),             oFontDet, 030, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVIcm, Alltrim(Transform(nValICM, cMaskPad)),             oFontDet, 030, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVIPI, Alltrim(Transform(nValIPI, cMaskPad)),             oFontDet, 030, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosAIcm, Alltrim(Transform(nAlqICM, cMaskPad)),             oFontDet, 030, 07, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosAIpi, Alltrim(Transform(nAlqIPI, cMaskPad)),             oFontDet, 030, 07, , nPadRight, )
				EndIf
				nLinAtu += 7
				
				//Se por acaso atingiu o limite da p�gina, finaliza, e come�a uma nova p�gina
				If nLinAtu >= nLinFin
					fImpRod()
					fImpCab()
				EndIf
				
				nValorTot += QRY_ITE->C6_VALOR
				QRY_ITE->(DbSkip())
			EndDo
			nTotFrete := MaFisRet(, "NF_FRETE")
			nTotVal := MaFisRet(, "NF_TOTAL")
			fMontDupl()
			QRY_ITE->(DbCloseArea())
			MaFisEnd()
			
			//Imprime o total do pedido
			fImpTot()
			
			//Se tiver mensagem da observa��o
			If !Empty(QRY_PED->C5_MENNOTA)
				fMsgObs()
			EndIf
			
			//Se dever� ser impresso as duplicatas
			If cImpDupl == "1"
				fImpDupl()
			EndIf
			
			//Imprime o rodap�
			fImpRod()
			
			QRY_PED->(DbSkip())
		EndDo
		
		//Gera o pdf para visualiza��o
		oPrintPvt:Preview()
	
	Else
		MsgStop("N�o h� pedidos!", "Aten��o")
	EndIf
	QRY_PED->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Fun��o que imprime o cabe�alho                               |
 *---------------------------------------------------------------------*/

Static Function fImpCab()
	Local cTexto      := ""
	Local nLinCab     := 025
	Local nLinCabOrig := nLinCab
	Local cCodBar     := ""
	Local nColMeiPed  := nColMeio+8+((nColMeio-nColIni)/2)
	Local lCNPJ       := (QRY_PED->A1_PESSOA != "F")
	Local cCliAux     := QRY_PED->C5_CLIENTE+" "+QRY_PED->C5_LOJACLI+" - "+QRY_PED->A1_NREDUZ
	Local cCGC        := ""
	Local cFretePed   := ""
	//Dados da empresa
	Local cEmpresa    := Iif(Empty(SM0->M0_NOMECOM), Alltrim(SM0->M0_NOME), Alltrim(SM0->M0_NOMECOM))
	Local cEmpTel     := Alltrim(Transform(SubStr(SM0->M0_TEL, 3, Len(SM0->M0_TEL)), cMaskTel))
	Local cEmpFax     := Alltrim(Transform(SubStr(SM0->M0_FAX, 3, Len(SM0->M0_FAX)), cMaskTel))
	Local cEmpCidade  := AllTrim(SM0->M0_CIDENT)+" / "+SM0->M0_ESTENT
	Local cEmpCnpj    := Alltrim(Transform(SM0->M0_CGC, cMaskCNPJ))
	Local cEmpCep     := Alltrim(Transform(SM0->M0_CEPENT, cMaskCEP))
	
	//Iniciando P�gina
	oPrintPvt:StartPage()
	
	//Dados da Empresa
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + 075, nColMeio-3)
	oPrintPvt:Line(nLinCab+nTamFundo, nColIni, nLinCab+nTamFundo, nColMeio-3)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni+5, "Emitente:",                                      oFontTit,  060, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 5
	oPrintPvt:SayBitmap(nLinCab+3, nColIni+5, cLogoEmp, 054, 054)
	oPrintPvt:SayAlign(nLinCab,    nColIni+65, "Empresa:",                                      oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColIni+95, cEmpresa,                                        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "CNPJ:",                                          oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+87, cEmpCnpj,                                         oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "Cidade:",                                        oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+95, cEmpCidade,                                       oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "CEP:",                                           oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+85, cEmpCep,                                          oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "Telefone:",                                      oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+95, cEmpTel,                                          oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "FAX:",                                           oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+85, cEmpFax,                                          oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "e-Mail:",                                        oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+87, cEmpEmail,                                        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni+65, "Home Page:",                                     oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+105, cEmpSite,                                        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	
	//Dados do Pedido
	nLinCab := nLinCabOrig
	oPrintPvt:Box(nLinCab, nColMeio+3, nLinCab + 075, nColFin)
	oPrintPvt:Line(nLinCab+nTamFundo, nColMeio+3, nLinCab+nTamFundo, nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColMeio+8,  "Pedido:",                                      oFontTit,  060, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 5
	oPrintPvt:SayAlign(nLinCab,    nColMeio+8,  "N�m.Pedido:",                                  oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColMeio+52, QRY_PED->C5_NUM,                                oFontCab,  060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,    nColMeio+8,  "Dt.Emiss�o:",                                  oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColMeio+50, dToC(QRY_PED->C5_EMISSAO),                      oFontCab,  060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,    nColMeio+8,  "Cliente:",                                     oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColMeio+34, cCliAux,                                        oFontCab, 120, 07, , nPadLeft, )
	nLinCab += 7
	cCGC := QRY_PED->A1_CGC
	If lCNPJ
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCNPJ)), "-")
		oPrintPvt:SayAlign(nLinCab, nColMeio+8, "CNPJ:",                                        oFontCabN, 060, 07, , nPadLeft, )
	Else
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCPF)), "-")
		oPrintPvt:SayAlign(nLinCab, nColMeio+8, "CPF:",                                         oFontCabN, 060, 07, , nPadLeft, )
	EndIf
	oPrintPvt:SayAlign(nLinCab, nColMeio+32, cCGC,                                              oFontCab,  060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8,  "Cond.Pagto.:",                                    oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColMeio+52, QRY_PED->C5_CONDPAG +" - "+QRY_PED->E4_DESCRI,     oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8, "Transportadora:",                                  oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColMeio+62, QRY_PED->C5_TRANSP +" "+QRY_PED->A4_NREDUZ,        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8, "Vendedor:",                                        oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColMeio+44, QRY_PED->C5_VEND1 + " "+QRY_PED->A3_NREDUZ,        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8, "Frete:",                                           oFontCabN, 060, 07, , nPadLeft, )
	If QRY_PED->C5_TPFRETE == "C"
		cFretePed := "CIF"
	ElseIf QRY_PED->C5_TPFRETE == "F"
		cFretePed := "FOB"
	ElseIf QRY_PED->C5_TPFRETE == "T"
		cFretePed := "Terceiros"
	Else
		cFretePed := "Sem Frete"
	EndIf
	cFretePed += " - "+Alltrim(Transform(QRY_PED->C5_FRETE, cMaskFrete))
	oPrintPvt:SayAlign(nLinCab, nColMeio+28, cFretePed,                                         oFontCab,  060, 07, , nPadLeft, )
	
	//C�digo de barras
	nLinCab := nLinCabOrig
	If cTipoBar $ "1;2"
		If cTipoBar == "1"
			cCodBar := QRY_PED->C5_NUM
		ElseIf cTipoBar == "2"
			cCodBar := QRY_PED->C5_FILIAL+QRY_PED->C5_NUM
		EndIf
		oPrintPvt:Code128C(nLinCab+30+nTamFundo, nColFin-80, cCodBar, 28)
		oPrintPvt:SayAlign(nLinCab+32+nTamFundo, nColFin-80, cCodBar, oFontRod, 080, 07, , nPadLeft, )
	EndIf
	
	//T�tulo
	nLinCab := nLinCabOrig + 080
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + nTamFundo, nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni, "Relat�rio de Pedidos de Venda:", oFontTit, nColFin-nColIni, nTamFundo, nCorAzul, nPadCenter, )
	
	//Linha Separat�rio
	nLinCab += 6
	
	//Cabe�alho com descri��es das colunas
	nLinCab += 3
	If cLayout == "1"
		oPrintPvt:SayAlign(nLinCab, nPosCod,  "C�d.Prod.", oFontDetN, 035, 07, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosDesc, "Descri��o", oFontDetN, 200, 07, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosQuan, "Quant.",    oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVUni, "Vl.Unit.",  oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosSTUn, "Vl.ST",     oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosSTVl, "Vlr + ST",  oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosSTBa, "BC.ST",     oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVTot, "Vl.Total",  oFontDetN, 050, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosSTTo, "Vl.Tot.ST", oFontDetN, 050, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosBIcm, "BC.ICMS",   oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVIcm, "Vl.ICMS",   oFontDetN, 025, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosAIcm, "A.ICMS",    oFontDetN, 025, 07, , nPadRight, )
	Else
		oPrintPvt:SayAlign(nLinCab, nPosCod, "C�d.Prod.",  oFontDetN, 040, 07, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosDesc, "Descri��o", oFontDetN, 200, 07, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosUnid, "Uni.Med.",  oFontDetN, 030, 07, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosQuan, "Quant.",    oFontDetN, 030, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVUni, "Vl.Unit.",  oFontDetN, 030, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVTot, "Vl.Total",  oFontDetN, 060, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosBIcm, "BC.ICMS",   oFontDetN, 030, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVIcm, "Vl.ICMS",   oFontDetN, 030, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVIPI, "Vl.IPI",    oFontDetN, 030, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosAIcm, "A.ICMS",    oFontDetN, 030, 07, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosAIpi, "A.IPI",     oFontDetN, 030, 07, , nPadRight, )
	EndIf
	
	//Atualizando a linha inicial do relat�rio
	nLinAtu := nLinCab + 8
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Fun��o que imprime o rodap�                                  |
 *---------------------------------------------------------------------*/

Static Function fImpRod()
	Local nLinRod:= nLinFin + 10
	Local cTexto := ""

	//Linha Separat�ria
	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin)
	nLinRod += 3
	
	//Dados da Esquerda
	cTexto := "Pedido: "+QRY_PED->C5_NUM+"    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+FunName()+"     "+cUserName
	oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , nPadLeft, )
	
	//Direita
	cTexto := "P�gina "+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , nPadRight, )
	
	//Finalizando a p�gina e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

/*---------------------------------------------------------------------*
 | Func:  fLogoEmp                                                     |
 | Desc:  Fun��o que retorna o logo da empresa (igual a DANFE)         |
 *---------------------------------------------------------------------*/

Static Function fLogoEmp()
	Local cGrpCompany := AllTrim(FWGrpCompany())
	Local cCodEmpGrp  := AllTrim(FWCodEmp())
	Local cUnitGrp    := AllTrim(FWUnitBusiness())
	Local cFilGrp     := AllTrim(FWFilial())
	Local cLogo       := ""
	Local cCamFim     := GetTempPath()
	Local cStart      := GetSrvProfString("Startpath", "")

	//Se tiver filiais por grupo de empresas
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
		
	//Sen�o, ser� apenas, empresa + filial
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf
	
	//Pega a imagem
	cLogo := cStart + "DANFE" + cDescLogo + ".BMP"
	
	//Se o arquivo n�o existir, pega apenas o da empresa, desconsiderando a filial
	If !File(cLogo)
		cLogo	:= cStart + "DANFE" + cEmpAnt + ".BMP"
	EndIf
	
	//Copia para a tempor�ria do s.o.
	CpyS2T(cLogo, cCamFim)
	cLogo := cCamFim + StrTran(cLogo, cStart, "")
	
	//Se o arquivo n�o existir na tempor�ria, espera meio segundo para terminar a c�pia
	If !File(cLogo)
		Sleep(500)
	EndIf
Return cLogo

/*---------------------------------------------------------------------*
 | Func:  fMudaLayout                                                  |
 | Desc:  Fun��o que muda as vari�veis das colunas do layout           |
 *---------------------------------------------------------------------*/

Static Function fMudaLayout()
	oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
	oFontTit   := TFont():New(cNomeFont, , -13, , .T.)
	oFontCab   := TFont():New(cNomeFont, , -07, , .F.)
	oFontCabN  := TFont():New(cNomeFont, , -07, , .T.)
	
	If cLayout == "1"
		nPosCod  := 0010 //C�digo do Produto 
		nPosDesc := 0045 //Descri��o
		nPosQuan := 0245 //Quantidade
		nPosVUni := 0270 //Valor Unitario
		nPosSTUn := 0295 //Valor Unit�rio ST
		nPosSTVl := 0320 //Valor Unit�rio + ST
		nPosSTBa := 0345 //Base do ST
		nPosVTot := 0370 //Valor Total
		nPosSTTo := 0420 //Valor Total ST
		nPosBIcm := 0470 //Base Calculo ICMS
		nPosVIcm := 0495 //Valor ICMS
		nPosAIcm := 0520 //Aliquota ICMS
		
		oFontDet   := TFont():New(cNomeFont, , -06, , .F.)
		oFontDetN  := TFont():New(cNomeFont, , -06, , .T.)
		
	Else
		nPosCod  := 0010 //C�digo do Produto 
		nPosDesc := 0050 //Descri��o
		nPosUnid := 0250 //Unidade de Medida
		nPosQuan := 0280 //Quantidade
		nPosVUni := 0310 //Valor Unitario
		nPosVTot := 0340 //Valor Total
		nPosBIcm := 0400 //Base Calculo ICMS
		nPosVIcm := 0430 //Valor ICMS
		nPosVIPI := 0460 //Valor Ipi
		nPosAIcm := 0490 //Aliquota ICMS
		nPosAIpi := 0520 //Aliquota IPI
		
		oFontDet   := TFont():New(cNomeFont, , -07, , .F.)
		oFontDetN  := TFont():New(cNomeFont, , -07, , .T.)
	EndIf
Return

/*---------------------------------------------------------------------*
 | Func:  fImpTot                                                      |
 | Desc:  Fun��o para imprimir os totais                               |
 *---------------------------------------------------------------------*/

Static Function fImpTot()
	nLinAtu += 4
	
	//Se atingir o fim da p�gina, quebra
	If nLinAtu + 50 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf
	
	//Cria o grupo de Total
	oPrintPvt:Box(nLinAtu, nColIni, nLinAtu + 045, nColFin)
	oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
	nLinAtu += nTamFundo - 5
	oPrintPvt:SayAlign(nLinAtu-10, nColIni+5, "Totais:",                                         oFontTit,  060, nTamFundo, nCorAzul, nPadLeft, )
	nLinAtu += 5
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, "Valor do Frete: ",                                oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni+0095, Alltrim(Transform(nTotFrete, cMaskFrete)),         oFontCabN, 080, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinAtu, nColMeio+005, "Peso.L�q.:",                                      oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColMeio+095, Alltrim(Transform(QRY_PED->C5_PESOL, cMaskPLiq)),  oFontCabN, 080, 07, , nPadRight, )
	nLinAtu += 7
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, "Valor Total dos Produtos: ",                      oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni+0095, Alltrim(Transform(nValorTot, cMaskVlr)),           oFontCabN, 080, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinAtu, nColMeio+005, "Peso.Bru:",                                       oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColMeio+095, Alltrim(Transform(QRY_PED->C5_PBRUTO, cMaskPBru)), oFontCabN, 080, 07, , nPadRight, )
	nLinAtu += 7
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, "Valor do ICMS Substitui��o: ",                    oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni+0095, Alltrim(Transform(nTotalST, cMaskVlr)),            oFontCabN, 080, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinAtu, nColMeio+005, "Valor do IPI:",                                   oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColMeio+095, Alltrim(Transform(nTotIPI, cMaskVlr)),             oFontCabN, 080, 07, , nPadRight, )
	nLinAtu += 7
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, "Valor Total do Pedido: ",                         oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni+0095, Alltrim(Transform(nTotVal, cMaskVlr)),             oFontCabN, 080, 07, , nPadRight, )
	nLinAtu += 10
Return

/*---------------------------------------------------------------------*
 | Func:  fMsgObs                                                      |
 | Desc:  Fun��o para imprimir mensagem de observa��o                  |
 *---------------------------------------------------------------------*/

Static Function fMsgObs()
	Local aMsg  := {"", "", ""}
	Local nQueb := 100
	Local cMsg  := Alltrim(QRY_PED->C5_MENNOTA)
	nLinAtu += 4
	
	//Se atingir o fim da p�gina, quebra
	If nLinAtu + 40 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf
	
	//Quebrando a mensagem
	If Len(cMsg) > nQueb
		aMsg[1] := SubStr(cMsg,    1, nQueb)
		aMsg[1] := SubStr(aMsg[1], 1, RAt(' ', aMsg[1]))
		
		//Pegando o restante e adicionando nas outras linhas
		cMsg := Alltrim(SubStr(cMsg, Len(aMsg[1])+1, Len(cMsg)))
		If Len(cMsg) > nQueb
			aMsg[2] := SubStr(cMsg,    1, nQueb)
			aMsg[2] := SubStr(aMsg[2], 1, RAt(' ', aMsg[2]))
			
			cMsg := Alltrim(SubStr(cMsg, Len(aMsg[2])+1, Len(cMsg)))
			aMsg[3] := cMsg
		Else
			aMsg[2] := cMsg
		EndIf
	Else
		aMsg[1] := cMsg
	EndIf
	
	//Cria o grupo de Observa��o
	oPrintPvt:Box(nLinAtu, nColIni, nLinAtu + 038, nColFin)
	oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
	nLinAtu += nTamFundo - 5
	oPrintPvt:SayAlign(nLinAtu-10, nColIni+5, "Observa��o:",                oFontTit,  100, nTamFundo, nCorAzul, nPadLeft, )
	nLinAtu += 5
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, aMsg[1],                      oFontCab,  400, 07, , nPadLeft, )
	nLinAtu += 7
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, aMsg[2],                      oFontCab,  400, 07, , nPadLeft, )
	nLinAtu += 7
	oPrintPvt:SayAlign(nLinAtu, nColIni+0005, aMsg[3],                      oFontCab,  400, 07, , nPadLeft, )
	nLinAtu += 10
Return

/*---------------------------------------------------------------------*
 | Func:  fMontDupl                                                    |
 | Desc:  Fun��o que monta o array de duplicatas                       |
 *---------------------------------------------------------------------*/

Static Function fMontDupl()
	Local aArea    := GetArea()
	Local lDtEmi   := SuperGetMv("MV_DPDTEMI", .F., .T.)
	Local nAcerto  := 0
	Local aEntr    := {}
	Local aDupl    := {}
	Local aDuplTmp := {}
	Local nItem    := 0
	Local nAux     := 0
	
	aDuplicatas := {}
	
	//Posiciona na condi��o de pagamento
	DbSelectarea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
	
	//Se na planilha financeira do Pedido de Venda as duplicatas ser�o separadas pela Emiss�o
	If lDtEmi
		//Se n�o for do tipo 9
		If (SE4->E4_TIPO != "9")
			//Pega as datas e valores das duplicatas
			aDupl := Condicao(MaFisRet(, "NF_BASEDUP"), SC5->C5_CONDPAG, MaFisRet(, "NF_VALIPI"), SC5->C5_EMISSAO, MaFisRet(, "NF_VALSOL"))
			
			//Se tiver dados, percorre os valores e adiciona dados na �ltima parcela
			If Len(aDupl) > 0
				For nAux := 1 To Len(aDupl)
					nAcerto += aDupl[nAux][2]
				Next nAux
				aDupl[Len(aDupl)][2] += MaFisRet(, "NF_BASEDUP") - nAcerto
			EndIf
		
		//Adiciona uma �nica linha
		Else
			aDupl := {{Ctod(""), MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR")}}
		EndIf
		
	Else
		//Percorre os itens
		nItem := 0
		QRY_ITE->(DbGoTop())
		While ! QRY_ITE->(EoF())
			nItem++
			
			//Se tiver entrega
			If !Empty(QRY_ITE->C6_ENTREG)
				
				//Procura pela data de entrega no Array
				nPosEntr := Ascan(aEntr, {|x| x[1] == QRY_ITE->C6_ENTREG})
				
				//Se n�o encontrar cria a Linha, do contr�rio atualiza os valores
 				If nPosEntr == 0
					aAdd(aEntr, {QRY_ITE->C6_ENTREG, MaFisRet(nItem, "IT_BASEDUP"), MaFisRet(nItem, "IT_VALIPI"), MaFisRet(nItem, "IT_VALSOL")})
				Else
					aEntr[nPosEntr][2]+= MaFisRet(nItem, "IT_BASEDUP")
					aEntr[nPosEntr][2]+= MaFisRet(nItem, "IT_VALIPI")
					aEntr[nPosEntr][2]+= MaFisRet(nItem, "IT_VALSOL")
				EndIf
			EndIf
			
			QRY_ITE->(DbSkip())
		EndDo
		
		//Se n�o for Condi��o do tipo 9
		If (SE4->E4_TIPO != "9")
			
			//Percorre os valores conforme data de entrega
			For nItem := 1 to Len(aEntr)
				nAcerto  := 0
				aDuplTmp := Condicao(aEntr[nItem][2], SC5->C5_CONDPAG, aEntr[nItem][3], aEntr[nItem][1], aEntr[nItem][4])
				
				//Atualiza o valor da �ltima parcela
				For nAux := 1 To Len(aDuplTmp)
					nAcerto += aDuplTmp[nAux][2]
				Next nAux
				aDuplTmp[Len(aDuplTmp)][2] += aEntr[nItem][2] - nAcerto
				
				//Percorre o tempor�rio e adiciona no duplicatas
				aEval(aDuplTmp, {|x| aAdd(aDupl, {aEntr[nItem][1], x[1], x[2]})})
			Next
			
		Else
	    	aDupl := {{Ctod(""), MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR")}}
		EndIf
	EndIf
	
	//Se n�o tiver duplicatas, adiciona em branco
	If Len(aDupl) == 0
		aDupl := {{Ctod(""), MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR")}}
	EndIf
	
	aDuplicatas := aClone(aDupl)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fImpDupl                                                     |
 | Desc:  Fun��o para imprimir as duplicatas                           |
 *---------------------------------------------------------------------*/

Static Function fImpDupl()
	Local nLinhas := NoRound(Len(aDuplicatas)/2, 0) + 1
	Local nAtual  := 0
	Local nLinDup := 0
	Local nLinLim := nLinAtu + ((nLinhas+1)*7) + nTamFundo
	Local nColAux := nColIni
	nLinAtu += 4
	
	//Se atingir o fim da p�gina, quebra
	If nLinLim+5 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf
	
	//Cria o grupo de Duplicatas
	oPrintPvt:Box(nLinAtu, nColIni, nLinLim, nColFin)
	oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
	nLinAtu += nTamFundo - 5
	oPrintPvt:SayAlign(nLinAtu-10, nColIni+5, "Duplicatas:",                oFontTit,  100, nTamFundo, nCorAzul, nPadLeft, )
	nLinAtu += 5
	nLinDup := nLinAtu
	
	//Percorre as duplicatas
	For nAtual := 1 To Len(aDuplicatas)
		oPrintPvt:SayAlign(nLinDup, nColAux+0005, StrZero(nAtual, 3)+", no dia "+dToC(aDuplicatas[nAtual][1])+":", oFontCab,  080, 07, , nPadLeft, )
		oPrintPvt:SayAlign(nLinDup, nColAux+0095, Alltrim(Transform(aDuplicatas[nAtual][2], cMaskVlr)),            oFontCabN, 080, 07, , nPadRight, )
		nLinDup += 7
		
		//Se atingiu o numero de linhas, muda para imprimir na coluna do meio
		If nAtual == nLinhas
			nLinDup := nLinAtu
			nColAux := nColMeio
		EndIf
	Next
	
	nLinAtu += (nLinhas*7) + 3
Return

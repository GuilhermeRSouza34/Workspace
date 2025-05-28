//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zGerSE2
Fun��o que gera t�tulos a pagar
@author Atilio
@since 18/12/2017
@version 1.0
@type function
/*/

User Function zGerSE2()
	Local aArea := GetArea()
	//Objetos da Janela
	Private oDlgPvt
	Private oMsGetTit
	Private aHeadTit := {}
	Private aColsTit := {}
	Private oBtnGera
	Private oBtnFech
	Private oBtnCopy
	//Tamanho da Janela
	Private	aTamanho	:= MsAdvSize()
	Private	nJanLarg	:= aTamanho[5]
	Private	nJanAltu	:= aTamanho[6]
	//Fontes
	Private	cFontUti   := "Tahoma"
	Private	oFontAno   := TFont():New(cFontUti,,-38)
	Private	oFontSub   := TFont():New(cFontUti,,-20)
	Private	oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
	Private	oFontBtn   := TFont():New(cFontUti,,-14)
	
	//Criando o cabe�alho da Grid
	//              Nome               Campo         M�scara                      Tamanho                   Decimal                 Valid          Usado  Tipo F3     CBOX
	aAdd(aHeadTit, {"Prefixo",         "E2_PREFIXO", "",                          TamSX3("E2_PREFIXO")[01], 0,                      ".T.",         ".T.", "C", "",    ""} )
	aAdd(aHeadTit, {"Num.T�tulo",      "E2_NUM",     "",                          TamSX3("E2_NUM"    )[01], 0,                      ".T.",         ".T.", "C", "",    ""} )
	aAdd(aHeadTit, {"Parcela",         "E2_PARCELA", "",                          TamSX3("E2_PARCELA")[01], 0,                      ".T.",         ".T.", "C", "",    ""} )
	aAdd(aHeadTit, {"Tipo",            "E2_TIPO",    "",                          TamSX3("E2_TIPO"   )[01], 0,                      ".T.",         ".T.", "C", "05",  ""} )
	aAdd(aHeadTit, {"Natureza",        "E2_NATUREZ", "",                          TamSX3("E2_NATUREZ")[01], 0,                      ".T.",         ".T.", "C", "SED", ""} )
	aAdd(aHeadTit, {"Fornecedor",      "XX_FORNECE", "",                          TamSX3("E2_FORNECE")[01], 0,                      "u_zSE2For()", ".T.", "C", "SA2", ""} )
	aAdd(aHeadTit, {"Loja",            "XX_LOJA",    "",                          TamSX3("E2_LOJA"   )[01], 0,                      ".F.",         ".T.", "C", "",    ""} )
	aAdd(aHeadTit, {"Nome",            "XX_NOMFOR",  "",                          TamSX3("E2_NOMFOR" )[01], 0,                      ".F.",         ".F.", "C", "",    ""} )
	aAdd(aHeadTit, {"Emiss�o",         "E2_EMISSAO", "",                          TamSX3("E2_EMISSAO")[01], 0,                      ".T.",         ".T.", "D", "",    ""} )
	aAdd(aHeadTit, {"Vencimento",      "E2_VENCTO",  "",                          TamSX3("E2_VENCTO" )[01], 0,                      "u_zSE2Dat()", ".T.", "D", "",    ""} )
	aAdd(aHeadTit, {"Vencimento Real", "E2_VENCREA", "",                          TamSX3("E2_VENCREA")[01], 0,                      ".T.",         ".T.", "D", "",    ""} )
	aAdd(aHeadTit, {"Valor T�tulo",    "E2_VALOR",   PesqPict('SE2', 'E2_VALOR'), TamSX3("E2_VALOR"  )[01], TamSX3("E2_VALOR")[02], ".T.",         ".T.", "N", "",    ""} )
	aAdd(aHeadTit, {"Conta Cont�bil",  "E2_CONTAD",  "",                          TamSX3("E2_CONTAD" )[01], 0,                      ".T.",         ".T.", "C", "CT1", ""} )
	aAdd(aHeadTit, {"Hist�rico",       "E2_HIST",    "",                          TamSX3("E2_HIST"   )[01], 0,                      ".T.",         ".T.", "C", "",    ""} )

	//Cria��o da tela com os dados que ser�o informados dos t�tulos
	DEFINE MSDIALOG oDlgPvt TITLE "Cria��o de T�tulos - Contas a Pagar" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Labels gerais
		@ 004, 003 SAY "FIN" SIZE 200, 030 FONT oFontAno OF oDlgPvt COLORS RGB(149,179,215) PIXEL
		@ 004, 040 SAY "Gera��o de" SIZE 200, 030 FONT oFontSub OF oDlgPvt COLORS RGB(031,073,125) PIXEL
		@ 014, 040 SAY "T�tulos a Pagar" SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
		
		//Bot�es
		@ 006, (nJanLarg/2-001)-(0067*03) BUTTON oBtnCopy  PROMPT "Copiar Linha"  SIZE 065, 018 OF oDlgPvt ACTION (fCopLinha())                                FONT oFontBtn PIXEL
		@ 006, (nJanLarg/2-001)-(0067*02) BUTTON oBtnGera  PROMPT "Gerar"         SIZE 065, 018 OF oDlgPvt ACTION (Processa({|| fGeraTit()}, "Processando"))   FONT oFontBtn PIXEL
		@ 006, (nJanLarg/2-001)-(0067*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 065, 018 OF oDlgPvt ACTION (oDlgPvt:End())                              FONT oFontBtn PIXEL
		
		//Grid dos t�tulos financeiros
		oMsGetTit := MsNewGetDados():New(	029,;                                        //nTop
    										003,;                                        //nLeft
    										(nJanAltu/2)-3,;                             //nBottom
    										(nJanLarg/2)-3,;                             //nRight
    										GD_INSERT + GD_DELETE + GD_UPDATE,;          //nStyle
    										"AllwaysTrue()",;                            //cLinhaOk
    										,;                                           //cTudoOk
    										"",;                                         //cIniCpos
    										,;                                           //aAlter
    										,;                                           //nFreeze
    										9999,;                                       //nMax
    										,;                                           //cFieldOK
    										,;                                           //cSuperDel
    										,;                                           //cDelOk
    										oDlgPvt,;                                    //oWnd
    										aHeadTit,;                                   //aHeader
    										aColsTit)                                    //aCols
	
	ACTIVATE MSDIALOG oDlgPvt CENTERED
	
	RestArea(aArea)
Return

/*------------------------------------------------*
 | Func.: fGeraTit                                |
 | Desc.: Fun��o que gera os t�tulos financeiros  |
 *------------------------------------------------*/

Static Function fGeraTit()
	Local aArea     := GetArea()
	Local aColsAux  := oMsGetTit:aCols
	Local nAtual    := 0
	Local nModBkp   := 0
	Local lContinua := .T.
	Local cEmBranco := ""
	Local nPosPre   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_PREFIXO"})
	Local nPosTit   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_NUM"    })
	Local nPosPar   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_PARCELA"})
	Local nPosTip   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_TIPO"   })
	Local nPosNat   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_NATUREZ"})
	Local nPosFor   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "XX_FORNECE"})
	Local nPosLoj   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "XX_LOJA"   })
	Local nPosNom   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "XX_NOMFOR" })
	Local nPosEmi   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_EMISSAO"})
	Local nPosVen   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_VENCTO" })
	Local nPosRea   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_VENCREA"})
	Local nPosVal   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_VALOR"  })
	Local nPosCon   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_CONTAD" })
	Local nPosHis   := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_HIST"   })
	Local aVetSE2   := {}
	
	DbSelectArea('SE2')
	SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
	
	ProcRegua(Len(aColsAux))
	
	//Percorre as linhas
	For nAtual := 1 To Len(aColsAux)
		IncProc("Analisando a linha "+cValToChar(nAtual)+" de "+cValToChar(Len(aColsAux))+"...")
		
		//Se a linha n�o estiver exclu�da
		If ! aColsAux[nAtual][Len(aHeadTit) + 1]
			cEmBranco := ""
			
			//Se j� existir um t�tulo com esse n�mero, retorna erro
			If SE2->(DbSeek(FWxFilial('SE2') + aColsAux[nAtual][nPosPre] + aColsAux[nAtual][nPosTit] + aColsAux[nAtual][nPosPar] + aColsAux[nAtual][nPosTip] + aColsAux[nAtual][nPosFor] + aColsAux[nAtual][nPosLoj]))
				MsgStop("N�mero de t�tulo com esse prefixo, para esse fornecedor j� encontrado!" + CRLF +;
					"Linha: " + cValToChar(nAtual) + CRLF +;
					"T�tulo: " + aColsAux[nAtual][nPosTit], "Aten��o")
				lContinua := .F.
			EndIf
			
			//Se houver algum campo obrigat�rio em branco, retorna erro
			//cEmBranco += Iif(Empty(aColsAux[nAtual][nPosPre]), "Prefixo" + CRLF,         "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosTit]), "Num.T�tulo" + CRLF,      "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosPar]), "Parcela" + CRLF,         "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosTip]), "Tipo" + CRLF,            "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosNat]), "Natureza" + CRLF,        "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosFor]), "Fornecedor" + CRLF,      "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosLoj]), "Loja" + CRLF,            "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosNom]), "Nome" + CRLF,            "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosEmi]), "Emiss�o" + CRLF,         "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosVen]), "Vencimento" + CRLF,      "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosRea]), "Vencimento Real" + CRLF, "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosVal]), "Valor T�tulo" + CRLF,    "")
			//cEmBranco += Iif(Empty(aColsAux[nAtual][nPosCon]), "Conta Cont�bil" + CRLF,  "")
			cEmBranco += Iif(Empty(aColsAux[nAtual][nPosHis]), "Hist�rico" + CRLF,       "")
			
			If ! Empty(cEmBranco)
				MsgStop("Campo(s) em branco: "+CRLF+cEmBranco, "Aten��o")
				lContinua := .F.
			EndIf
		EndIf
	Next
	
	//Se n�o houve erro no processo
	If lContinua
		//Faz um backup da nModulo e altera para financeiro
		nModBkp := nModulo
		nModulo := 6
		
		ProcRegua(Len(aColsAux))
		
		//Percorre novamente os dados digitados
		For nAtual := 1 To Len(aColsAux)
		
			IncProc("Gerando T�tulo - linha "+cValToChar(nAtual)+" de "+cValToChar(Len(aColsAux))+"...")
			
			//Se a linha n�o estiver exclu�da
			If ! aColsAux[nAtual][Len(aHeadTit) + 1]
				//Prepara o array para o execauto
				aVetSE2 := {}
				aAdd(aVetSE2, {"E2_FILIAL",  FWxFilial("SE2"),          Nil})
				aAdd(aVetSE2, {"E2_NUM",     aColsAux[nAtual][nPosTit], Nil})
				aAdd(aVetSE2, {"E2_PREFIXO", aColsAux[nAtual][nPosPre], Nil})
				aAdd(aVetSE2, {"E2_PARCELA", aColsAux[nAtual][nPosPar], Nil})
				aAdd(aVetSE2, {"E2_TIPO",    aColsAux[nAtual][nPosTip], Nil})
				aAdd(aVetSE2, {"E2_NATUREZ", aColsAux[nAtual][nPosNat], Nil})
				aAdd(aVetSE2, {"E2_FORNECE", aColsAux[nAtual][nPosFor], Nil})
				aAdd(aVetSE2, {"E2_LOJA",    aColsAux[nAtual][nPosLoj], Nil})
				aAdd(aVetSE2, {"E2_NOMFOR",  aColsAux[nAtual][nPosNom], Nil})
				aAdd(aVetSE2, {"E2_EMISSAO", aColsAux[nAtual][nPosEmi], Nil})
				aAdd(aVetSE2, {"E2_VENCTO",  aColsAux[nAtual][nPosVen], Nil})
				aAdd(aVetSE2, {"E2_VENCREA", aColsAux[nAtual][nPosRea], Nil})
				aAdd(aVetSE2, {"E2_VALOR",   aColsAux[nAtual][nPosVal], Nil})
				aAdd(aVetSE2, {"E2_CONTAD",  aColsAux[nAtual][nPosCon], Nil})
				aAdd(aVetSE2, {"E2_HIST",    aColsAux[nAtual][nPosHis], Nil})
				
				//Inicia o controle de transa��o
				Begin Transaction
					//Chama a rotina autom�tica
					lMsErroAuto := .F.
					MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)
					
					//Se houve erro, mostra o erro ao usu�rio e desarma a transa��o
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					EndIf
				//Finaliza a transa��o
				End Transaction
			EndIf
		Next
			
		//Volta a vari�vel nModulo
		nModulo := nModBkp
	EndIf
	
	RestArea(aArea)
Return

/*-----------------------------------------------------------*
 | Func.: fCopLinha                                          |
 | Desc.: Fun��o que copia a linha e cria uma nova em baixo  |
 *-----------------------------------------------------------*/

Static Function fCopLinha()
	Local aArea    := GetArea()
	Local aColsAux := oMsGetTit:aCols
	Local nLinha   := oMsGetTit:nAt
	Local aLinNov  := {}
	Local nPosTit  := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_NUM"})
	Local nPosParc := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_PARCELA"})
	Local aPergs   := {}
	Local aRetorn  := {}
	Local cTitulo  := aColsAux[nLinha][nPosTit]
	Local nQuant   := 0
	Local nAtual   := 0
	Local cIncParc := "1"
	
	//Se n�o tiver t�tulo, n�o poder� ser copiado
	If Empty(cTitulo)
		MsgAlert("Linha com t�tulo em branco, n�o poder� ser copiada.", "Aten��o")
	
	Else
		//Cria uma c�pia da Linha
		aLinNov := aClone(aColsAux[nLinha])
		aLinNov[nPosTit] := Space(Len(aLinNov[nPosTit]))
		
		//Se a parcela tiver em branco, muda para n�o a pergunta
		If Empty(aColsAux[nLinha][nPosParc])
			cIncParc := "2"
		EndIf
		
		//Adiciona os parametros para a pergunta
		aAdd(aPergs, {1, "T�tulo",              cTitulo, "",       ".T.",        "", ".F.", 80, .F.})
		aAdd(aPergs, {1, "Quantidade",          nQuant,  "@E 999", "Positivo()", "", ".T.", 80, .T.})
		aAdd(aPergs, {2, "Incrementa Parcela",  Val(cIncParc), {"1=Sim", "2=N�o"},          80, ".T.", .F.})
		
		//Se a pergunta for confirmada
		If ParamBox(aPergs, "Informe os par�metros", @aRetorn, , , , , , , , .F., .F.)
			nQuant   := aRetorn[2]
			cIncParc := cValToChar(aRetorn[3])
			
			//Adiciona no array
			For nAtual := 1 To nQuant
				If cIncParc == "1"
					aLinNov[nPosParc] := Soma1(aLinNov[nPosParc])
				EndIf
				
				aAdd(aColsAux, aClone(aLinNov))
			Next
		EndIf
		
		//Seta novamente o array
		oMsGetTit:SetArray(aColsAux)
		oMsGetTit:Refresh()
	EndIf
	
	RestArea(aArea)
Return

/*/{Protheus.doc} zSE2For
Fun��o que valida o fornecedor digitado
@author Atilio
@since 19/12/2017
@version 1.0
@type function
/*/

User Function zSE2For()
	Local aArea    := GetArea()
	Local lRet     := .T.
	Local cForn    := &( ReadVar() )
	Local nLinha   := oMsGetTit:nAt
	Local nPosLoj  := aScan(aHeadTit, {|x| Alltrim(x[2]) == "XX_LOJA"   })
	Local nPosNom  := aScan(aHeadTit, {|x| Alltrim(x[2]) == "XX_NOMFOR" })
	
	DbSelectArea('SA2')
	SA2->(DbSetOrder(1))
	
	//Tenta posicionar no fornecedor
	If SA2->(DbSeek(FWxFilial('SA2') + cForn))
		oMsGetTit:aCols[nLinha][nPosLoj] := SA2->A2_LOJA
		oMsGetTit:aCols[nLinha][nPosNom] := SA2->A2_NOME
		
	Else
		lRet := .F.
		MsgStop("Fornecedor n�o encontrado!", "Aten��o")
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} zSE2Dat
Fun��o que valida a data de vencimento, atualizando o vencimento real
@author Atilio
@since 19/12/2017
@version 1.0
@type function
/*/

User Function zSE2Dat()
	Local aArea    := GetArea()
	Local lRet     := .T.
	Local dVencto  := &( ReadVar() )
	Local nLinha   := oMsGetTit:nAt
	Local nPosReal := aScan(aHeadTit, {|x| Alltrim(x[2]) == "E2_VENCREA" })
	
	//Pega a pr�xima data v�lida do sistema
	oMsGetTit:aCols[nLinha][nPosReal] := DataValida(dVencto, .T.)
			
	RestArea(aArea)
Return lRet
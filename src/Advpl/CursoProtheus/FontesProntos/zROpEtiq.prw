//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//Variáveis estáticas
Static nCorAzul   := RGB(062, 179, 206)
Static nCorCinza  := RGB(200, 200, 200)

/*/{Protheus.doc} zROpEtiq
Impressão de etiquetas de Ordem de Produção em pdf
@author Atilio
@since 24/08/2016
@version 1.0
@type function
/*/

User Function zROpEtiq()
	Local aArea      := GetArea()
	Local aPergs     := {}
	Private cOPDe    := Space(TamSX3('D3_OP')[01])
	Private cOPAt    := StrTran(cOPDe, ' ', 'Z')
	Private dDataDe  := FirstDate(Date())
	Private dDataAt  := LastDate(dDataDe)
	Private nTipo    := 3
	Private nPrevis  := 2
	Private nTipoQtd := 2
	Private nCopias  := 1
	
    aAdd(aPergs, {1, "OP De",       cOPDe,    "",       ".T.",        "SC2", ".T.", 90,  .F.})
    aAdd(aPergs, {1, "OP Até",      cOPAt,    "",       ".T.",        "SC2", ".T.", 90,  .T.})
    aAdd(aPergs, {1, "Emissão De",  dDataDe,  "",       ".T.",        "",    ".T.", 70,  .F.})
    aAdd(aPergs, {1, "Emissão Até", dDataAt,  "",       ".T.",        "",    ".T.", 70,  .T.})
    aAdd(aPergs, {2, "Tipo Relatório",     nTipo,    {"1=Somente em Aberto",   "2=Somente Finalizadas", "3=Ambas"},     110, ".T.", .F.})
    aAdd(aPergs, {2, "Imp Previsões",      nPrevis,  {"1=Não",                 "2=Sim"},                                 40, ".T.", .F.})
    aAdd(aPergs, {2, "Imp Quantidade",     nTipoQtd, {"1=Quantidade Original", "2=Saldo da OP"},                        110, ".T.", .F.})
    aAdd(aPergs, {1, "Qtde Cópias", nCopias,  "@E 99",  "Positivo()", "",    ".T.", 40,  .F.})
	
	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
		cOPDe    := MV_PAR01
		cOPAt    := MV_PAR02
		dDataDe  := MV_PAR03
		dDataAt  := MV_PAR04
		nTipo    := Val(cValToChar(MV_PAR05))
		nPrevis  := Val(cValToChar(MV_PAR06))
		nTipoQtd := Val(cValToChar(MV_PAR07))
		nCopias  := Iif(MV_PAR08 <= 0, 1, MV_PAR08)
		
		Processa({|| fMontaRel()}, "Processando...")
	EndIf
	
	RestArea(aArea)
Return

Static Function fMontaRel()
	Local cNomeRel    := "zROpEtiq_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
	Local cQryOP      := ""
	Local nTotOP      := 0
	Local nOPAtu      := 0
	Local nAtuCpy     := 0
	Private cHoraEx   := Time()
	Private nPagAtu   := 1
	Private nPagTot   := 1
	Private nQtdQua   := 5
    Private cPastaTmp := GetTempPath()
	//Linhas e colunas
	Private nLinAtu   := 0
	Private nLinIni   := 050
	Private nLinFin   := 820
	Private nColIni   := 010
	Private nColFin   := 550
	Private nColMeio  := (nColFin-nColIni)/2
	Private nQuadrOP  := (nLinFin-nLinIni)/nQtdQua - 9 //150
	Private oPrintPvt
	//Declarando as fontes
	Private cNomeFont := "Arial"
	Private oFontDet  := TFont():New(cNomeFont, 9, -13, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontRod  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontTit  := TFont():New(cNomeFont, 9, -22, .T., .T., 5, .T., 5, .T., .F.)
	
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	DbSelectArea('SC2')
	SC2->(DbSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	
	//Selecionando os orçamentos
	cQryOP := " SELECT "
	cQryOP += "    SC2.R_E_C_N_O_ AS C2REC, "
	cQryOP += "    SB1.R_E_C_N_O_ AS B1REC "
	cQryOP += " FROM "
	cQryOP += "    "+RetSQLName('SC2')+" SC2 "
	cQryOP += "    INNER JOIN "+RetSQLName('SB1')+" SB1 ON ( "
	cQryOP += "        B1_FILIAL = '"+FWxFilial('SB1')+"' "
	cQryOP += "        AND B1_COD = SC2.C2_PRODUTO "
	cQryOP += "        AND SB1.D_E_L_E_T_ = ' ' "
	cQryOP += "    ) "
	cQryOP += " WHERE "
	cQryOP += "    C2_FILIAL = '"+FWxFilial('SC2')+"' "
	cQryOP += "    AND C2_NUM+C2_ITEM+C2_SEQUEN >= '"+cOPDe+"' "
	cQryOP += "    AND C2_NUM+C2_ITEM+C2_SEQUEN <= '"+cOPAt+"' "
	cQryOP += "    AND C2_EMISSAO >= '"+dToS(dDataDe)+"' "
	cQryOP += "    AND C2_EMISSAO <= '"+dToS(dDataAt)+"' "
	If nTipo == 1
		cQryOP += "    AND C2_DATRF  = '"+Space(TamSX3('C2_DATRF')[01])+"' "
	ElseIf nTipo == 2
		cQryOP += "    AND C2_DATRF != '"+Space(TamSX3('C2_DATRF')[01])+"' "
	EndIf
	cQryOP += "    AND SC2.D_E_L_E_T_ = ' ' "
	cQryOP := ChangeQuery(cQryOP)
	TCQuery cQryOP New Alias "QRY_DAD"
	
	Count To nTotOP
	nTotOP := nTotOP * nCopias
	ProcRegua(nTotOP)
	QRY_DAD->(DbGoTop())
	
	//Somente se houver orçamentos
	If nTotOP != 0
        //Gera o objeto de impressão
        oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
        
        //Setando os atributos necessários
        oPrintPvt:cPathPDF := cPastaTmp
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(60, 60, 60, 60)
		oPrintPvt:StartPage()
		nLinAtu := nLinIni
		nPagAtu := 1
		nPagTot := Int(nTotOP/nQtdQua) + Iif(nTotOP % nQtdQua != 0, 1, 0)
		
		//Enquanto houver orçamentos
		While ! QRY_DAD->(EoF())
			For nAtuCpy := 1 To nCopias
				SB1->(DbGoTo(QRY_DAD->B1REC))
				SC2->(DbGoTo(QRY_DAD->C2REC))
				nOPAtu++
				IncProc("Processando OP "+cValToChar(nOPAtu)+" de "+cValToChar(nTotOP)+"...")
				
				//Imprime a etiqueta da OP
				fQuadrOP()
				nLinAtu += (nQuadrOP + 12)
				
				//Cria uma linha cinza entre os box
				oPrintPvt:Line(nLinAtu-6, nColIni, nLinAtu-6, nColFin, nCorCinza, "-1")
					
				//Se por acaso atingiu o limite da página, finaliza, e começa uma nova página
				If nOPAtu % nQtdQua == 0
					fRodape()
					oPrintPvt:StartPage()
					nLinAtu := nLinIni
					nPagAtu++
				EndIf
			Next
			
			QRY_DAD->(DbSkip())
		EndDo
		QRY_DAD->(DbCloseArea())
		
		//Se acabou no meio da página
		If nOPAtu % nQtdQua != 0
			nLinAtu := nLinIni
			nLinAtu += (nQuadrOP + 12) * nQtdQua
			fRodape()
		EndIf
		
		//Mostra o pdf
		oPrintPvt:Preview()
	
	Else
		QRY_DAD->(DbCloseArea())
		MsgStop("Não há ordens de produção!", "Atenção")
	EndIf
Return

Static Function fQuadrOP()
	Local nLinAux  := nLinAtu
	Local cEmpresa := Alltrim(Upper(FWEmpName(cEmpAnt)))+" - "+FWFilialName()
	Local nEspLin  := Iif(nPrevis == 2, 017, 025)
	Local nQtde    := Iif(nTipoQtd == 1, SC2->C2_QUANT, aSC2Sld())
	Local cCodBar  := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	
	//Desenha a caixa da OP
	oPrintPvt:Box(nLinAux, nColIni, nLinAux + nQuadrOP, nColFin)
	
	//Nome da Filial
	nLinAux += 3
	oPrintPvt:SayAlign(nLinAux, nColIni+5, cEmpresa, oFontTit, 400, 05, nCorAzul, PAD_LEFT,  )
	
	//O.P.
	nLinAux += 025
	oPrintPvt:SayAlign(nLinAux, nColIni+5, "Ordem de Produção:", oFontDet,  120, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinAux, nColIni+125, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, oFontDetN, 200, 05, , PAD_LEFT,  )
	
	//Produto
	nLinAux += nEspLin
	oPrintPvt:SayAlign(nLinAux, nColIni+5, "Produto:", oFontDet, 120, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinAux, nColIni+125, SC2->C2_PRODUTO, oFontDetN, 200, 05, , PAD_LEFT,  )
	
	//Descrição
	nLinAux += nEspLin
	oPrintPvt:SayAlign(nLinAux, nColIni+5, "Descrição:", oFontDet, 120, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinAux, nColIni+125, SB1->B1_DESC, oFontDetN, 200, 05, , PAD_LEFT,  )
	
	//Emissão
	nLinAux += nEspLin
	oPrintPvt:SayAlign(nLinAux, nColIni+5, "Emissão:", oFontDet, 120, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinAux, nColIni+125, dToC(SC2->C2_EMISSAO), oFontDetN, 200, 05, , PAD_LEFT,  )
	
	//Quantidade
	nLinAux += nEspLin
	oPrintPvt:SayAlign(nLinAux, nColIni+5, "Quantidade:", oFontDet, 120, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinAux, nColIni+125, Alltrim(Transform(nQtde, PesqPict('SC2', 'C2_QUANT'))), oFontDetN, 200, 05, , PAD_LEFT,  )
	
	//Se tiver previsões
	If nPrevis == 2
		//Previsão Inicial
		nLinAux += nEspLin
		oPrintPvt:SayAlign(nLinAux, nColIni+5, "Previsão Inicial:", oFontDet, 120, 05, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAux, nColIni+125, dToC(SC2->C2_DATPRI), oFontDetN, 200, 05, , PAD_LEFT,  )
		
		//Previsão Final
		nLinAux += nEspLin
		oPrintPvt:SayAlign(nLinAux, nColIni+5, "Previsão Final:", oFontDet, 120, 05, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAux, nColIni+125, dToC(SC2->C2_DATPRF), oFontDetN, 200, 05, , PAD_LEFT,  )
	EndIf
	
	//Imprimindo a foto do produto
    If ! Empty(SB1->B1_BITMAP)
        //Define o nome da foto
        cFotoProd := cPastaTmp + "produto_" + SB1->B1_COD + ".jpg"

        //Se a foto já existir na temporária do S.O., exclui
        If File(cFotoProd)
            FErase(cFotoProd)
        EndIf

        //Faz a extração da imagem do Protheus
        RepExtract(Alltrim(SB1->B1_BITMAP), cFotoProd)

        //Se deu certo de extrair a imagem, será impressa
        If File(cFotoProd)
            nLinAux := nLinAtu + 04
	        oPrintPvt:SayBitmap(nLinAux, nColFin-120, cFotoProd, 58.75, 64.5) //86.4, 86.4
        EndIf
    EndIf
	
	//Imprimindo o código de barras
	nLinAux := nLinAtu + 130
	//oPrintPvt:Code128C(nLinAux,   nColFin-127, cCodBar, 40) //TODO
	oPrintPvt:Code128(nLinAux - 38,   nColFin-127, cCodBar, 1, 40)
	oPrintPvt:SayAlign(nLinAux+2, nColFin-127, cCodBar, oFontRod, 080, 05, , PAD_LEFT,  )
Return

Static Function fRodape()
    Local cTexto

    //Dados da Esquerda
	cTexto := "Etiquetas OPs    |    "+dToC(Date())+"     "+cHoraEx+"     "+FunName()+" (zROpEtiq)     "+cUserName
	oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto, oFontRod, 250, 05, , PAD_LEFT, )

    //Dados da Direita
	oPrintPvt:SayAlign(nLinAtu, nColFin-50, "Página "+cValToChar(nPagAtu)+" de "+cValToChar(nPagTot), oFontRod, 050, 05, nCorAzul, PAD_RIGHT,  )
	oPrintPvt:EndPage()
Return

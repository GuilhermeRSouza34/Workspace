//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//Colunas
#Define POS_SEQ   0010 //Sequência 
#Define POS_EMIS  0060 //Emissão
#Define POS_VENC  0110 //Vencimento
#Define POS_OBS   0170 //Vencimento
#Define POS_VALOR 0470 //Valor

//Variáveis estáticas
Static nTamFundo  := 15
Static cEmpEmail  := Alltrim(SuperGetMV('MV_X_EMAIL', .F., "email@empresa.com.br"))
Static cEmpSite   := Alltrim(SuperGetMV('MV_X_HPAGE', .F., "http://www.empresa.com.br"))
Static nCorAzul   := RGB(062,179,206)

/*/{Protheus.doc} zRAdianRec
Impressão gráfica de Adiantamentos de Clientes (Tí­tulos RA)
@author Atilio
@since 29/08/2016
@version 1.0
@param cXCodCli, caracter, Código do Cliente
@param cXLojCli, caracter, Loja do Cliente
@param cXNumDe, caracter, Tí­tulo Inicial
@param cXNumAt, caracter, Tí­tulo Final
/*/

User Function zRAdianRec(cXCodCli, cXLojCli, cXNumDe, cXNumAt)
	Local aArea      := GetArea()
	Local aPergs     := {}
	Default cXCodCli := Space(TamSX3('A1_COD')[1])
	Default cXLojCli := Space(TamSX3('A1_LOJA')[1])
	Default cXNumDe  := Space(TamSX3('E1_NUM')[1])
	Default cXNumAt  := StrTran(cXNumDe, ' ', 'Z')
	Private cLogoEmp := fLogoEmp()
	Private cCodCli  := cXCodCli
	Private cLojCli  := cXLojCli
	Private cNumDe   := cXNumDe
	Private cNumAt   := cXNumAt
	Private lAuto    := ! Empty(cCodCli)
	
	//Se for o processo automático, não mostra a pergunta
	If lAuto
		Processa({|| fMontaRel()}, "Processando...")
		
	Else
		aAdd(aPergs, {1, "Cliente",    cCodCli,  "", ".T.", "SA1", ".T.", 60,  .T.})
		aAdd(aPergs, {1, "Loja",       cLojCli,  "", ".T.", "",    ".T.", 40,  .F.})
		aAdd(aPergs, {1, "Título De",  cNumDe,   "", ".T.", "",    ".T.", 80,  .F.})
		aAdd(aPergs, {1, "Título Até", cNumAt,   "", ".T.", "",    ".T.", 80,  .T.})

		//Se a pergunta for confirmada
		If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
			cCodCli  := MV_PAR01
			cLojCli  := MV_PAR02
			cNumDe   := MV_PAR03
			cNumAt   := MV_PAR04
			
			Processa({|| fMontaRel()}, "Processando...")
		EndIf
	EndIf
	
	RestArea(aArea)
Return

Static Function fMontaRel()
	Local cNomeRel    := "recebimento_"+dToS(Date())+"_"+StrTran(Time(), ":", "-")+"_"+RetCodUsr()
	Local cQryDad     := ""
	Local nTitAtu     := 0
	Local nTotTit     := 0
	Private cMascara  := PesqPict('SE1', 'E1_VALOR')
	Private cHoraEx   := Time()
	Private nPagAtu   := 1
	Private nValorTot := 0
	//Linhas e colunas
	Private nLinAtu   := 0
	Private nLinFin   := 820
	Private nColIni   := 010
	Private nColFin   := 550
	Private nColMeio  := (nColFin-nColIni)/2
	Private oPrintPvt
	//Declarando as fontes
	Private cNomeFont := "Arial"
	Private oFontDet  := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
	Private oFontRod  := TFont():New(cNomeFont, 9, -6,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontCab  := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontCabN := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
	
	//Se não tiver código do cliente, finaliza
	If Empty(cCodCli)
		Return
	EndIf
	
	//Se não tiver loja, deixa sem espaços em branco para posicionar corretamente
	If Empty(cLojCli)
		cLojCli := ""
	EndIf
	
	DbSelectArea('SA1')
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbGoTop())
	
	//Se conseguir posicionar no cliente
	If SA1->(DbSeek(FWxFilial('SA1') + cCodCli + cLojCli))
		
		//Selecionando os títulos
		cQryDad := " SELECT " + CRLF
		cQryDad += "    E1_EMISSAO, " + CRLF
		cQryDad += "    E1_VENCREA, " + CRLF
		cQryDad += "    E1_HIST, " + CRLF
		cQryDad += "    E1_VALOR " + CRLF
		cQryDad += " FROM " + CRLF
		cQryDad += "    "+RetSQLName('SE1')+" SE1 " + CRLF
		cQryDad += " WHERE " + CRLF
		cQryDad += "    E1_FILIAL = '"+FWxFilial('SE1')+"' " + CRLF
		cQryDad += "    AND E1_CLIENTE = '"+SA1->A1_COD+"' " + CRLF
		cQryDad += "    AND E1_LOJA    = '"+SA1->A1_LOJA+"' " + CRLF
		cQryDad += "    AND E1_VALOR > 0 " + CRLF
		cQryDad += "    AND E1_TIPO = 'RA' " + CRLF
		cQryDad += "    AND E1_NUM >= '"+cNumDe+"' " + CRLF
		cQryDad += "    AND E1_NUM <= '"+cNumAt+"' " + CRLF
		cQryDad += "    AND SE1.D_E_L_E_T_ = ' ' " + CRLF
		cQryDad := ChangeQuery(cQryDad)
		TCQuery cQryDad New Alias "QRY_DAD"
		TCSetField("QRY_DAD", "E1_EMISSAO", "D")
		TCSetField("QRY_DAD", "E1_VENCREA", "D")
		
		//Definindo a régua
		Count To nTotTit
		ProcRegua(nTotTit)
		QRY_DAD->(DbGoTop())
		
		//Somente se houver Tí­tulos
		QRY_DAD->(DbGoTop())
		If nTotTit != 0
			//Setando os atributos necessários
			oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
			oPrintPvt:cPathPDF := GetTempPath()
			oPrintPvt:SetResolution(72)
			oPrintPvt:SetPortrait()
			oPrintPvt:SetPaperSize(DMPAPER_A4)
			oPrintPvt:SetMargin(60, 60, 60, 60)

			//Pegando o valor total
			While ! QRY_DAD->(EoF())
				nValorTot += QRY_DAD->E1_VALOR
				
				QRY_DAD->(DbSkip())
			EndDo
			
			//Imprimindo o cabeçalho
			fImpCab()
			
			//Enquanto houver Tí­tulos
			QRY_DAD->(DbGoTop())
			While ! QRY_DAD->(EoF())
				nPagAtu := 1
				nTitAtu++
				IncProc("Processando o Tí­tulo "+cValToChar(nTitAtu)+" de "+cValToChar(nTotTit)+"...")
				
				//Imprimindo os dados
				oPrintPvt:SayAlign(nLinAtu, POS_SEQ,   StrZero(nTitAtu, 3),                                   oFontDet, 050, 05, , PAD_LEFT,  )
				oPrintPvt:SayAlign(nLinAtu, POS_EMIS,  dToC(QRY_DAD->E1_EMISSAO),                             oFontDet, 050, 05, , PAD_LEFT,  )
				oPrintPvt:SayAlign(nLinAtu, POS_VENC,  dToC(QRY_DAD->E1_VENCREA),                             oFontDet, 050, 05, , PAD_LEFT,  )
				oPrintPvt:SayAlign(nLinAtu, POS_OBS,   QRY_DAD->E1_HIST,                                      oFontDet, 200, 05, , PAD_LEFT,  )
				oPrintPvt:SayAlign(nLinAtu, POS_VALOR, Alltrim(Transform(QRY_DAD->E1_VALOR, cMascara)),       oFontDetN, 080, 05, , PAD_RIGHT, )
				nLinAtu += 7
				
				//Se por acaso atingiu o limite da página, finaliza, e começa uma nova página
				If nLinAtu >= nLinFin-53
					fImpRod()
					fImpCab()
				EndIf
				
				QRY_DAD->(DbSkip())
			EndDo
			QRY_DAD->(DbCloseArea())
			
			//Imprime o total do Tí­tulo
			nLinAtu += 2
			oPrintPvt:Line(nLinAtu,   nColIni, nLinAtu,   nColFin)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, POS_SEQ,  "Total:", oFontDetN, 050, 05, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, POS_VALOR, Alltrim(Transform(nValorTot, cMascara)),  oFontDetN, 080, 05, , PAD_RIGHT, )
			nLinAtu += 20
			
			//Imprimindo a data por extenso
			oPrintPvt:SayAlign(nLinAtu, nColFin-170, "BAURU, "+fDtExtenso(),  oFontDetN, 170, 05, , PAD_RIGHT, )
			nLinAtu += 30
			
			//Gerando a linha de assinatura
			oPrintPvt:Line(nLinAtu,   nColFin-170, nLinAtu,   nColFin)
			
			//Se houver linhas na página ainda, imprime o rodapé
			fImpRod()
			
			oPrintPvt:Preview()
		
		Else
			QRY_DAD->(DbCloseArea())
			MsgStop("Não há recebimentos antecipados!", "Atenção")
		EndIf
	EndIf
Return

Static Function fImpCab()
	Local nLinCab     := 025
	Local nLinCabOrig := nLinCab
	Local lCNPJ       := (SA1->A1_PESSOA != 'F')
	Local cCGC        := ""
	//Dados da empresa
	Local aSM0Data    := FWSM0Util():GetSM0Data(, cFilAnt, {"M0_NOMECOM", "M0_NOME", "M0_TEL", "M0_FAX", "M0_CIDCOB", "M0_ESTCOB", "M0_CGC", "M0_CEPCOB"})
	Local cEmpresa    := Iif(Empty(aSM0Data[01][2]), Alltrim(aSM0Data[02][2]), Alltrim(aSM0Data[01][2]))
	Local cEmpTel     := Alltrim(Transform(SubStr(aSM0Data[03][2],3,Len(aSM0Data[03][2])),"@R (99) 9999-9999"))
	Local cEmpFax     := Alltrim(Transform(SubStr(aSM0Data[04][2],3,Len(aSM0Data[04][2])),"@R (99) 9999-9999"))
	Local cEmpCidade  := AllTrim(aSM0Data[05][2])+" / "+aSM0Data[06][2]
	Local cEmpCnpj    := Alltrim(Transform(aSM0Data[07][2],"@R 99.999.999/9999-99"))
	Local cEmpCep     := Alltrim(Transform(aSM0Data[08][2],"@R 99999-999"))
	
	//Iniciando Página
	oPrintPvt:StartPage()
	
	//Dados da Empresa
	oPrintPvt:Box(nLinCab, nColIni,    nLinCab + 075, nColMeio-3)
	oPrintPvt:Line(nLinCab+nTamFundo,   nColIni, nLinCab+nTamFundo,   nColMeio-3)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni+5, "Empresa:", oFontTit, 060, 05, nCorAzul, PAD_LEFT,  )
	nLinCab += 5
	oPrintPvt:SayBitmap(nLinCab+3, nColIni+5, cLogoEmp, 054, 054)
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "Empresa:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+95,  cEmpresa, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "CNPJ:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+87,  cEmpCnpj, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "Cidade:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+95,  cEmpCidade, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "CEP:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+85,  cEmpCep, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "Telefone:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+95,  cEmpTel, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "FAX:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+85,  cEmpFax, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "e-Mail:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+87,  cEmpEmail, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColIni+65,  "Home Page:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni+105,  cEmpSite, oFontCab, 120, 05, , PAD_LEFT,  )
	nLinCab += 7
	
	//Dados do cliente
	nLinCab := nLinCabOrig
	oPrintPvt:Box(nLinCab, nColMeio+3, nLinCab + 075, nColFin)
	oPrintPvt:Line(nLinCab+nTamFundo,   nColMeio+3, nLinCab+nTamFundo,   nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColMeio+8, "Cliente:", oFontTit, 060, 05, nCorAzul, PAD_LEFT,  )
	nLinCab += 5
	oPrintPvt:SayAlign(nLinCab, nColMeio+8,  "Código:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColMeio+34, SA1->A1_COD + "/"+SA1->A1_LOJA, oFontCab, 060, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8,  "Razão Social:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColMeio+52, SA1->A1_NOME, oFontCab, 200, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8,  "Nome Fantasia:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColMeio+58, SA1->A1_NREDUZ, oFontCab, 200, 05, , PAD_LEFT,  )
	nLinCab += 7
	cCGC := SA1->A1_CGC
	If lCNPJ
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, "@R 99.999.999/9999-99")), "-")
		oPrintPvt:SayAlign(nLinCab, nColMeio+08, "CNPJ:", oFontCabN, 060, 05, , PAD_LEFT,  )
	Else
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, "@R 999.999.999-99")), "-")
		oPrintPvt:SayAlign(nLinCab, nColMeio+08, "CPF:",  oFontCabN, 060, 05, , PAD_LEFT,  )
	EndIf
	oPrintPvt:SayAlign(nLinCab, nColMeio+32, cCGC,  oFontCab, 060, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8, "Endereço:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColMeio+40, Alltrim(SA1->A1_END)+" | "+SA1->A1_CEP, oFontCab, 200, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8, "Mun. Est.:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColMeio+40, Alltrim(SA1->A1_MUN)+" - "+SA1->A1_EST, oFontCab, 160, 05, , PAD_LEFT,  )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio+8,  "e-Mail:", oFontCabN, 060, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColMeio+30,  SA1->A1_EMAIL, oFontCab, 160, 05, , PAD_LEFT,  )
	nLinCab += 7
	
	//Tí­tulo
	nLinCab := nLinCabOrig + 080
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + (nTamFundo*3), nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni, "Adiantamento de Clientes", oFontTit, nColFin-nColIni, nTamFundo, nCorAzul, PAD_CENTER, )
	nLinOrigAux := nLinCab
	nLinCab += 8
	oPrintPvt:SayAlign(nLinCab, nColIni + 10,   "Recebemos de",   oFontDet, 050, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni + 57,   SA1->A1_NOME,   oFontDetN, 120, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColFin-210, "R$ "+Alltrim(Transform(nValorTot, cMascara)), oFontTit, 200, nTamFundo, , PAD_RIGHT, )
	nLinCab += 12
	oPrintPvt:SayAlign(nLinCab, nColIni + 10,   "A importância de",   oFontDet, 050, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, nColIni + 60,   Extenso(nValorTot),   oFontDetN, 240, 05, , PAD_LEFT,  )
	
	//Linha Separatório
	nLinCab := nLinOrigAux + 8 + (nTamFundo*2)
	oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
	
	//Cabeçalho com descrições das colunas
	nLinCab += 3
	oPrintPvt:SayAlign(nLinCab, POS_SEQ,   "Sequência",   oFontDetN, 050, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, POS_EMIS,  "Emissão",     oFontDetN, 050, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, POS_VENC,  "Vencimento",  oFontDetN, 050, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, POS_OBS,   "Observação",  oFontDetN, 200, 05, , PAD_LEFT,  )
	oPrintPvt:SayAlign(nLinCab, POS_VALOR, "Valor",       oFontDetN, 080, 05, , PAD_RIGHT, )
	
	//Atualizando a linha inicial do relatório
	nLinAtu := nLinCab + 8
Return

Static Function fImpRod()
	Local nLinRod:= nLinFin + 10
	Local cTexto := ''

	//Linha Separatória
	oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
	nLinRod += 3
	
	//Dados da Esquerda
	cTexto := "Adiantamento de Clientes    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+FunName()+" (zRAdianRec)     "+cUserName
	oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 250, 05, , PAD_LEFT, )
	
	//Direita
	cTexto := "Página "+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 05, , PAD_RIGHT, )
	
	//Finalizando a página e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

Static Function fLogoEmp()
	Local cGrpCompany	:= AllTrim(FWGrpCompany())
	Local cCodEmpGrp	:= AllTrim(FWCodEmp())
	Local cUnitGrp	:= AllTrim(FWUnitBusiness())
	Local cFilGrp		:= AllTrim(FWFilial())
	Local cLogo		:= ""
	Local cCamFim		:= GetTempPath()
	Local cStart		:= GetSrvProfString("Startpath","")

	//Se tiver filiais por grupo de empresas
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
		
	//Senão, será apenas, empresa + filial
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf
	
	//Pega a imagem
	cLogo := cStart + "DANFE" + cDescLogo + ".BMP"
	
	//Se o arquivo não existir, pega apenas o da empresa, desconsiderando a filial
	If !File(cLogo)
		cLogo	:= cStart + "DANFE" + cEmpAnt + ".BMP"
	EndIf
	
	//Copia para a temporária do s.o.
	CpyS2T(cLogo, cCamFim)
	cLogo := cCamFim + StrTran(cLogo, cStart, '')
	
	//Se o arquivo não existir na temporária, espera meio segundo para terminar a cópia
	If !File(cLogo)
		Sleep(500)
	EndIf
Return cLogo

//Baseado no artigo https://terminaldeinformacao.com/2015/02/05/data-extenso-advpl/
Static Function fDtExtenso(dDataAtual)
    Local cRetorno := ""
    Default dDataAtual := dDataBase

    cRetorno += cValToChar(Day(dDataAtual))
    cRetorno += " de "
    cRetorno += MesExtenso(dDataAtual)
    cRetorno += " de "
    cRetorno += cValToChar(Year(dDataAtual))
Return cRetorno

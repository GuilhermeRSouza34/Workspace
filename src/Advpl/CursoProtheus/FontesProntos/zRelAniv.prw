//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)

/*/{Protheus.doc} User Function zRelAniv
Função que gera o relatório de aniversariantes do dia
@type  Function
@version version
/*/

User Function zRelAniv()
    Local aArea
    Local lContinua   := .F.
    Private lJob      := .F.
    Private dDataRef  := Date()
    Private cDiretorio := "\x_aniversariantes\"

    //Se o ambiente não estiver em pé, sobe para usar de maneira automática
    If Select("SX2") == 0
        lJob := .T.
        lContinua := .T.
		RPCSetEnv("99", "01", "", "", "", "")
    EndIf
    aArea := GetArea()

    //Se não for modo automático, mostra uma pergunta
    If ! lJob
        lContinua := MsgYesNo("Deseja gerar o relatório de aniversariantes do dia?", "Atenção")
    EndIf

    //Se for continuar, faz a chamada para a realização das baixas
    If lContinua
        //Se a pasta não existir, cria
        If ! ExistDir(cDiretorio)
            MakeDir(cDiretorio)
        EndIf

        Processa({|| fMontaRel()}, "Processando...")
    EndIf
Return

Static Function fMontaRel()
    Local aArea        := GetArea()
	Local nAtual       := 0
    Local nTotal       := 0
    Local cQuerySRA    := ""
	Local cArquivo     := "zRelAniv_"+RetCodUsr()+"_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".pdf"
    Local cFotoFunc    := ""
    Local cPastaTemp   := GetTempPath()
	Private oPrintPvt
	Private cHoraEx    := Time()
	Private nPagAtu    := 1
	//Linhas e colunas
	Private nLinAtu    := 0
	Private nLinFin    := 820
	Private nColIni    := 010
	Private nColFin    := 580
	Private nEspCol    := (nColFin-(nColIni+150))/13
	Private nColMeio   := (nColFin-nColIni)/2
	//Declarando as fontes
	Private cNomeFont  := "Arial"
	Private oFontDet   := TFont():New(cNomeFont, 9, -15, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN  := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
	Private oFontTit   := TFont():New(cNomeFont, 9, -20, .T., .T., 5, .T., 5, .T., .F.)

    //Busca os funcionários que nasceram no mesmo dia de hoje
    cQuerySRA := " SELECT " + CRLF
    cQuerySRA += "     SRA.R_E_C_N_O_ AS SRAREC " + CRLF
    cQuerySRA += " FROM " + CRLF
    cQuerySRA += " 	" + RetSQLName("SRA") + " SRA " + CRLF
    cQuerySRA += " WHERE " + CRLF
    cQuerySRA += " 	RA_FILIAL = '" + FWxFilial("SRA") + "' " + CRLF
    cQuerySRA += " 	AND RA_SITFOLH NOT IN ('D', 'T') " + CRLF
    cQuerySRA += " 	AND SUBSTRING(RA_NASC, 5, 4) = '" + SubStr(dToS(dDataRef), 5) + "' " + CRLF
    cQuerySRA += " 	AND SRA.D_E_L_E_T_ = ' ' " + CRLF
    TCQuery cQuerySRA New Alias "QRY_SRA"

    //Se houver dados
    If ! QRY_SRA->(EoF())
		 //Criando o objeto de impressao
		If lJob
			oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., '', .T., .F., , ,.T., .T., ,.F.)
			oPrintPvt:cPathPDF := cDiretorio
		Else
			oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
			oPrintPvt:cPathPDF := cPastaTemp
		EndIf
		oPrintPvt:SetResolution(72)
		oPrintPvt:SetPortrait()
		oPrintPvt:SetPaperSize(DMPAPER_A4)
		oPrintPvt:SetMargin(0, 0, 0, 0)
	
        //Define o tamanho da régua
        Count To nTotal
        ProcRegua(nTotal)
        QRY_SRA->(DbGoTop())

        //Enquanto houver funcionários
        fImpCab()
        While ! QRY_SRA->(EoF())
            //Atualiza a régua
            nAtual++
            IncProc("Imprimindo funcionário " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

            //Se atingiu o limite, quebra de pagina
            fQuebra()

            //Posiciona no funcionário
            DbSelectArea("SRA")
            SRA->(DbGoTo(QRY_SRA->SRAREC))

            //Se o funcionário tiver foto
            If ! Empty(SRA->RA_BITMAP)
                //Define o nome da foto
                cFotoFunc := cPastaTemp + "matricula_" + SRA->RA_MAT + ".bmp"

                //Se a foto já existir na temporária do S.O., exclui
                If File(cFotoFunc)
                    FErase(cFotoFunc)
                EndIf

                //Faz a extração da imagem do Protheus
                RepExtract(Alltrim(SRA->RA_BITMAP), cFotoFunc)

                //Se deu certo de extrair a imagem, será impressa
                If File(cFotoFunc)
                    //A imagem do funcionário, tem aproximadamente 235 x 258 (largura x altura),
                    //  iremos manter a proporção (no caso dividimos por 4)
                    oPrintPvt:SayBitmap(nLinAtu, nColIni + 100, cFotoFunc, 58.75, 64.5)
                EndIf
            EndIf

            //Imprime agora os dados do funcionário
            oPrintPvt:SayAlign(nLinAtu, nColIni + 180, SRA->RA_NOME, oFontDetN,  nColFin - (nColIni + 180),  10, , PAD_LEFT,  )
            nLinAtu += 25
            oPrintPvt:SayAlign(nLinAtu, nColIni + 180, "Nasceu no dia " + dToC(SRA->RA_NASC), oFontDet,  nColFin - (nColIni + 180),  10, nCorAzul, PAD_LEFT,  )
            nLinAtu += 25
            oPrintPvt:SayAlign(nLinAtu, nColIni + 180, "Esta completando " + cValToChar(DateDiffYear(dDataRef, SRA->RA_NASC)) + " anos", oFontDet,  nColFin - (nColIni + 180),  10, nCorAzul, PAD_LEFT,  )
            nLinAtu += 25
            oPrintPvt:Line(nLinAtu-3, nColIni + 80, nLinAtu-3, nColFin - 80, nCorCinza)

            QRY_SRA->(DbSkip())
        EndDo
        fImpRod()

        //Se for via Job, irá disparar um e-Mail
        // zEnvMail disponível em https://terminaldeinformacao.com/2017/10/17/funcao-dispara-e-mail-varios-anexos-em-advpl/
        If lJob
            oPrintPvt:Print()

            aAnexos  := {}
            aAdd(aAnexos, cDiretorio + cArquivo)
            cPara	 := "teste@teste.com"
            cAssunto := "Aniversariantes do dia"
            cCorpo   := "Olá.<br>"
            cCorpo   += "Segue em anexo o relatório com os aniversariantes do dia. Desejamos a todos, muita saúde, paz e prosperidade.<br>"
            cCorpo   += "e-Mail gerado automaticamente no dia " + dToC(Date()) + " às " + Time() + "."
            u_zEnvMail(cPara, cAssunto, cCorpo, aAnexos)

        //Senão, se for manual, irá abrir o PDF
        Else
            oPrintPvt:Preview()
        EndIf

    //Senão, se não for job, mostra mensagem
    Else
        If ! lJob
            MsgStop("Não foi encontrado funcionário(s) aniversariante(s) na data de hoje!", "Atenção")
        EndIf
    EndIf
    QRY_SRA->(DbCloseArea())
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Funcao que imprime o cabecalho                               |
 *---------------------------------------------------------------------*/

Static Function fImpCab()
	Local cTexto   := ""
	Local nLinCab  := 015
	
	//Iniciando Pagina
	oPrintPvt:StartPage()
	
	//Cabecalho
	cTexto := "Aniversariantes - " + dToC(dDataRef)
	oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
	
	//Linha Separatoria
	nLinCab += 025
	oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
	
	//Atualizando a linha inicial do relatorio
	nLinAtu := nLinCab + 5
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Funcao que imprime o rodape                                  |
 *---------------------------------------------------------------------*/

Static Function fImpRod()
	Local nLinRod:= nLinFin
	Local cTexto := ''

	//Linha Separatoria
	oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
	nLinRod += 3
	
	//Dados da Esquerda
	cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (zRelAniv)     " + UsrRetName(RetCodUsr())
	oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
	
	//Direita
	cTexto := "Pagina "+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
	
	//Finalizando a pagina e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

Static Function fQuebra()
	If nLinAtu + 75 >= nLinFin-10
		fImpRod()
		fImpCab()
	EndIf
Return

//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

//Posi��es do Array
Static nPosCodig := 1
Static nPosPreco := 2

/*/{Protheus.doc} zImpDA1
Fun��o para importar os itens da tabela de pre�o
@author Atilio
@since 21/03/2017
@version 1.0
@type function
@obs O ideal � sempre fazer via MsExecAuto inclus�es, por�m como a tabela de pre�o, em alguns lugares pode passar de
    5.000 registros, foi feito utilizando RecLock para n�o perder a performance, o ideal � avaliar o cen�rio no cliente
/*/

User Function zImpDA1()
	Local aArea     := GetArea()
    Local aPergs    := {}
    Local cMsg      := ""
	Private cTabPrc := Space(TamSX3('DA0_CODTAB')[1])
	Private cArqOri := GetTempPath() + Space(100)

    //Mostra a mensagem de como deve ser realizada a importa��o
    cMsg := "Essa importa��o de registros para a tabela de pre�o (DA1), faz as seguintes manipula��es: " + CRLF
    cMsg += " +  Se n�o existir o produto na tabela de pre�o, ser� criado " + CRLF
    cMsg += " +  Se j� existir o produto, o pre�o de venda ser� alterado " + CRLF
    cMsg += " " + CRLF
    cMsg += "O Arquivo csv, deve ter apenas duas colunas, a de c�digo e a de pre�o, sendo que a primeira linha, pode ser descritiva apenas, por exemplo: " + CRLF
    cMsg += " " + CRLF
    cMsg += "C�digo;Pre�o; " + CRLF
    cMsg += "000001;10,50; " + CRLF
    cMsg += "000101;20,80; " + CRLF
    cMsg += "000201;15,99; " + CRLF
    cMsg += "000301;23,35; " + CRLF
    Aviso("Aten��o", cMsg, {"OK"}, 3)

	//Adiciona os par�metros que ser�o exibidos na pergunta
    aAdd(aPergs, {1, "Tabela de Pre�o", cTabPrc, "", "ExistCpo('DA0', &(ReadVar()))", "DA0", ".T.", 50, .T.})
    aAdd(aPergs, {6, "Arquivo CSV", cArqOri, "", "", "", 80, .T., "Arquivos com separadores (*.csv) |*.csv"})     
	
	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os par�metros", , , , , , , , , .F., .F.)
		cTabPrc := MV_PAR01
		cArqOri := Alltrim(MV_PAR02)
		
		Processa({|| fImporta() }, "Importando...")
	EndIf
	
	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Fun��o que importa os dados                                            |
 *-------------------------------------------------------------------------------*/

Static Function fImporta()
    Local cDirLog    := GetTempPath()
    Local cArqLog    := "zImpDA1_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
	Local cLog       := ""
	Local nTotLinhas := 0
	Local cLinAtu    := ""
	Local nLinhaAtu  := 1
	Local aLinha     := {}
	Local cUltItem   := StrTran(Space(TamSX3('DA1_ITEM')[01]), ' ', '0')
	Local cQryUlt    := ""
	Local cMasPreco  := PesqPict('DA1', 'DA1_PRCVEN')
    Local oArquivo
    Local aLinhas
    Local cCodProd   := ""
    Local nPrcProd   := 0
	
    //Abre as tabelas que ser�o usadas
	DbSelectArea('DA0')
	DA0->(DbSetOrder(1)) //DA0_FILIAL + DA0_CODTAB
	DA0->(DbGoTop())
	DbSelectArea('DA1')
	DA1->(DbSetOrder(1)) //DA1_FILIAL + DA1_CODTAB + DA1_CODPRO + DA1_INDLOT + DA1_ITEM
	DA1->(DbGoTop())
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
	SB1->(DbGoTop())

	//Se existir a tabela de pre�o
	If DA0->(DbSeek(FWxFilial('DA0') + cTabPrc))

		//Se o arquivo for CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'

            //Busca o �ltimo item da tabela de pre�o, para que ao incluir seja incrementado
			cQryUlt := " SELECT " + CRLF
			cQryUlt += " 	ISNULL(MAX(DA1_ITEM), '" + cUltItem + "') AS ULTIMO " + CRLF
			cQryUlt += " FROM " + CRLF
			cQryUlt += " 	" + RetSQLName('DA1') + " DA1 " + CRLF
			cQryUlt += " WHERE  " + CRLF
			cQryUlt += " 	DA1_FILIAL = '" + FWxFilial('DA1') + "' " + CRLF
			cQryUlt += " 	AND DA1_CODTAB = '" + cTabPrc + "' " + CRLF
			TCQuery cQryUlt New Alias "QRY_AUX"
			cUltItem := QRY_AUX->ULTIMO
			QRY_AUX->(DbCloseArea())
			
            //Definindo o arquivo a ser lido
            oArquivo := FWFileReader():New(cArqOri)
            
            //Se o arquivo pode ser aberto
            If (oArquivo:Open())

                //Se n�o for fim do arquivo
                If ! (oArquivo:EoF())

                    //Definindo o tamanho da r�gua
                    aLinhas := oArquivo:GetAllLines()
                    nTotLinhas := Len(aLinhas)
                    ProcRegua(nTotLinhas)
                    
                    //M�todo GoTop n�o funciona (dependendo da vers�o da LIB), deve fechar e abrir novamente o arquivo
                    oArquivo:Close()
                    oArquivo := FWFileReader():New(cArqOri)
                    oArquivo:Open()

                    //Iniciando controle de transa��o
                    Begin Transaction

                        //Enquanto tiver linhas
                        While (oArquivo:HasLine())

                            //Incrementa na tela a mensagem
                            nLinhaAtu++
                            IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                            
                            //Pegando a linha atual e transformando em array
                            cLinAtu := oArquivo:GetLine()
                            aLinha  := StrTokArr(cLinAtu, ";")
                            
                            //Se n�o for o cabe�alho (pesquisa pela palavra c�digo) e se o tamanho da linha tiver 2 colunas
                            If ! ("c�digo" $ Lower(cLinAtu)) .And. Len(aLinha) == 2
                                cCodProd := aLinha[nPosCodig]
                                nPrcProd := StrTran(aLinha[nPosPreco], '.', '')  //Tira os pontos
                                nPrcProd := StrTran(aLinha[nPosPreco], ',', '.') //Transforma a v�rgula em ponto
                                nPrcProd := Val(nPrcProd)                        //Converte de texto para valor num�rico
                                
                                //Se j� existir o produto, armazena no log
                                If DA1->(DbSeek(FWxFilial('DA1') + cTabPrc + cCodProd))
                                    //Somente se o pre�o for diferente
                                    If DA1->DA1_PRCVEN != nPrcProd
                                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto " + cCodProd + " atualizado, pre�o original: " + Alltrim(Transform(DA1->DA1_PRCVEN, cMasPreco)) + ", novo pre�o: " + Alltrim(Transform(nPrcProd, cMasPreco)) + ";" + CRLF
                                        
                                        RecLock("DA1", .F.)
                                            DA1_PRCVEN := nPrcProd
                                        DA1->(MsUnlock())

                                    Else
                                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto " + cCodProd + " n�o foi atualizado, o pre�o est� igual no Protheus e no CSV;" + CRLF
                                    EndIf
                                    
                                //Sen�o, importa o produto
                                Else
                                    If SB1->(DbSeek(FWxFilial('SB1') + cCodProd))
                                        cUltItem := Soma1(cUltItem)
                                        RecLock("DA1", .T.)
                                            DA1_FILIAL := FWxFilial('DA1')
                                            DA1_ITEM   := cUltItem
                                            DA1_CODTAB := cTabPrc
                                            DA1_CODPRO := cCodProd
                                            DA1_PRCVEN := nPrcProd
                                            DA1_VLRDES := 0
                                            DA1_PERDES := 0
                                            DA1_ATIVO  := '1'
                                            DA1_FRETE  := 0
                                            DA1_ESTADO := ''
                                            DA1_TPOPER := '4'
                                            DA1_QTDLOT := 999999.99
                                            DA1_INDLOT := ''
                                            DA1_MOEDA  := 0
                                            DA1_DATVIG := Date()
                                        DA1->(MsUnlock())
                                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto " + cCodProd + " incluido na tabela de pre�o, item - " + cUltItem + ";" + CRLF

                                    Else
                                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto " + cCodProd + " n�o encontrado;" + CRLF
                                    EndIf
                                EndIf
                            Else
                                cLog += "- Lin" + cValToChar(nLinhaAtu) + ", linha n�o processada;" + CRLF
                            EndIf
                            
                        EndDo
                    End Transaction
                
                    //Se tiver log, mostra ele
                    If ! Empty(cLog)
                        MemoWrite(cDirLog + cArqLog, cLog)
                        ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
                    EndIf

                Else
                    MsgStop("Arquivo n�o tem conte�do!", "Aten��o")
                EndIf

                //Fecha o arquivo
                oArquivo:Close()
            Else
                MsgStop("Arquivo n�o pode ser aberto!", "Aten��o")
            EndIf

		Else
			MsgStop("Arquivo inv�lido! Somente extens�o CSV pode ser importada", "Aten��o")
		EndIf
			
	Else
		MsgStop("Tabela de Pre�o n�o encontrada!", "Aten��o")
	EndIf
Return

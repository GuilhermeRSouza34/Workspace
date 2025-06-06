//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function AEXCL002
Importação de CSV para popular a tela de transferência múltipla
@type  Function
@author Atilio
@since 18/10/2023
@version 1.0
@type function
/*/

User Function AEXCL002()
	Local aArea := FWGetArea()
	Local cDirIni := GetTempPath()
	Local cTipArq := 'Arquivos com separações (*.csv) | Arquivos texto (*.txt) | Todas extensões (*.*)'
	Local cTitulo := 'Seleção de Arquivos para Processamento'
	Local lSalvar := .F.
	Local cArqSel := ''
 
	//Se não estiver sendo executado via job
	If ! IsBlind()
 
	    //Chama a função para buscar arquivos
	    cArqSel := tFileDialog(;
	        cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
	        cTitulo,;  // Título da Janela para seleção dos arquivos
	        ,;         // Compatibilidade
	        cDirIni,;  // Diretório inicial da busca de arquivos
	        lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
	        ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
	    )

	    //Se tiver o arquivo selecionado e ele existir
	    If ! Empty(cArqSel) .And. File(cArqSel)
	        Processa({|| fImporta(cArqSel) }, 'Importando...')
	    EndIf
	EndIf
	
	FWRestArea(aArea)
Return


Static Function fImporta(cArqSel)
    Local aAreaSB1   := SB1->(FWGetArea())
    Local aAreaNNR   := NNR->(FWGetArea())
	Local nTotLinhas := 0
	Local cLinAtu    := ''
	Local nLinhaAtu  := 0
	Local aLinhaTxt  := {}
	Local oArquivo
	Local lIgnor01   := FWAlertYesNo('Deseja ignorar a linha 1 do arquivo?', 'Ignorar?')
    Local cSeparador := ';'
    Local cFilSB1    := FWxFilial("SB1")
    Local cFilNNR    := FWxFilial("NNR")
    //Variáveis usadas para manipular a tela
    local nPosProdut := GdFieldPos('D3_COD')
	Local nColuna
	Local nLinha

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
    DbSelectArea("NNR")
    NNR->(DbSetOrder(1)) // NNR_FILIAL + NNR_CODIGO

	//Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqSel)

	//Se o arquivo pode ser aberto
	If (oArquivo:Open())

		//Se não for fim do arquivo
		If ! (oArquivo:EoF())

			//Definindo o tamanho da régua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSel)
			oArquivo:Open()

            //Enquanto tiver linhas
            While (oArquivo:HasLine())

                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc('Analisando linha ' + cValToChar(nLinhaAtu) + ' de ' + cValToChar(nTotLinhas) + '...')

                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinhaTxt  := Separa(cLinAtu, cSeparador)

                //Se estiver configurado para pular a linha 1, e for a linha 1
                If lIgnor01 .And. nLinhaAtu == 1
                    Loop

                //Se houver posições no array
                ElseIf Len(aLinhaTxt) > 0 
                    
                    //Pega o código do produto e os armazéns
					cCodProd := AvKey(aLinhaTxt[1], "D3_COD")
					cLocOrig := AvKey(aLinhaTxt[3], "D3_LOCAL")
					cLocDest := AvKey(aLinhaTxt[4], "D3_LOCAL")

                    //Transformando de caractere para numérico (exemplo '1.234,56' para 1234.56)
                    aLinhaTxt[2] := StrTran(aLinhaTxt[2], '.', '')
                    aLinhaTxt[2] := StrTran(aLinhaTxt[2], ',', '.')
                    aLinhaTxt[2] := Val(aLinhaTxt[2])
					nQtdTransf   := aLinhaTxt[2]
                    
                    //Somente se conseguir posicionar no produto e nos armazéns de origem e destino
                    If SB1->(MsSeek(cFilSB1 + cCodProd)) .And. NNR->(MsSeek(cFilNNR + cLocOrig)) .And. NNR->(MsSeek(cFilNNR + cLocDest))

						//Se o Local de Origem ou Destino nao existe para o Produto entao cria
						CriaSB2(cCodProd, cLocOrig)
						CriaSB2(cCodProd, cLocDest)
					
						//Validacao do produto origem ter saldo suficiente para atender a transferencia
						If fVldQtd(cCodProd, cLocOrig, nQtdTransf)

                            //Se a última linha, esta preenchido o código do produto
							If ! Empty(aCols[Len(aCols)][nPosProdut])

								//Adiciona nova linha no Array
								aAdd(aCols, Array(Len(aHeader) + 1))
							EndIf

                            //Variavel de Controle se já preencheu o local de origem, e pega o número da linha atual
							lJaFoiOrig := .F.
							nLinha := Len(aCols)

                            //Percorre as colunas da tela
							For nColuna := 1 to Len(aHeader)

                                //Pega o nome do campo atual da grid
                                cCampoAtu := Alltrim(aHeader[nColuna][2])

                                //Se for o campo de código do produto
                                If cCampoAtu == "D3_COD"
									aCols[nLinha][nColuna] := cCodProd

                                //Se for a descrição do produto
                                ElseIf cCampoAtu == "D3_DESCRI"
									aCols[nLinha][nColuna] := SB1->B1_DESC

                                //Se for a unidade de medida
                                ElseIf cCampoAtu == "D3_UM"
									aCols[nLinha][nColuna] := SB1->B1_UM

                                //Se for o Armazém, e ainda não foi a Origem, será o de origem (o primeiro na grid, devido a ter o mesmo nome)
                                ElseIf cCampoAtu == "D3_LOCAL" .And. ! lJaFoiOrig
									aCols[nLinha][nColuna] := cLocOrig
									lJaFoiOrig := .T.

                                //Se for o Armazém, e já tiver sido o da Origem, então agora será o Destino
                                ElseIf cCampoAtu == "D3_LOCAL" .and. lJaFoiOrig 
									aCols[nLinha][nColuna] := cLocDest
									
                                //Se for a quantidade a ser transferida
                                ElseIf cCampoAtu == "D3_QUANT" 
									aCols[nLinha][nColuna] := nQtdTransf

                                //Se for o campo interno da grid de alias
                                ElseIf cCampoAtu == "D3_ALI_WT"
                                    aCols[nLinha][nColuna] := "SD3"

                                //Se for o campo interno da grid de recno
                                ElseIf cCampoAtu == "D3_REC_WT"
                                    aCols[nLinha][nColuna] := 0

                                //Senão, se for os outros campo, inicializa eles
                                Else
									aCols[nLinha][nColuna] := CriaVar(cCampoAtu, .F.)
								EndIf
							Next
						EndIf
                    EndIf

                EndIf

            EndDo

		Else
			FWAlertError('Arquivo não tem conteúdo!', 'Atenção')
		EndIf

		//Fecha o arquivo
		oArquivo:Close()
	Else
		FWAlertError('Arquivo não pode ser aberto!', 'Atenção')
	EndIf

    FWRestArea(aAreaNNR)
    FWRestArea(aAreaSB1)
Return

Static Function fVldQtd(cCodigo, cLocal, nQuantidade)
	Local aArea := GetArea()
	Local cQryQtd := ""
	Local lContinua := .T.

	//Buscando o saldo da tabela
	cQryQtd := " SELECT " + CRLF
	cQryQtd += " 	B2_QATU " + CRLF
	cQryQtd += " FROM " + CRLF
	cQryQtd += " 	" + RetSQLName('SB2') + " SB2 " + CRLF
	cQryQtd += " WHERE " + CRLF
	cQryQtd += " 	B2_FILIAL = '" + FWxFilial('SB2') + "' " + CRLF
	cQryQtd += " 	AND B2_COD = '" + cCodigo + "' " + CRLF
	cQryQtd += " 	AND B2_LOCAL = '" + cLocal + "' " + CRLF
	cQryQtd += " 	AND B2_QATU >= " + cValToChar(nQuantidade) + " " + CRLF
	cQryQtd += " 	AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	PLSQuery(cQryQtd, "QRY_QTD")

	//Se nao houver dados, retorna falso
	If QRY_QTD->(EoF())
		lContinua := .F.
	EndIf
	QRY_QTD->(DbCloseArea())

	RestArea(aArea)
Return lContinua

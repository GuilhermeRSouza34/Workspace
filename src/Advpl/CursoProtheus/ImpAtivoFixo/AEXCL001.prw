//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function AEXCL001
Importação de dados para o Ativo Fixo
@author Atilio
@since 12/11/2022
@version 1.0
@type function
/*/

User Function AEXCL001()
	Local aArea := FWGetArea()
	Local cDirIni := GetTempPath()
	Local cTipArq := 'Arquivos com separações (*.csv) | Arquivos texto (*.txt)'
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
	
/*/{Protheus.doc} fImporta
Função que processa o arquivo e realiza a importação para o sistema
@author Atilio
@since 12/11/2022
@version 1.0
@type function
/*/

Static Function fImporta(cArqSel)
	Local cDirTmp    := GetTempPath()
	Local cArqLog    := 'importacao_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
	Local nTotLinhas := 0
	Local cLinAtu    := ''
	Local nLinhaAtu  := 0
	Local aLinha     := {}
	Local oArquivo
	Local cPastaErro := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local aLogErro   := {}
	Local nLinhaErro := 0
	Local cLog       := ''
    //Variáveis usadas para montar os dados do ExecAuto
    Local cSeparador := ';'
    Local aInfCampos := {}
    Local aCab       := {}
    Local aItens     := {}
    Local aItemAtu   := {}
    Local cCampo     := ""
    Local cTabela    := ""
    Local cTipo      := ""
    Local nPosicao   := 0
    Local xConteudo  := Nil
	//Variáveis para log do ExecAuto
	Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	
	//Abre as tabelas que serão usadas
	DbSelectArea('SN1')
	SN1->(DbSetOrder(1)) // N1_FILIAL + N1_CBASE + N1_ITEM
	DbSelectArea('SN3')
	SN3->(DbSetOrder(1)) // N3_FILIAL + N3_CBASE + N3_ITEM + N3_TIPO + N3_BAIXA + N3_SEQ

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
                aLinha  := Separa(cLinAtu, cSeparador)

                //Se houver posições no array
                If Len(aLinha) > 0
                    //Se for a primeira linha, é as informações dos campos
                    If nLinhaAtu == 1

                        //Percorre os campos digitados na linha 1, e adiciona num array
                        For nPosicao := 1 To Len(aLinha)
                            cCampo  := aLinha[nPosicao]
                            cTabela := AliasCpo(cCampo)
                            cTipo   := GetSX3Cache(cCampo, "X3_TIPO")
                            aAdd(aInfCampos, {cCampo, cTabela, cTipo})
                        Next

                    //Senão, ai monta a importação dos dados
                    Else
                        aCab     := {}
                        aItens   := {}
                        aItemAtu := {}
                        For nPosicao := 1 To Len(aLinha)
                            xConteudo := aLinha[nPosicao]

                            //Somente se for uma posição válida
                            If nPosicao <= Len(aInfCampos)

                                //Se for do tipo Data
                                If aInfCampos[nPosicao][3] == "D"
                                    //Se tiver barra no texto, irá converter de "DD/MM/YYYY"
                                    If "/" $ xConteudo
                                        xConteudo := cToD(xConteudo)

                                    //Se não tiver barra, irá converter de "YYYYMMDD"
                                    Else
                                        xConteudo := sToD(xConteudo)
                                    EndIf

                                //Senão, se for numérico, tira caracteres que impactem a conversão
                                ElseIf aInfCampos[nPosicao][3] == "N"
                                    xConteudo := StrTran(xConteudo, ".", "")
                                    xConteudo := StrTran(xConteudo, ",", ".")
                                    xConteudo := Val(xConteudo)
                                EndIf

                                //Se for o cabeçalho
                                If aInfCampos[nPosicao][2] == "SN1"
                                    aAdd(aCab, {aInfCampos[nPosicao][1], xConteudo, Nil})

                                //Se for o detalhe
                                ElseIf aInfCampos[nPosicao][2] == "SN3"
                                    aAdd(aItemAtu, {aInfCampos[nPosicao][1], xConteudo, Nil})
                                EndIf
                            EndIf

                        Next
                        aAdd(aItens, aClone(aItemAtu))

                        //Aciona a inclusão do registro
                        lMsErroAuto := .F.
                        MSExecAuto({|x, y, z| ATFA012(x, y, z)}, aCab, aItens, 3)

                        //Se houve erro, gera o log
                        If lMsErroAuto
                            cPastaErro := '\x_logs\'
                            cNomeErro  := 'erro_atf_lin_' + cValToChar(nLinhaAtu) + "_" + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'

                            //Se a pasta de erro não existir, cria ela
                            If ! ExistDir(cPastaErro)
                                MakeDir(cPastaErro)
                            EndIf

                            //Pegando log do ExecAuto, percorrendo e incrementando o texto
                            cTextoErro := ""
                            cTextoErro += "Linha " + cValToChar(nLinhaAtu) + CRLF
                            cTextoErro += "Conteúdo da linha: '" + cLinAtu + "'" + CRLF
                            cTextoErro += "--" + CRLF + CRLF
                            aLogErro := GetAutoGRLog()
                            For nLinhaErro := 1 To Len(aLogErro)
                                cTextoErro += aLogErro[nLinhaErro] + CRLF
                            Next

                            //Criando o arquivo txt e incrementa o log
                            MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                            cLog += '- Falha ao incluir registro, linha [' + cValToChar(nLinhaAtu) + '], veja o arquivo de log em ' + cPastaErro + cNomeErro + CRLF
                        Else
                            cLog += '+ Sucesso no Execauto na linha ' + cValToChar(nLinhaAtu) + ';' + CRLF
                        EndIf
                    EndIf

                EndIf

            EndDo

			//Se tiver log, mostra ele
			If ! Empty(cLog)
				MemoWrite(cDirTmp + cArqLog, cLog)
				ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
			EndIf

		Else
			FWAlertError('Arquivo não tem conteúdo!', 'Atenção')
		EndIf

		//Fecha o arquivo
		oArquivo:Close()
	Else
		FWAlertError('Arquivo não pode ser aberto!', 'Atenção')
	EndIf

Return

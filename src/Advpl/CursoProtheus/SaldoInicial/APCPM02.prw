//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function APCPM02
Função que aciona a criação de saldo inicial na SB9
@type  Function
@author Atilio
@since 01/10/2024
/*/

User Function APCPM02()
    Local aArea := FWGetArea()
    Local aPergs   := {}
    Local cProdDe  := Space(TamSX3("B1_COD")[01])
    Local cProdAt  := StrTran(cProdDe, " ", "Z")
	Local cArmazem := Space(TamSX3("B1_LOCPAD")[01])
    
    //Monta o array dos parâmetros
    aAdd(aPergs, {1, "Produto De",  cProdDe,  "", ".T.", "SB1", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Produto Até", cProdAt,  "", ".T.", "SB1", ".T.", 80,  .T.})
    aAdd(aPergs, {2, "Bloqueados",  2, {"1=Sim, somente bloqueados", "2=Não, somente ativos", "3=Ambos"}, 110, ".T.", .F.})
	aAdd(aPergs, {1, "Armazém",     cArmazem, "", ".T.", "NNR", ".T.", 40,  .T.})
    
    //Se a pergunta for confirmada
    If ParamBox(aPergs, "Informe os parâmetros", /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
        MV_PAR03 := Val(cValToChar(MV_PAR03))
        Processa({|| fAnalisaDados()})
    EndIf

    FWRestArea(aArea)
Return

Static Function fAnalisaDados()
    Local aArea      := FWGetArea()
    Local cQuery     := ""
    Local nTotal     := 0
    Local nAtual     := 0
    Local cMsgLog    := ""
    Local lBloqueado := .F.
    Local cFiliaisProc := SuperGetMV("MV_X_SB9FI", .F., "0101;0102;")
    Local aFiliaisProc := StrTokArr(cFiliaisProc, ";")
    Local nFilAtu      := 0
    Local cFilBkp      := cFilAnt
	Local cArmazem     := MV_PAR04

    //Percorre as filiais
    For nFilAtu := 1 To Len(aFiliaisProc)

        //Se a filial atual for diferente da logada, troca ela em memória
        If cFilAnt != aFiliaisProc[nFilAtu]
            cFilAnt := aFiliaisProc[nFilAtu]
            cNumEmp := cEmpAnt + cFilAnt
            OpenFile(cNumEmp)
        EndIf

        //Busca todos os produtos conforme parâmetros informados
        cQuery := " SELECT " + CRLF
        cQuery += "     SB1.R_E_C_N_O_ AS SB1REC " + CRLF
        cQuery += " FROM " + CRLF
        cQuery += "     " + RetSQLName("SB1") + " SB1 " + CRLF
        cQuery += " WHERE " + CRLF
        cQuery += "     B1_FILIAL = '" + FWxFilial("SB1") + "' " + CRLF
        cQuery += "     AND B1_COD >= '" + MV_PAR01 + "' " + CRLF
        cQuery += "     AND B1_COD <= '" + MV_PAR02 + "' " + CRLF
        If MV_PAR03 == 1
            cQuery += "     AND B1_MSBLQL = '1' " + CRLF
        ElseIf MV_PAR03 == 2
            cQuery += "     AND B1_MSBLQL != '1' " + CRLF
        EndIf
        cQuery += "     AND SB1.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "     AND B1_COD NOT IN ( " + CRLF
        cQuery += "         SELECT B9_COD " + CRLF
        cQuery += "         FROM " + RetSQLName("SB9") + " SB9 " + CRLF
        cQuery += "         WHERE B9_FILIAL = '" + FWxFilial("SB9") + "' " + CRLF
		cQuery += "         AND B9_LOCAL = '" + cArmazem + "' " + CRLF
        cQuery += "         AND SB9.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "     ) " + CRLF
        cQuery += " ORDER BY " + CRLF
        cQuery += "     B1_COD ASC " + CRLF
        TCQuery cQuery New Alias "QRY_SB1"

        //Se houver dados
        If ! QRY_SB1->(EoF())

            //Define o tamanho da régua
            nAtual := 0
            Count To nTotal
            ProcRegua(nTotal)
            QRY_SB1->(DbGoTop())

            //Enquanto houver dados da query a serem processados
            While ! QRY_SB1->(EoF())
                //Posiciona no produto
                DbSelectArea("SB1")
                SB1->(DbGoTo(QRY_SB1->SB1REC))

                //Incrementa a régua
                nAtual++
                IncProc("[" + cFilAnt + "] Processando o produto " + Alltrim(SB1->B1_COD) + " (registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

                //Se o produto esta bloqueado, coloca ele como normal
                If SB1->B1_MSBLQL == "1"
                    lBloqueado := .T.
                    cMsgLog += "! Produto '" + SB1->B1_COD + "' estava bloqueado. Haverá alteração para desbloquear antes de criar o saldo inicial." + CRLF

                    //Atualiza o registro manualmente
                    RecLock("SB1", .F.)
                        SB1->B1_MSBLQL := "2"
                    SB1->(MsUnlock())
                EndIf

                //Aciona o sincronismo para criar a SB9
                cMsgLog += u_APCPM02b(SB1->B1_COD, cArmazem, {cFilAnt})

                //Se o produto foi bloqueado, desbloqueia ele
                If lBloqueado
                    lBloqueado := .F.
                    cMsgLog += "! Produto '" + SB1->B1_COD + "' voltando para o bloqueio original" + CRLF

                    //Atualiza o registro manualmente
                    RecLock("SB1", .F.)
                        SB1->B1_MSBLQL := "1"
                    SB1->(MsUnlock())
                EndIf

                QRY_SB1->(DbSkip())
            EndDo

        Else
            cMsgLog += "Não foi encontrado informações para a filial '" + cFilAnt + "'!" + CRLF
        EndIf
        QRY_SB1->(DbCloseArea())
    Next

    //Exibe o log de término
    ShowLog("Abaixo as informações dos produtos processados: " + CRLF + CRLF + cMsgLog)

    //Se a filial de backup for diferente da que esta saindo da rotina, volta o backup
    If cFilAnt != cFilBkp
        cFilAnt := cFilBkp
        cNumEmp := cEmpAnt + cFilAnt
        OpenFile(cNumEmp)
    EndIf

    FWRestArea(aArea)
Return

/*/{Protheus.doc} User Function APCPM02b
Função que vai criar a SB9 nas filiais conforme o parâmetro MV_X_SB9FI
@type  Function
@author Atilio
@since 01/10/2024
@version version
@param cCodProd, Caractere, Código do Produto
@param cLocPadrao, Caractere, Armazém padrão do Produto
@param aFiliaisProc, Caractere, Array com as filiais a serem processadas
@return cObservacoes, Caractere, Retorna as observações dos ExecAutos de inclusão na SB9
@example
u_APCPM02b("F0001", "01")
/*/

User Function APCPM02b(cCodProd, cLocPadrao, aFiliaisProc)
    Local aArea        := FWGetArea()
    Local cObservacoes := ""
    Local cFiliaisProc  := SuperGetMV("MV_X_SB9FI", .F., "0101;0102;")
    Local nFilAtu      := 0
    Local cFilBkp      := cFilAnt
    //Variáveis para gravação do Log na Protheus Data
    Local cPastaErro := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local aLogErro   := {}
    Local nLinhaErro := 0
    //Parâmetros recebidos
    Default cCodProd := ""
    Default cLocPadrao := ""
    Default aFiliaisProc  := StrTokArr(cFiliaisProc, ";")
	//Variáveis do ExecAuto
	Private aDados         := {}
	Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

    //Somente se veio código e armazém padrão
    If ! Empty(cCodProd) .And. ! Empty(cLocPadrao)

        //Se a pasta de logs não existir, cria ela
        If ! ExistDir(cPastaErro)
            MakeDir(cPastaErro)
        EndIf

        //Deixa os parâmetros com o mesmo tamanho de campo do dicionário da SB9
        cCodProd   := AvKey(cCodProd, "B9_COD")
        cLocPadrao := AvKey(cLocPadrao, "B9_LOCAL")

        //Abre as tabelas que vão ser usadas na replicação
        DbSelectArea("SB9")
        SB9->(DbSetOrder(1)) // B9_FILIAL + B9_COD + B9_LOCAL + DTOS(B9_DATA)
        DbSelectArea("NNR")
        NNR->(DbSetOrder(1)) // NNR_FILIAL + NNR_CODIGO

        //Percorre as filiais
        For nFilAtu := 1 To Len(aFiliaisProc)
            //Se tiver vazio, pula a posição do array
            If Empty(aFiliaisProc[nFilAtu])
                Loop
            EndIf

            //Se a filial atual for diferente da logada, troca ela em memória
            If cFilAnt != aFiliaisProc[nFilAtu]
                cFilAnt := aFiliaisProc[nFilAtu]
                cNumEmp := cEmpAnt + cFilAnt
                OpenFile(cNumEmp)
            EndIf

            //Se o armazém não existir nessa filial ainda
            If ! NNR->(MsSeek(FWxFilial("NNR") + cLocPadrao))
                //Adiciona os campos
                aDados := {}
                aAdd(aDados, {"NNR_CODIGO", cLocPadrao,    Nil})
                aAdd(aDados, {"NNR_DESCRI", "Armazém",     Nil})

                //Chama a inclusão
                lMsErroAuto := .F.
                MsExecAuto({|x, y| AGRA045(x, y)}, aDados, 3)

                //Se houve o erro
                If lMsErroAuto

                    //Pegando log do ExecAuto, percorrendo e incrementando o texto
                    aLogErro := GetAutoGRLog()
                    cTextoErro := ''
                    For nLinhaErro := 1 To Len(aLogErro)
                        cTextoErro += aLogErro[nLinhaErro] + CRLF
                    Next

                    //Criando o arquivo txt com o log
                    cNomeErro  := 'erro_nnr_' + cLocPadrao + '_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'
                    MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                    cObservacoes += "- Falha ao incluir o armazém '" + cLocPadrao + "' na filial '" + cFilAnt + "', veja os detalhes do erro nesse arquivo: " + cPastaErro + cNomeErro + CRLF
                Else
                    cObservacoes += "+ Não existia o armazém '" + cLocPadrao + "', na filial '" + cFilAnt + "', então foi criado!" + CRLF
                EndIf
            EndIf

            //Se o indicar não existir nessa filial
            If ! SB9->(MsSeek(FWxFilial("SB9") + cCodProd + cLocPadrao))
                //Adiciona os campos
                aDados := {}
                aAdd(aDados, {"B9_COD",    cCodProd,    Nil})
                aAdd(aDados, {"B9_LOCAL", cLocPadrao,  Nil})
                aAdd(aDados, {"B9_QINI",   0,           Nil})

                //Chama a inclusão
                lMsErroAuto := .F.
                MsExecAuto({|x, y| MATA220(x, y)}, aDados, 3)

                //Se houve o erro
                If lMsErroAuto

                    //Pegando log do ExecAuto, percorrendo e incrementando o texto
                    aLogErro := GetAutoGRLog()
                    cTextoErro := ''
                    For nLinhaErro := 1 To Len(aLogErro)
                        cTextoErro += aLogErro[nLinhaErro] + CRLF
                    Next

                    //Criando o arquivo txt com o log
                    cNomeErro  := 'erro_SB9_' + cCodProd + '_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'
                    MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                    cObservacoes += "- Falha ao incluir o saldo inicial do produto '" + cCodProd + "' na filial '" + cFilAnt + "', veja os detalhes do erro nesse arquivo: " + cPastaErro + cNomeErro + CRLF
                Else
                    cObservacoes += "+ Não existia o saldo inicial do produto '" + cCodProd + "', na filial '" + cFilAnt + "', então foi criado!" + CRLF
                EndIf

            Else
                cObservacoes += "# saldo inicial do produto '" + cCodProd + "' já tem cadastro na filial '" + cFilAnt + "'!" + CRLF
            EndIf

        Next

        //Se a filial de backup for diferente da que esta saindo da rotina, volta o backup
        If cFilAnt != cFilBkp
            cFilAnt := cFilBkp
            cNumEmp := cEmpAnt + cFilAnt
            OpenFile(cNumEmp)
        EndIf

    Else
        cObservacoes := "Código e/ou Armazém em Branco!" + CRLF
    EndIf

    FWRestArea(aArea)
Return cObservacoes

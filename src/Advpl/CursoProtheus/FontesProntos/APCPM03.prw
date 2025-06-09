//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function APCPM03
Fun��o que aciona o sincronismo para cria��o da SBZ (essa fun��o � para ser adicionada no menu)
@type  Function
@author Atilio
@since 14/09/2024
/*/

User Function APCPM03()
    Local aArea := FWGetArea()
    Local aPergs   := {}
    Local cProdDe  := Space(TamSX3("B1_COD")[01])
    Local cProdAt  := StrTran(cProdDe, " ", "Z")
    
    //Monta o array dos par�metros
    aAdd(aPergs, {1, "Produto De",  cProdDe,  "", ".T.", "SB1", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Produto At�", cProdAt,  "", ".T.", "SB1", ".T.", 80,  .T.})
    aAdd(aPergs, {2, "Bloqueados",  2, {"1=Sim, somente bloqueados", "2=N�o, somente ativos", "3=Ambos"}, 110, ".T.", .F.})
    
    //Se a pergunta for confirmada
    If ParamBox(aPergs, "Informe os par�metros", /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
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
    Local cFiliaisSBZ  := SuperGetMV("MV_X_SBZFI", .F., "0101;0102;")
    Local aFiliaisSBZ  := StrTokArr(cFiliaisSBZ, ";")
    Local nFilAtu      := 0
    Local cFilBkp      := cFilAnt

    //Percorre as filiais
    For nFilAtu := 1 To Len(aFiliaisSBZ)

        //Se a filial atual for diferente da logada, troca ela em mem�ria
        If cFilAnt != aFiliaisSBZ[nFilAtu]
            cFilAnt := aFiliaisSBZ[nFilAtu]
            cNumEmp := cEmpAnt + cFilAnt
            OpenFile(cNumEmp)
        EndIf

        //Busca todos os produtos conforme par�metros informados
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
        cQuery += "     AND (" + CRLF
        cQuery += "         SELECT COUNT(BZ_COD) FROM " + RetSQLName("SBZ") + " SBZ WHERE BZ_FILIAL = '" + FWxFilial("SBZ") + "' AND BZ_COD = B1_COD AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "     ) = 0 " + CRLF
        cQuery += " ORDER BY " + CRLF
        cQuery += "     B1_COD ASC " + CRLF
        TCQuery cQuery New Alias "QRY_SB1"

        //Se houver dados
        If ! QRY_SB1->(EoF())

            //Define o tamanho da r�gua
            nAtual := 0
            Count To nTotal
            ProcRegua(nTotal)
            QRY_SB1->(DbGoTop())

            //Enquanto houver dados da query a serem processados
            While ! QRY_SB1->(EoF())
                //Posiciona no produto
                DbSelectArea("SB1")
                SB1->(DbGoTo(QRY_SB1->SB1REC))

                //Incrementa a r�gua
                nAtual++
                IncProc("[" + cFilAnt + "] Processando o produto " + Alltrim(SB1->B1_COD) + " (registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

                //Se o produto esta bloqueado, coloca ele como normal
                If SB1->B1_MSBLQL == "1"
                    lBloqueado := .T.
                    cMsgLog += "! Produto '" + SB1->B1_COD + "' estava bloqueado. Haver� altera��o para desbloquear antes de criar os indicadores." + CRLF

                    //Atualiza o registro manualmente
                    RecLock("SB1", .F.)
                        SB1->B1_MSBLQL := "2"
                    SB1->(MsUnlock())
                EndIf

                //Aciona o sincronismo para criar a SBZ
                cMsgLog += u_APCPM03b(SB1->B1_COD, SB1->B1_LOCPAD, {cFilAnt})

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
            cMsgLog += "N�o foi encontrado informa��es para a filial '" + cFilAnt + "'!" + CRLF
        EndIf
        QRY_SB1->(DbCloseArea())
    Next

    //Exibe o log de t�rmino
    ShowLog("Abaixo as informa��es dos produtos processados: " + CRLF + CRLF + cMsgLog)

    //Se a filial de backup for diferente da que esta saindo da rotina, volta o backup
    If cFilAnt != cFilBkp
        cFilAnt := cFilBkp
        cNumEmp := cEmpAnt + cFilAnt
        OpenFile(cNumEmp)
    EndIf

    FWRestArea(aArea)
Return

/*/{Protheus.doc} User Function APCPM03b
Fun��o que vai criar a SBZ nas filiais conforme o par�metro MV_X_SBZFI
@type  Function
@author Atilio
@since 14/09/2024
@version version
@param cCodProd, Caractere, C�digo do Produto
@param cLocPadrao, Caractere, Armaz�m padr�o do Produto
@param aFiliaisSBZ, Caractere, Array com as filiais a serem processadas
@return cObservacoes, Caractere, Retorna as observa��es dos ExecAutos de inclus�o na SBZ
@example
u_APCPM03b("F0001", "Produto de Teste")
/*/

User Function APCPM03b(cCodProd, cLocPadrao, aFiliaisSBZ)
    Local aArea        := FWGetArea()
    Local cObservacoes := ""
    Local cFiliaisSBZ  := SuperGetMV("MV_X_SBZFI", .F., "0101;0102;")
    Local nFilAtu      := 0
    Local cFilBkp      := cFilAnt
    //Vari�veis para grava��o do Log na Protheus Data
    Local cPastaErro := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local aLogErro   := {}
    Local nLinhaErro := 0
    //Par�metros recebidos
    Default cCodProd := ""
    Default cLocPadrao := ""
    Default aFiliaisSBZ  := StrTokArr(cFiliaisSBZ, ";")
	//Vari�veis do ExecAuto
	Private aDados         := {}
	Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

    //Somente se veio c�digo e armaz�m padr�o
    If ! Empty(cCodProd) .And. ! Empty(cLocPadrao)

        //Se a pasta de logs n�o existir, cria ela
        If ! ExistDir(cPastaErro)
            MakeDir(cPastaErro)
        EndIf

        //Deixa os par�metros com o mesmo tamanho de campo do dicion�rio da SBZ
        cCodProd   := AvKey(cCodProd, "BZ_COD")
        cLocPadrao := AvKey(cLocPadrao, "BZ_LOCPAD")

        //Abre as tabelas que v�o ser usadas na replica��o
        DbSelectArea("SBZ")
        SBZ->(DbSetOrder(1)) // BZ_FILIAL + BZ_COD
        DbSelectArea("NNR")
        NNR->(DbSetOrder(1)) // NNR_FILIAL + NNR_CODIGO

        //Percorre as filiais
        For nFilAtu := 1 To Len(aFiliaisSBZ)
            //Se tiver vazio, pula a posi��o do array
            If Empty(aFiliaisSBZ[nFilAtu])
                Loop
            EndIf

            //Se a filial atual for diferente da logada, troca ela em mem�ria
            If cFilAnt != aFiliaisSBZ[nFilAtu]
                cFilAnt := aFiliaisSBZ[nFilAtu]
                cNumEmp := cEmpAnt + cFilAnt
                OpenFile(cNumEmp)
            EndIf

            //Se o armaz�m n�o existir nessa filial ainda
            If ! NNR->(MsSeek(FWxFilial("NNR") + cLocPadrao))
                //Adiciona os campos
                aDados := {}
                aAdd(aDados, {"NNR_CODIGO", cLocPadrao,    Nil})
                aAdd(aDados, {"NNR_DESCRI", "Armaz�m",     Nil})

                //Chama a inclus�o
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
                    cObservacoes += "- Falha ao incluir o armaz�m '" + cLocPadrao + "' na filial '" + cFilAnt + "', veja os detalhes do erro nesse arquivo: " + cPastaErro + cNomeErro + CRLF
                Else
                    cObservacoes += "+ N�o existia o armaz�m '" + cLocPadrao + "', na filial '" + cFilAnt + "', ent�o foi criado!" + CRLF
                EndIf
            EndIf

            //Se o indicar n�o existir nessa filial
            If ! SBZ->(MsSeek(FWxFilial("SBZ") + cCodProd))
                //Adiciona os campos
                aDados := {}
                aAdd(aDados, {"BZ_COD",    cCodProd,    Nil})
                aAdd(aDados, {"BZ_LOCPAD", cLocPadrao,  Nil})

                //Chama a inclus�o
                lMsErroAuto := .F.
                MsExecAuto({|x, y| MATA018(x, y)}, aDados, 3)

                //Se houve o erro
                If lMsErroAuto

                    //Pegando log do ExecAuto, percorrendo e incrementando o texto
                    aLogErro := GetAutoGRLog()
                    cTextoErro := ''
                    For nLinhaErro := 1 To Len(aLogErro)
                        cTextoErro += aLogErro[nLinhaErro] + CRLF
                    Next

                    //Criando o arquivo txt com o log
                    cNomeErro  := 'erro_sbz_' + cCodProd + '_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'
                    MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                    cObservacoes += "- Falha ao incluir o indicador do produto '" + cCodProd + "' na filial '" + cFilAnt + "', veja os detalhes do erro nesse arquivo: " + cPastaErro + cNomeErro + CRLF
                Else
                    cObservacoes += "+ N�o existia o indicador do produto '" + cCodProd + "', na filial '" + cFilAnt + "', ent�o foi criado!" + CRLF
                EndIf

            Else
                cObservacoes += "# Indicador do produto '" + cCodProd + "' j� tem cadastro na filial '" + cFilAnt + "'!" + CRLF
            EndIf

        Next

        //Se a filial de backup for diferente da que esta saindo da rotina, volta o backup
        If cFilAnt != cFilBkp
            cFilAnt := cFilBkp
            cNumEmp := cEmpAnt + cFilAnt
            OpenFile(cNumEmp)
        EndIf

    Else
        cObservacoes := "C�digo e/ou Armaz�m em Branco!" + CRLF
    EndIf

    FWRestArea(aArea)
Return cObservacoes

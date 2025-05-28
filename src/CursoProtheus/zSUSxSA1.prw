//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function zSUSxSA1
Fun��o para transformar cadastros da SUS (prospects) para SA1 (clientes)
@type  Function
@author Atilio
@since 12/05/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@obs Essa rotina foi criada, pois pelo padr�o � necess�rio gerar uma Oportunidade de Venda ou Or�amento
    para transformar o Prospect em Cliente

    Dessa forma, atrav�s do preenchimento do campo de Prospect De / At�, � feito a inclus�o do Cliente
    automaticamente via MsExecAuto, e depois � alterado o US_STATUS para 6 (Cliente) e preenchido os
    campos US_CODCLI + US_LOJACLI
@see https://tdn.totvs.com/display/public/PROT/FAT0000+Transformar+Prospect+em+Cliente
/*/

User Function zSUSxSA1()
    Local aArea := GetArea()
    Local aPergs := {}
    //Par�metros, traz do registro posicionado
    Private cProsDe := SUS->US_COD
    Private cLojaDe := SUS->US_LOJA
    Private cProsAt := SUS->US_COD
    Private cLojaAt := SUS->US_LOJA

    //Adiciona os par�metros no Array do ParamBox
    aAdd(aPergs, {1, "Prospect De",  cProsDe,  "", ".T.", "SUS", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Loja De",      cLojaDe,  "", ".T.", "",    ".T.", 40,  .F.})
    aAdd(aPergs, {1, "Prospect At�", cProsAt,  "", ".T.", "SUS", ".T.", 80,  .T.})
    aAdd(aPergs, {1, "Loja At�",     cLojaAt,  "", ".T.", "",    ".T.", 40,  .T.})

    //Se a pergunta for confirmada, ir� ser criado os clientes
    If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
        cProsDe := MV_PAR01
        cLojaDe := MV_PAR02
        cProsAt := MV_PAR03
        cLojaAt := MV_PAR04

        Processa({|| fTransform()}, "Transformando Prospects em Clientes")
    EndIf

    RestArea(aArea)
Return

Static Function fTransform()
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local nTotal    := 0
    Local nAtual    := 0
    Local cLogTxt   := ""
    Local cPasta    := ""
    Local cArquivo  := ""
    Local lOK       := .F.

    //Busca os prospects conforme o filtro (e que n�o tenham cliente vinculado ainda)
    cQuery := " SELECT " + CRLF
    cQuery += "     SUS.R_E_C_N_O_ AS SUSREC " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSQLName('SUS') + " SUS " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     US_FILIAL = '" + FWxFilial('SUS') + "' " + CRLF
    cQuery += "     AND US_COD  >= '" + cProsDe + "' " + CRLF
    cQuery += "     AND US_LOJA >= '" + cLojaDe + "' " + CRLF
    cQuery += "     AND US_COD  <= '" + cProsAt + "' " + CRLF
    cQuery += "     AND US_LOJA <= '" + cLojaAt + "' " + CRLF
    cQuery += "     AND US_CODCLI = '' " + CRLF
    cQuery += "     AND US_LOJACLI = '' " + CRLF
    cQuery += "     AND SUS.D_E_L_E_T_ = ' ' " + CRLF
    TCQuery cQuery New Alias "QRY_SUS"

    //Se houver dados
    If ! QRY_SUS->(EoF())

        //Define o tamanho da r�gua
        Count To nTotal
        ProcRegua(nTotal)
        QRY_SUS->(DbGoTop())

        //Enquanto houver dados
        While ! QRY_SUS->(EoF())

            //Incrementa a r�gua
            nAtual++
            IncProc("Analisando prospect " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

            //Posiciona na SUS conforme recno que vem da query
            DbSelectArea('SUS')
            SUS->(DbGoTo(QRY_SUS->SUSREC))
            
            //Chama a fun��o padr�o que gera o cliente atrav�s do Prospect
            lOK := Tk273GrvPTC(SUS->US_COD, SUS->US_LOJA, .T.)

            //Incrementa o log
            If lOK
                cLogTxt += "+ Prospect " + SUS->US_COD + SUS->US_LOJA +;
                    " (" + SubStr(SUS->US_NOME, 1, 15) + "...) foi transformado em cliente -" +;
                    "c�digo + loja: " + SUS->US_CODCLI + SUS->US_LOJACLI + ";" + CRLF
            Else
                cLogTxt += "- Prospect " + SUS->US_COD + SUS->US_LOJA +;
                    " (" + SubStr(SUS->US_NOME, 1, 15) + "...) n�o foi transformado em cliente, houve falha no processamento;" + CRLF
            EndIf

            QRY_SUS->(DbSkip())
        EndDo

        //Se existe(m) erro(s) no processamento, mostra mensagem e abre a pasta de logs
        If ! Empty(cLogTxt)
            cPasta := GetTempPath()
            cArquivo := "log_prospects_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
            MemoWrite(cPasta + cArquivo, cLogTxt)
            ShellExecute("OPEN", cArquivo, "", cPasta, 1)
        EndIf

    //Sen�o, exibe mensagem de alerta
    Else
        MsgStop("N�o foi encontrado Prospects com os filtros informados!", "Aten��o")
    EndIf
    QRY_SUS->(DbCloseArea())

    RestArea(aArea)
Return

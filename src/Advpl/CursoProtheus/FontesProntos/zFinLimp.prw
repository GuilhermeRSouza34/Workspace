//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function zFinLimp
Função que realiza a limpeza de tabelas do financeiro baixando títulos em aberto como dação
@type  Function
@author Atilio
@since 04/04/2022
/*/

User Function zFinLimp()
    Local aArea     := FWGetArea()
    Local aPergs    := {}
    Private nTipo     := 3
    Private dVencDe   := FirstDate(MonthSub(Date(), 1))
    Private dVencAt   := LastDate(dVencDe)
    Private cCliForDe := Space(TamSX3('A1_COD')[01])
    Private cCliForAt := StrTran(cCliForDe, ' ', 'Z')
    
    //Adiciona as perguntas para realizar o filtro
    aAdd(aPergs, {2, "Tipo",                     nTipo, {"1=Contas a Receber", "2=Contas a Pagar", "3=Ambas"}, 090, ".T.", .T.})
    aAdd(aPergs, {1, "Vencimento De",            dVencDe,    "", ".T.", "", ".T.", 100, .F.})
    aAdd(aPergs, {1, "Vencimento Até",           dVencAt,    "", ".T.", "", ".T.", 100, .T.})
    aAdd(aPergs, {1, "Cliente / Fornecedor De",  cCliForDe,  "", ".T.", "", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Cliente / Fornecedor Até", cCliForAt,  "", ".T.", "", ".T.", 80,  .T.})
    
    //Se a pergunta for confirmada, mostra uma mensagem para prosseguir
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
        If FWAlertYesNo("Os títulos que serão encontrados, serão feitos a baixa por dação, deseja mesmo assim prosseguir?", "Continua?")
            nTipo     := Val(cValToChar(MV_PAR01))
            dVencDe   := MV_PAR02
            dVencAt   := MV_PAR03
            cCliForDe := MV_PAR04
            cCliForAt := MV_PAR05

            Processa({|| fLimpeza()}, "Limpando...")
        EndIf
    EndIf

    FWRestArea(aArea)
Return

Static Function fLimpeza()
    Local cQuery    := ""
    Local nAtual    := 0
    Local nTotal    := 0
    Local dDataBkp  := dDataBase
    Local aDadosBx  := {}
    Local cPasta    := GetTempPath()
    Local cArquivo  := "log_limpeza_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".txt"
    Local aLogAuto  := {}
    Local cLogTxt   := ""
    Local nAux      := 0
    Local cPastaLog := "\x_logs\"
    Local cArquiLog := ""
    //Variáveis de controle do ExecAuto
    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.

    //Se a pasta de logs não existir, cria ela
    If ! ExistDir(cPastaLog)
        MakeDir(cPastaLog)
    EndIf

    //Monta a busca dos títulos
    If nTipo == 1 .Or. nTipo == 3
        cQuery += " SELECT " + CRLF
        cQuery += " 	'SE1' AS TIPO, " + CRLF
        cQuery += " 	E1_VENCREA AS VENCIM, " + CRLF
        cQuery += " 	SE1.R_E_C_N_O_ AS RECREF " + CRLF
        cQuery += " FROM " + CRLF
        cQuery += " 	" + RetSQLName("SE1") + " SE1 " + CRLF
        cQuery += " WHERE " + CRLF
        cQuery += " 	E1_FILIAL = '" + FWxFilial("SE1") + "' " + CRLF
        cQuery += " 	AND E1_CLIENTE >= '" + cCliForDe + "' " + CRLF
        cQuery += " 	AND E1_CLIENTE <= '" + cCliForAt + "' " + CRLF
        cQuery += " 	AND E1_VENCREA >= '" + dToS(dVencDe) + "' " + CRLF
        cQuery += " 	AND E1_VENCREA <= '" + dToS(dVencAt) + "' " + CRLF
        cQuery += " 	AND E1_SALDO != 0 " + CRLF
        cQuery += " 	AND E1_BAIXA = '' " + CRLF
        cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' " + CRLF
    EndIf
    If nTipo == 3
        cQuery += " UNION ALL " + CRLF
    EndIf
    If nTipo == 2 .Or. nTipo == 3
        cQuery += " SELECT " + CRLF
        cQuery += " 	'SE2' AS TIPO, " + CRLF
        cQuery += " 	E2_VENCREA AS VENCIM, " + CRLF
        cQuery += " 	SE2.R_E_C_N_O_ AS RECREF " + CRLF
        cQuery += " FROM " + CRLF
        cQuery += " 	" + RetSQLName("SE2") + " SE2 " + CRLF
        cQuery += " WHERE " + CRLF
        cQuery += " 	E2_FILIAL = '" + FWxFilial("SE2") + "' " + CRLF
        cQuery += " 	AND E2_FORNECE >= '" + cCliForDe + "' " + CRLF
        cQuery += " 	AND E2_FORNECE <= '" + cCliForAt + "' " + CRLF
        cQuery += " 	AND E2_VENCREA >= '" + dToS(dVencDe) + "' " + CRLF
        cQuery += " 	AND E2_VENCREA <= '" + dToS(dVencAt) + "' " + CRLF
        cQuery += " 	AND E2_SALDO != 0 " + CRLF
        cQuery += " 	AND E2_BAIXA = '' " + CRLF
        cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' " + CRLF
    EndIf
    cQuery += " ORDER BY " + CRLF
    cQuery += " 	VENCIM ASC " + CRLF
    TCQuery cQuery New Alias "QRY_TIT"
    TCSetField("QRY_TIT", "VENCIM", "D")

    //Se houver dados da query
    If ! QRY_TIT->(EoF())
        //Define o tamanho da régua
        Count To nTotal
        ProcRegua(nTotal)
        QRY_TIT->(DbGoTop())

        DbSelectArea("SE1")
        DbSelectArea("SE2")

        Begin Transaction
            //Cria o arquivo de log
            oFWriter := FWFileWriter():New(cPasta + cArquivo, .T.)
            oFWriter:Create()
            oFWriter:Write("Rotina iniciada - " + dToC(Date()) + " " + Time() + CRLF)

            //Enquanto houver dados da query
            While ! QRY_TIT->(EoF())
                //Incrementando a régua
                nAtual++
                IncProc("Baixando título " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

                //Caso a sua base, seja necessário baixar o título na data do vencimento, descomente a linha abaixo
                //dDataBase := QRY_TIT->VENCIM

                //Zera as variáveis do ExecAuto
                aDadosBx := {}
                lMsErroAuto	:= .F.

                //Monta os dados e aciona o execauto para fazer a baixa por dação
                If QRY_TIT->TIPO == "SE1"
                    SE1->(DbGoTo(QRY_TIT->RECREF))
                    aDadosBx := {;
                        {"E1_FILIAL",    SE1->E1_FILIAL,      Nil},;
                        {"E1_PREFIXO",   SE1->E1_PREFIXO,     Nil},;
                        {"E1_NUM",       SE1->E1_NUM,         Nil},;
                        {"E1_PARCELA",   SE1->E1_PARCELA,     Nil},;
                        {"E1_TIPO",      SE1->E1_TIPO,        Nil},;
                        {"E1_CLIENTE",   SE1->E1_CLIENTE,     Nil},;
                        {"E1_LOJA",      SE1->E1_LOJA,        Nil},;
                        {"AUTMOTBX",     "DAC",               Nil},;
                        {"AUTDTBAIXA",   dDataBase,           Nil},;
                        {"AUTDTCREDITO", dDataBase,           Nil},;
                        {"AUTHIST",      "Baixa Automática",  Nil},;
                        {"AUTVALREC",    SE1->E1_SALDO,       Nil};
                    }
                    MSExecAuto({|x, y| FINA070(x, y)}, aDadosBx, 3)
                Else
                    SE2->(DbGoTo(QRY_TIT->RECREF))
                    aDadosBx := {;
                        {"E2_FILIAL",    SE2->E2_FILIAL,      Nil},;
                        {"E2_PREFIXO",   SE2->E2_PREFIXO,     Nil},;
                        {"E2_NUM",       SE2->E2_NUM,         Nil},;
                        {"E2_PARCELA",   SE2->E2_PARCELA,     Nil},;
                        {"E2_TIPO",      SE2->E2_TIPO,        Nil},;
                        {"E2_FORNECE",   SE2->E2_FORNECE,     Nil},;
                        {"E2_LOJA",      SE2->E2_LOJA,        Nil},;
                        {"AUTMOTBX",     "DAC",               Nil},;
                        {"AUTDTBAIXA",   dDataBase,           Nil},;
                        {"AUTDTDEB",     dDataBase,           Nil},;
                        {"AUTHIST",      "Baixa Automática",  Nil},;
                        {"AUTVLRPG",     SE1->E1_SALDO,       Nil};
                    }
                    MSExecAuto({|x, y| FINA080(x, y)}, aDadosBx, 3)
                EndIf

                If lMsErroAuto
                    //Pegando log do ExecAuto
                    aLogAuto := GetAutoGRLog()
                    
                    //Percorrendo o Log e incrementando o texto
                    cLogTxt := ""
                    For nAux := 1 To Len(aLogAuto)
                        cLogTxt += "<p>" + aLogAuto[nAux] + "</p>" + CRLF
                    Next

                    //Grava o arquivo de log e incrementa o texto
                    cArquiLog := "bx_" + QRY_TIT->TIPO + "_" + cValToChar(QRY_TIT->RECREF) + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".txt"
                    MemoWrite(cPastaLog + cArquiLog, cLogTxt)
                    oFWriter:Write("[" + QRY_TIT->TIPO + "] RecNo: " + cValToChar(QRY_TIT->RECREF) + ", houve falha - arquivo de log em: '" + cPastaLog + cArquiLog + "' " + CRLF)
                Else
                    oFWriter:Write("[" + QRY_TIT->TIPO + "] RecNo: " + cValToChar(QRY_TIT->RECREF) + ", sucesso na baixa do título " + CRLF)
                EndIf

                QRY_TIT->(DbSkip())
            EndDo
        End Transaction

        //Encerra o arquivo e abre
        oFWriter:Write("Rotina encerrada - " + dToC(Date()) + " " + Time() + CRLF)
        oFWriter:Close()
        ShellExecute("OPEN", cArquivo, "", cPasta, 1)
    Else
        FWAlertError("Não foi encontrado dados com os filtros informados!", "Atenção")
    EndIf
    QRY_TIT->(DbCloseArea())

    dDataBase := dDataBkp
Return

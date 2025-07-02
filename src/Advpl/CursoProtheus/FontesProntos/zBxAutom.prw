//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function zBxAutom
Fun��o que realiza a baixa automaticamente de t�tulos a receber
@type  Function
@version version
/*/

User Function zBxAutom()
    Local aArea
    Local aPergs := {}
    Local lContinua := .F.
    Local nModBkp
    Local cFilBkp
    Private lJob := .F.
    Private dDataVen := Date()

    //Se o ambiente n�o estiver em p�, sobe para usar de maneira autom�tica
    If Select("SX2") == 0
        lJob := .T.
        lContinua := .T.
		RPCSetEnv("01", "0101", "", "", "", "")
    EndIf
    aArea := GetArea()

    //Se n�o for modo autom�tico, mostra uma pergunta
    If ! lJob
        //Adicionando os par�metros
        aAdd(aPergs, {1, "Vencimento Buscado", dDataVen, "", ".T.", "", ".T.", 80, .T.})

        //Se a pergunta for confirmada
        If ParamBox(aPergs, "Informe os par�metros", , , , , , , , , .F., .F.)
            dDataVen := MV_PAR01
            lContinua := .T.
        Else
            lContinua := .F.
        EndIf
    EndIf

    //Se for continuar, faz a chamada para a realiza��o das baixas
    If lContinua
        nModBkp := nModulo
        cFilBkp := cFilAnt
        nModulo := 6
        
        Processa({|| fFazBaixa()}, "Processando...")
        
        nModulo := nModBkp
        cFilAnt := cFilBkp
    EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} Static Function fFazBaixa
Fun��o que monta a query, efetua a busca e a baixa dos t�tulos
@type  Function
@author Atilio
@since 06/03/2021
@version version
/*/

Static Function fFazBaixa()
    Local aArea := GetArea()
    Local cQuery := ""
    Local nTotal := 0
    Local nAtual := 0
    Local cMaskSaldo := PesqPict('SE1', 'E1_SALDO')
    Local cMotBx := "XXX"
    Local aDadosBx := {}
    //Mensagem disparada por e-Mail
    Local aLogAuto
    Local cLogTxt
    Local nAux
    Local cPara := SuperGetMV('MV_X_EMBAI', .F., 'seuemail@empresa.com')
    Local cAssunto
    Local cMensagem
    //Vari�veis de controle do ExecAuto
    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.

    //Buscando t�tulos ainda com saldo e no vencimento informado
    cQuery := " SELECT " + CRLF
    cQuery += " 	SE1.R_E_C_N_O_ AS SE1REC " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += " 	" + RetSQLName('SE1') + " SE1 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += " 	E1_SALDO != 0 " + CRLF
    cQuery += " 	AND E1_VENCREA = '" + dToS(dDataVen) + "' " + CRLF
    cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' " + CRLF
    TCQuery cQuery New Alias "QRY_SE1"

    //Define o tamanho da r�gua
    Count To nTotal
    ProcRegua(nTotal)
    QRY_SE1->(DbGoTop())

    //Se existir dados
    If ! QRY_SE1->(EoF())
        //Enquanto houver dados
        While ! QRY_SE1->(EoF())
            //Incrementa a r�gua de processamento
            nAtual++
            IncProc("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

            //Posiciona na tabela, e altera a vari�vel p�blica de filial
            DbSelectArea('SE1')
            SE1->(DbGoTo(QRY_SE1->SE1REC))
            cFilAnt := SE1->E1_FILIAL

            //Monta o array para realizar a baixa
            aDadosBx := {;
                {"E1_FILIAL",    SE1->E1_FILIAL,      Nil},;
                {"E1_PREFIXO",   SE1->E1_PREFIXO,     Nil},;
                {"E1_NUM",       SE1->E1_NUM,         Nil},;
                {"E1_PARCELA",   SE1->E1_PARCELA,     Nil},;
                {"E1_TIPO",      SE1->E1_TIPO,        Nil},;
                {"E1_CLIENTE",   SE1->E1_CLIENTE,     Nil},;
                {"E1_LOJA",      SE1->E1_LOJA,        Nil},;
                {"AUTMOTBX",     cMotBx,              Nil},;
                {"AUTDTBAIXA",   dDataRef,            Nil},;
                {"AUTDTCREDITO", dDataRef,            Nil},;
                {"AUTHIST",      "Baixa Autom�tica",  Nil},;
                {"AUTVALREC",    SE1->E1_SALDO,       Nil};
            }

            //Efetua a baixa do t�tulo
			lMsErroAuto	:= .F.
			MSExecAuto({|x, y| FINA070(x, y)}, aDadosBx, 3)

            //Se houve algum erro
            If lMsErroAuto
                //Pegando log do ExecAuto
                aLogAuto := GetAutoGRLog()
                
                //Percorrendo o Log e incrementando o texto (para usar o CRLF voc� deve usar a include "Protheus.ch")
                cLogTxt := ""
                For nAux := 1 To Len(aLogAuto)
                    cLogTxt += "<p>" + aLogAuto[nAux] + "</p>" + CRLF
                Next

                //Monta mensagem de e-Mail para disparo em caso de falha
                cAssunto  := '[Baixa de T�tulos] Falha ao baixar t�tulo ' + SE1->E1_NUM
                cMensagem := ''
                cMensagem += '<p>Ol�.</p>' + CRLF
                cMensagem += '<p>Houve uma falha ao baixar um t�tulo no dia ' + dToC(Date()) + ' �s ' + Time() + '.</p>' + CRLF
                cMensagem += '<p><strong>Abaixo as informa��es do T�tulo:</strong></p>' + CRLF
                cMensagem += '<p>Filial:  '     + SE1->E1_FILIAL + '</p>' + CRLF
                cMensagem += '<p>N�mero:  '     + SE1->E1_NUM + '</p>' + CRLF
                cMensagem += '<p>Parcela:  '    + SE1->E1_PARCELA + '</p>' + CRLF
                cMensagem += '<p>Tipo:  '       + SE1->E1_TIPO + '</p>' + CRLF
                cMensagem += '<p>Cliente:  '    + SE1->E1_CLIENTE + '</p>' + CRLF
                cMensagem += '<p>Loja:  '       + SE1->E1_LOJA + '</p>' + CRLF
                cMensagem += '<p>Venc. Real:  ' + dToC(SE1->E1_VENCREA) + '</p>' + CRLF
                cMensagem += '<p>Valor:  '      + Alltrim(Transform(SE1->E1_SALDO, cMaskSaldo)) + '</p>' + CRLF
                cMensagem += '<br>' + CRLF
                cMensagem += '<p><strong>Abaixo a mensagem de erro:</strong></p>' + CRLF
                cMensagem += cLogTxt
                u_EnvEmail(cPara, cAssunto, cMensagem)
            EndIf

            QRY_SE1->(DbSkip())
        EndDo

        //Se n�o for autom�tico, mostra a mensagem de t�rmino
        If ! lJob
            MsgInfo("Processamento finalizado!", "Aten��o")
        EndIf
    EndIf
    QRY_SE1->(DbCloseArea())

    RestArea(aArea)
Return

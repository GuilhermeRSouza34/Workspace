//Bibliotecas
#Include "TOTVS.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*
    Para testes, esta sendo usado o seguinte link:
    http://187.94.60.130:14548/html-protheus/rest/ (dentro do AppServer da porta 14547)
*/

WSRESTFUL WSHolerite DESCRIPTION "WS de Métodos de Holerite"
    //Atributos usados
    WSDATA limit AS INTEGER
    WSDATA page AS INTEGER
    WSDATA cc AS STRING
    WSDATA yearmonth AS STRING
 
    //Métodos usados
    WSMETHOD GET ALL DESCRIPTION "Retorna todas os holerites confome Centro de Custo informado" WSSYNTAX '/WSHolerite/get_all?{cc, yearmonth, limit, page}' PATH "get_all"       PRODUCES APPLICATION_JSON
END WSRESTFUL

//Poderia ser usado o FWAdapterBaseV2(), porém a paginação foi feita manualmente
WSMETHOD GET ALL WSRECEIVE limit, page, cc, yearmonth WSSERVICE WSHolerite
    Local lRet       := .T.
    Local oResponse  := JsonObject():New()
    Local cQueryDad  := ""
    Local nTamanho   := 10
	Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local cPDFBase64 := ""
    Local cPeriodo   := SubStr(dToS(Date()), 1, 6)
    Local cNomeArq   := ""
    Local cPath      := SuperGetMV("MV_RELT", .F., "\spool\") + "holerite\"
    Local cObserv    := ""
    Local oArq       := Nil
    Local cArqConteu := ""
    Local cMatricula := ""
    Local cNome      := ""
    Local cSemana    := "01"

    //Se a pasta não existir, cria a pasta
    If ! ExistDir(cPath)
        MakeDir(cPath)
    EndIf

    //Se não tiver centro de custo
    If Empty(::cc)
        //SetRestFault(500, "Falha ao consultar holerites")
		Self:setStatus(500)
        oResponse["errorId"]  := "HOL001"
        oResponse["error"]    := "Centro de Custo vazio"
        oResponse["solution"] := "Informe um codigo de Centro de Custo para pesquisar os holerites"
    Else

        //Se vier o ano e mês, altera o período
        If ! Empty(::yearmonth)
            cPeriodo := ::yearmonth
        EndIf

        //Efetua a busca dos registros
        cQueryDad := " SELECT " + CRLF
        cQueryDad += "    RD_CC, " + CRLF
        cQueryDad += "    RD_PROCES, " + CRLF
        cQueryDad += "    RD_ROTEIR, " + CRLF
        cQueryDad += "    SRA.R_E_C_N_O_ AS SRAREC " + CRLF
        cQueryDad += " FROM " + CRLF
        cQueryDad += "    " + RetSQLName('SRA') + " SRA " + CRLF
        cQueryDad += "    INNER JOIN " + RetSQLName('SRD') + " SRD ON ( " + CRLF
        cQueryDad += "        RD_FILIAL = RA_FILIAL " + CRLF
        cQueryDad += "        AND RD_MAT = RA_MAT " + CRLF
        cQueryDad += "        AND RD_DATARQ = '" + cPeriodo + "' " + CRLF
        cQueryDad += "        AND RD_CC = '" + ::cc + "' " + CRLF
        cQueryDad += "        AND RD_PROCES = '00001' " + CRLF
        cQueryDad += "        AND RD_ROTEIR = 'FOL' " + CRLF
        cQueryDad += "        AND SRD.D_E_L_E_T_ = ' ' " + CRLF
        cQueryDad += "    ) " + CRLF
        cQueryDad += " WHERE " + CRLF
        cQueryDad += "    SRA.D_E_L_E_T_ = ' ' " + CRLF
        cQueryDad += " GROUP BY " + CRLF
        cQueryDad += "    RD_CC, " + CRLF
        cQueryDad += "    RD_PROCES, " + CRLF
        cQueryDad += "    RD_ROTEIR, " + CRLF
        cQueryDad += "    SRA.R_E_C_N_O_ " + CRLF
        TCQuery cQueryDad New Alias "QRY_DAD"

        //Se não encontrar o registro
        If QRY_DAD->(EoF())
            //SetRestFault(500, "Falha ao consultar funcionarios")
			Self:setStatus(500)
            oResponse["errorId"]  := "HOL002"
            oResponse["error"]    := "Nao ha registros!"
            oResponse["solution"] := "Nao existem registros com o filtro informado"
        Else

            oResponse["objects"] := {}

            //Conta o total de registros
            Count To nTotal
            QRY_DAD->(DbGoTop())

            //O tamanho do retorno, será o limit, se ele estiver definido
            If ! Empty(::limit)
                nTamanho := ::limit
            EndIf

            //Pegando total de páginas
            nPags := NoRound(nTotal / nTamanho, 0)
            nPags += Iif(nTotal % nTamanho != 0, 1, 0)
            
            //Se vier página
            If ! Empty(::page)
                nPagina := ::page
            EndIf

            //Se a página vier zerada ou negativa ou for maior que o máximo, será 1 
            If nPagina <= 0 .Or. nPagina > nPags
                nPagina := 1
            EndIf

            //Se a página for diferente de 1, pula os registros
            If nPagina != 1
                QRY_DAD->(DbSkip((nPagina-1) * nTamanho))
            EndIf

            //Adiciona os dados para a meta
            oJsonMeta := JsonObject():New()
            oJsonMeta["total"]         := nTotal
            oJsonMeta["current_page"]  := nPagina
            oJsonMeta["total_page"]    := nPags
            oJsonMeta["total_items"]   := nTamanho
            oResponse["meta"]          := oJsonMeta

            //Percorre os registros
            While ! QRY_DAD->(EoF())
                nAtual++
                cPDFBase64 := ""
                
                //Se ultrapassar o limite, encerra o laço
                If nAtual > nTamanho
                    Exit
                EndIf

                //Posiciona o registro
                DbSelectArea("SRA")
                SRA->(DbGoTo(QRY_DAD->SRAREC))
                cMatricula := SRA->RA_MAT
                cNome      := Alltrim(SRA->RA_NOME)

                //Define o nome do arquivo
                cNomeArq   := QRY_DAD->RD_CC + "_" + cPeriodo + "_" + SRA->RA_FILIAL + "_" + SRA->RA_MAT

                //Se o arquivo existir antes da geração do holerite, apaga ele
                If File(cPath + cNomeArq + ".pdf")
                    FErase(cPath + cNomeArq + ".pdf")
                EndIf

                //Se for outra filial, muda para poder gerar o relatório
                If cFilAnt != SRA->RA_FILIAL
                    cFilAnt := SRA->RA_FILIAL
                EndIf

                //Chama a impressão do Holerite
                u_xGPER030(;
                    .T.,;                  //lTerminal,
                    SRA->RA_FILIAL,;       //cFilTerminal,
                    SRA->RA_MAT,;          //cMatTerminal,
                    QRY_DAD->RD_PROCES,;   //cProcTerminal,
                    QRY_DAD->RD_ROTEIR,;   //nRecTipo,
                    cPeriodo,;             //cPerTerminal,
                    cSemana,;              //cSemanaTerminal,
                    .T.,;                  //lMeuRH,
                    cNomeArq;              //cArqName;
                )

                //Se o arquivo existir, deu certo a impressão do holerite
                If File(cPath + cNomeArq + ".pdf")
                    //Tenta abrir o arquivo
					oArq := FwFileReader():New(cPath + cNomeArq + ".pdf")
					If oArq:Open()
						cArqConteu := oArq:FullRead()
						cPDFBase64 := Encode64(cArqConteu, , .F., .F.)
						cObserv    := "PDF convertido para BASE64"
                        oArq:Close()
					Else
						cObserv := "Falha converter o PDF em BASE64"
					EndIf
                Else
                    cObserv := "Falha ao gerar o PDF"
                EndIf

                //Adiciona no retorno
                oJsonObj := JsonObject():New()
                oJsonObj["id"]       := cMatricula
                oJsonObj["cc"]       := QRY_DAD->RD_CC
                oJsonObj["name"]     := cNome
                oJsonObj["pdf"]      := cPDFBase64
                oJsonObj["message"]  := cObserv
                oJsonObj["origin"]   := cPath + cNomeArq + ".pdf"
                aAdd(oResponse["objects"], oJsonObj)

                //Exclui o pdf original
                FErase(cPath + cNomeArq + ".pdf")

                QRY_DAD->(DbSkip())
            EndDo
        EndIf
        QRY_DAD->(DbCloseArea())
    EndIf

    //Define o retorno
    Self:SetContentType("application/json")
    Self:SetResponse(oResponse:toJSON())
Return lRet

//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function zListNF
Listagem de NFs
@author Daniel Atilio
@since 04/08/2020
@version 1.0
@type function
/*/

User Function zListNF()
	Local aArea := GetArea()
	Local aPergs   := {}
	Local cFilDe := Space(TamSX3('F2_FILIAL')[1])
	Local cFilAt := StrTran(cFilDe, ' ', 'Z')
	Local dDatDe := FirstDate(Date())
	Local dDatAt := LastDate(Date())
	
	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Filial De", cFilDe,  "", ".T.", "SM0", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Filial Até", cFilAt,  "", ".T.", "SM0", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Data De", dDatDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Até", dDatAt,  "", ".T.", "", ".T.", 80,  .T.})
	
	//Se a pergunta for confirmada, chama o preenchimento dos dados do .dot
	If ParamBox(aPergs, "Informe os parametros")
        If dDatAt >= dDatDe .And. cFilAt >= cFilDe
		    Processa({|| fGeraExcel()})
        Else
            MsgStop("Data Até e Filial Até devem ser maior ou igual a Data De e Filial De!", "Atenção")
        EndIf
	EndIf
	
	RestArea(aArea)
Return

/*/{Protheus.doc} fGeraExcel
Criacao do arquivo Excel na funcao zListNF
@author Daniel Atilio
@since 04/08/2020
@version 1.0
@type function
/*/

Static Function fGeraExcel()
	Local cQryDad  := ""
	Local oFWMsExcel
	Local oExcel
	Local cArquivo   := GetTempPath() + "zListNF_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".xml"
	Local cWorkShSai := "Saidas"
	Local cTituloSai := "Lista de NFs de Saida"
    Local cWorkShEnt := "Entradas"
	Local cTituloEnt := "Lista de NFs de Entrada"
	Local nAtual := 0
	Local nTotal := 0
	
	//Montando consulta de dados
	cQryDad += "SELECT "		+ CRLF
	cQryDad += " 'SAIDA' AS TIPO, "		+ CRLF
	cQryDad += " F2_EMISSAO AS DT_EMISS, "		+ CRLF
	cQryDad += " F2_DOC AS NFISCAL, "		+ CRLF
	cQryDad += " F2_SERIE AS SERIE, "		+ CRLF
	cQryDad += " F2_CLIENTE AS CLIFOR, "		+ CRLF
	cQryDad += " F2_LOJA AS LOJA, "		+ CRLF
	cQryDad += " A1_NOME AS NOME, "		+ CRLF
	cQryDad += " F2_VALMERC AS VALOR "		+ CRLF
	cQryDad += "FROM "		+ CRLF
	cQryDad += " " + RetSQLName('SF2') + " SF2 "		+ CRLF
	cQryDad += " INNER JOIN " + RetSQLName('SA1') + " SA1 ON ( "		+ CRLF
	cQryDad += " A1_FILIAL = '" + FWxFilial('SA1') + "' "		+ CRLF
	cQryDad += " AND A1_COD = F2_CLIENTE "		+ CRLF
	cQryDad += " AND A1_LOJA = F2_LOJA "		+ CRLF
	cQryDad += " AND SA1.D_E_L_E_T_ = ' ' "		+ CRLF
	cQryDad += " ) "		+ CRLF
	cQryDad += "WHERE "		+ CRLF
	cQryDad += " F2_FILIAL >= '" + MV_PAR01 + "' "		+ CRLF
	cQryDad += " AND F2_FILIAL <= '" + MV_PAR02 + "' "		+ CRLF
	cQryDad += " AND F2_EMISSAO >= '" + dToS(MV_PAR03) + "' "		+ CRLF
	cQryDad += " AND F2_EMISSAO <= '" + dToS(MV_PAR04) + "' "		+ CRLF
	cQryDad += " AND F2_TIPO NOT IN ('B', 'D') "		+ CRLF
	cQryDad += " AND SF2.D_E_L_E_T_ = ' ' "		+ CRLF
	cQryDad += " "		+ CRLF
	cQryDad += "UNION ALL "		+ CRLF
	cQryDad += " "		+ CRLF
	cQryDad += "SELECT "		+ CRLF
	cQryDad += " 'ENTRADA' AS TIPO, "		+ CRLF
	cQryDad += " F1_EMISSAO AS DT_EMISS, "		+ CRLF
	cQryDad += " F1_DOC AS NFISCAL, "		+ CRLF
	cQryDad += " F1_SERIE AS SERIE, "		+ CRLF
	cQryDad += " F1_FORNECE AS CLIFOR, "		+ CRLF
	cQryDad += " F1_LOJA AS LOJA, "		+ CRLF
	cQryDad += " A2_NOME AS NOME, "		+ CRLF
	cQryDad += " F1_VALMERC AS VALOR "		+ CRLF
	cQryDad += "FROM "		+ CRLF
	cQryDad += " " + RetSQLName('SF1') + " SF1 "		+ CRLF
	cQryDad += " INNER JOIN " + RetSQLName('SA2') + " SA2 ON ( "		+ CRLF
	cQryDad += " A2_FILIAL = '" + FWxFilial('SA2') + "' "		+ CRLF
	cQryDad += " AND A2_COD = F1_FORNECE "		+ CRLF
	cQryDad += " AND A2_LOJA = F1_LOJA "		+ CRLF
	cQryDad += " AND SA2.D_E_L_E_T_ = ' ' "		+ CRLF
	cQryDad += " ) "		+ CRLF
	cQryDad += "WHERE "		+ CRLF
	cQryDad += " F1_FILIAL >= '" + MV_PAR01 + "' "		+ CRLF
	cQryDad += " AND F1_FILIAL <= '" + MV_PAR02 + "' "		+ CRLF
	cQryDad += " AND F1_DTDIGIT >= '" + dToS(MV_PAR03) + "' "		+ CRLF
	cQryDad += " AND F1_DTDIGIT <= '" + dToS(MV_PAR04) + "' "		+ CRLF
	cQryDad += " AND F1_TIPO NOT IN ('B', 'D') "		+ CRLF
	cQryDad += " AND SF1.D_E_L_E_T_ = ' ' "		+ CRLF
	cQryDad += " "		+ CRLF
	cQryDad += "ORDER BY "		+ CRLF
	cQryDad += " DT_EMISS, "		+ CRLF
	cQryDad += " TIPO"		+ CRLF
	
	//Executando consulta e setando o total da regua
	PlsQuery(cQryDad, "QRY_DAD")
    TCSetField("QRY_DAD", "DT_EMISS", "D")
	DbSelectArea("QRY_DAD")
	
	//Cria a planilha do excel
	oFWMsExcel := FWMSExcel():New()
	
	//Criando as abas da planilha
	oFWMsExcel:AddworkSheet(cWorkShSai)
    oFWMsExcel:AddworkSheet(cWorkShEnt)
	
	//Criando as Tabelas e as colunas
	oFWMsExcel:AddTable(cWorkShSai, cTituloSai)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Data de Emissão", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Nota Fiscal", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Série", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Cliente", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Loja", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Nome", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShSai, cTituloSai, "Valor", 3, 3, .F.)

    oFWMsExcel:AddTable(cWorkShEnt, cTituloEnt)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Data de Emissão", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Nota Fiscal", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Série", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Fornecedor", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Loja", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Nome", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkShEnt, cTituloEnt, "Valor", 3, 3, .F.)
	
	//Definindo o tamanho da regua
	Count To nTotal
	ProcRegua(nTotal)
	QRY_DAD->(DbGoTop())
	
	//Percorrendo os dados da query
	While !(QRY_DAD->(EoF()))
		
		//Incrementando a regua
		nAtual++
		IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		
		//Se for saida, adicionando uma nova linha
        If Alltrim(Upper(QRY_DAD->TIPO)) == 'SAIDA'
            oFWMsExcel:AddRow(cWorkShSai, cTituloSai, {;
                dToC(QRY_DAD->DT_EMISS),;
                QRY_DAD->NFISCAL,;
                QRY_DAD->SERIE,;
                QRY_DAD->CLIFOR,;
                QRY_DAD->LOJA,;
                QRY_DAD->NOME,;
                QRY_DAD->VALOR;
            })
        ElseIf Alltrim(Upper(QRY_DAD->TIPO)) == 'ENTRADA'
            oFWMsExcel:AddRow(cWorkShEnt, cTituloEnt, {;
                dToC(QRY_DAD->DT_EMISS),;
                QRY_DAD->NFISCAL,;
                QRY_DAD->SERIE,;
                QRY_DAD->CLIFOR,;
                QRY_DAD->LOJA,;
                QRY_DAD->NOME,;
                QRY_DAD->VALOR;
            })
        EndIf
		
		QRY_DAD->(DbSkip())
	EndDo
	QRY_DAD->(DbCloseArea())

    //Esperando 1 segundo para gerar o arquivo
    Sleep(5000)

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
	
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
	
Return

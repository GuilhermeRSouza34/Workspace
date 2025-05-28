#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#Include "Protheus.ch"

/*-------------------------------------------------------------------------------*
 | Programa 	: RFATR01.PRW									 |
 | Data 		: 09/10/2025									 |
 | Autor    	: Guilherme Souza            	    	                		 |
 | Uso      	: Relatorio de Analise de Vendas                    		 |
 *-------------------------------------------------------------------------------*/

User Function RFATR01()
    Local aArea := FWGetArea()

    Processa({|| fGeraExcel()})
    FWRestArea(aArea)
Return

Static Function fGeraExcel()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cCaminho     := GetTempPath()+'RFATR01.XML'
    Local nTotal       := 0
    Local oFWMsExcel
    Local oExcel
    Local cWorkSheet   := "Relatorio"
    Local cTitulo      := "Relatorio de Analise de Vendas"
    Local nAtual       := 0

    Private cPerg   := "RFATR01"

    ValidSX1()
    Pergunte(cPerg,.T.)
    
    cQuery := " SELECT D2.D2_FILIAL, D2.D2_DOC, D2.D2_SERIE, D2.D2_CLIENTE, D2.D2_LOJA, "
    cQuery += " A1.A1_NOME, A1.A1_GRPVEN, "
    cQuery += " B1.B1_COD, B1.B1_DESC, B1.B1_GRUPO, BM.BM_DESC, "
    cQuery += " D2.D2_QUANT, D2.D2_PRCVEN, D2.D2_TOTAL, D2.D2_EMISSAO, "
    cQuery += " F4.F4_TEXTO, "
    cQuery += " A3.A3_NOME AS VENDEDOR "
    cQuery += " FROM " + RetSqlName("SD2") + " D2 "
    cQuery += " INNER JOIN " + RetSqlName("SA1") + " A1 WITH (NOLOCK) ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA "
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 WITH (NOLOCK) ON B1.B1_COD = D2.D2_COD "
    cQuery += " INNER JOIN " + RetSqlName("SBM") + " BM WITH (NOLOCK) ON BM.BM_GRUPO = B1.B1_GRUPO "
    cQuery += " INNER JOIN " + RetSqlName("SF4") + " F4 WITH (NOLOCK) ON F4.F4_CODIGO = D2.D2_TES "
    cQuery += " INNER JOIN " + RetSqlName("SA3") + " A3 WITH (NOLOCK) ON A3.A3_COD = D2.D2_VEND "
    cQuery += " WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "' "
    cQuery += " AND D2.D2_EMISSAO >= '" + dTos(mv_par01) + "' AND D2.D2_EMISSAO <= '" + dTos(mv_par02) + "' "
    cQuery += " AND D2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' "
    cQuery += " AND BM.D_E_L_E_T_ = '' AND F4.D_E_L_E_T_ = '' AND A3.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY D2.D2_EMISSAO, D2.D2_DOC "

    TCQUERY cQuery Alias "QRY" New

    oFWMsExcel := FWMsExcelEx():New() 
    oFWMsExcel:AddworkSheet(cWorkSheet)

    oFWMsExcel:AddTable(cWorkSheet, cTitulo)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Data",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Nota Fiscal",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Serie",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Cliente",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Nome Cliente",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Grupo Cliente",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Vendedor",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Produto",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Descricao",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Grupo Produto",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Desc. Grupo",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Quantidade",2,2)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Preco Unit.",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Total",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Tipo Operacao",1,1)

    Count To nTotal
    ProcRegua(nTotal)    
    QRY->(DbGoTop())

    While !(QRY->(EoF()))
        nAtual++
        IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
            STOD(QRY->D2_EMISSAO),;
            QRY->D2_DOC,;
            QRY->D2_SERIE,;
            QRY->D2_CLIENTE,;
            QRY->A1_NOME,;
            QRY->A1_GRPVEN,;
            QRY->VENDEDOR,;
            QRY->B1_COD,;
            QRY->B1_DESC,;
            QRY->B1_GRUPO,;
            QRY->BM_DESC,;
            QRY->D2_QUANT,;
            QRY->D2_PRCVEN,;
            QRY->D2_TOTAL,;
            QRY->F4_TEXTO})

        QRY->( dbSkip() )
    Enddo

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cCaminho)
    oExcel := MsExcel():New()             	//Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cCaminho)     	//Abre uma planilha
    oExcel:SetVisible(.T.)                 	//Visualiza a planilha
    oExcel:Destroy()

    QRY->(DbCloseArea())
    FWRestArea(aArea)   

    MsgInfo("Planilha Gerada")

Return

Static Function ValidSX1()
    Local aPergs := {}

    Aadd(aPergs,{"Data Inicial?  ","","","mv_ch1","D", 8,0,0,"G",,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
    Aadd(aPergs,{"Data Final?    ","","","mv_ch2","D", 8,0,0,"G",,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

Return(.T.)

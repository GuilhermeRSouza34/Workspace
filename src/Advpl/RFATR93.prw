#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#Include "Protheus.ch"

/*-------------------------------------------------------------------------------*
 | Programa 	: RFATR93.PRW										 |
 | Data 		: 09/10/2025										 |
 | Autor    	: Trae AI            	    	                		 |
 | Uso      	: Relatorio de vendas por produto com ranking                    	 |
 *-------------------------------------------------------------------------------*/

User Function RFATR93()
    Local aArea := FWGetArea()

    Processa({|| fGeraExcel()})
    FWRestArea(aArea)
Return

Static Function fGeraExcel()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cCaminho     := GetTempPath()+'RFATR93.XML'
    Local nTotal       := 0
    Local oFWMsExcel
    Local oExcel
    Local cWorkSheet   := "Relatorio"
    Local cTitulo      := "Relatorio de Vendas por Produto"
    Local nAtual       := 0

    Private cPerg   := "RFATR93"

    ValidSX1()
    Pergunte(cPerg,.T.)
    
    cQuery := " SELECT B1.B1_COD, B1.B1_DESC, B1.B1_GRUPO, BM.BM_DESC, "
    cQuery += " SUM(D2.D2_QUANT) AS QUANTIDADE, "
    cQuery += " SUM(D2.D2_TOTAL) AS VALOR_TOTAL, "
    cQuery += " SUM(D2.D2_VALBRUT) AS VALOR_BRUTO, "
    cQuery += " AVG(D2.D2_PRCVEN) AS PRECO_MEDIO "
    cQuery += " FROM " + RetSqlName("SD2") + " D2 "
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 WITH (NOLOCK) ON B1.B1_COD = D2.D2_COD "
    cQuery += " INNER JOIN " + RetSqlName("SBM") + " BM WITH (NOLOCK) ON BM.BM_GRUPO = B1.B1_GRUPO "
    cQuery += " WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "' "
    cQuery += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += " AND BM.BM_FILIAL = '" + xFilial("SBM") + "' "
    cQuery += " AND D2.D2_EMISSAO >= '" + dTos(mv_par01) + "' AND D2.D2_EMISSAO <= '" + dTos(mv_par02) + "' "
    cQuery += " AND D2.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' AND BM.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY B1.B1_COD, B1.B1_DESC, B1.B1_GRUPO, BM.BM_DESC "
    cQuery += " ORDER BY VALOR_TOTAL DESC "

    TCQUERY cQuery Alias "QRY" New

    oFWMsExcel := FWMsExcelEx():New() 
    oFWMsExcel:AddworkSheet(cWorkSheet)

    oFWMsExcel:AddTable(cWorkSheet, cTitulo)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Código Produto",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Descrição",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Grupo",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Desc. Grupo",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Quantidade",2,2)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Preço Médio",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Valor Total",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Valor Bruto",3,3)

    Count To nTotal
    ProcRegua(nTotal)    
    QRY->(DbGoTop())

    While !(QRY->(EoF()))
        nAtual++
        IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
            QRY->B1_COD,;          // Código Produto
            QRY->B1_DESC,;         // Descrição
            QRY->B1_GRUPO,;        // Grupo
            QRY->BM_DESC,;         // Desc. Grupo
            QRY->QUANTIDADE,;      // Quantidade
            QRY->PRECO_MEDIO,;     // Preço Médio
            QRY->VALOR_TOTAL,;     // Valor Total
            QRY->VALOR_BRUTO})     // Valor Bruto

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
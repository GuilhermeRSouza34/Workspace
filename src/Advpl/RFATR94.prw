#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#Include "Protheus.ch"

/*-------------------------------------------------------------------------------*
 | Programa 	: RFATR94.PRW										 |
 | Data 		: 09/10/2025										 |
 | Autor    	: Guilherme Souza            	    	                		 |
 | Uso      	: Relatorio de performance de vendedores                    	 |
 *-------------------------------------------------------------------------------*/

User Function RFATR94()
    Local aArea := FWGetArea()

    Processa({|| fGeraExcel()})
    FWRestArea(aArea)
Return

Static Function fGeraExcel()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cCaminho     := GetTempPath()+'RFATR94.XML'
    Local nTotal       := 0
    Local oFWMsExcel
    Local oExcel
    Local cWorkSheet   := "Relatorio"
    Local cTitulo      := "Relatorio de Performance de Vendedores"
    Local nAtual       := 0

    Private cPerg   := "RFATR94"

    ValidSX1()
    Pergunte(cPerg,.T.)
    
    cQuery := " SELECT A3.A3_COD, A3.A3_NOME, A3.A3_SUPER, SUPER.A3_NOME AS NOME_SUPER, "
    cQuery += " COUNT(DISTINCT C5.C5_NUM) AS TOTAL_PEDIDOS, "
    cQuery += " SUM(C6.C6_VALOR) AS VALOR_VENDIDO, "
    cQuery += " SUM(C6.C6_COMIS1) AS VALOR_COMISSAO, "
    cQuery += " COUNT(DISTINCT C5.C5_CLIENTE) AS TOTAL_CLIENTES, "
    cQuery += " AVG(C6.C6_VALOR) AS TICKET_MEDIO "
    cQuery += " FROM " + RetSqlName("SC5") + " C5 "
    cQuery += " INNER JOIN " + RetSqlName("SC6") + " C6 WITH (NOLOCK) ON C5.C5_NUM = C6.C6_NUM AND C5.C5_FILIAL = C6.C6_FILIAL "
    cQuery += " INNER JOIN " + RetSqlName("SA3") + " A3 WITH (NOLOCK) ON A3.A3_COD = C5.C5_VEND1 "
    cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SUPER WITH (NOLOCK) ON A3.A3_SUPER = SUPER.A3_COD "
    cQuery += " WHERE C5.C5_FILIAL = '" + xFilial("SC5") + "' "
    cQuery += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += " AND A3.A3_FILIAL = '" + xFilial("SA3") + "' "
    cQuery += " AND C5.C5_EMISSAO >= '" + dTos(mv_par01) + "' AND C5.C5_EMISSAO <= '" + dTos(mv_par02) + "' "
    cQuery += " AND C5.D_E_L_E_T_ = '' AND C6.D_E_L_E_T_ = '' AND A3.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY A3.A3_COD, A3.A3_NOME, A3.A3_SUPER, SUPER.A3_NOME "
    cQuery += " ORDER BY VALOR_VENDIDO DESC "

    TCQUERY cQuery Alias "QRY" New

    oFWMsExcel := FWMsExcelEx():New() 
    oFWMsExcel:AddworkSheet(cWorkSheet)

    oFWMsExcel:AddTable(cWorkSheet, cTitulo)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Código Vendedor",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Nome Vendedor",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Código Supervisor",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Nome Supervisor",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Total Pedidos",2,2)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Total Clientes",2,2)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Valor Vendido",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Ticket Médio",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Valor Comissão",3,3)

    Count To nTotal
    ProcRegua(nTotal)    
    QRY->(DbGoTop())

    While !(QRY->(EoF()))
        nAtual++
        IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
            QRY->A3_COD,;          // Código Vendedor
            QRY->A3_NOME,;         // Nome Vendedor
            QRY->A3_SUPER,;        // Código Supervisor
            QRY->NOME_SUPER,;      // Nome Supervisor
            QRY->TOTAL_PEDIDOS,;   // Total Pedidos
            QRY->TOTAL_CLIENTES,;  // Total Clientes
            QRY->VALOR_VENDIDO,;   // Valor Vendido
            QRY->TICKET_MEDIO,;    // Ticket Médio
            QRY->VALOR_COMISSAO})  // Valor Comissão

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

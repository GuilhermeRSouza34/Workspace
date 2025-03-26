#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#Include "Protheus.ch"

/*-------------------------------------------------------------------------------*
 | Programa 	: RFATR92.PRW													 |
 | Data 		: 09/10/2025													 |
 | Autor    	: Guilherme Souza            	    	                		 |
 | Uso      	: Relatorio gestores, base faturamento                    		 |
 *-------------------------------------------------------------------------------*/


User Function RFATR92()
    Local aArea := FWGetArea()

    Processa({|| fGeraExcel()})
    FWRestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Fun��o     : fGeraExcel.PRW                                                   |
 | Data       : 25/03/2025                                                       |
 | Autor      : Guilherme Souza                                                  |
 | Uso        : Gera o relatorio                                                 |
 *-------------------------------------------------------------------------------*/


Static Function fGeraExcel()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cCaminho     := GetTempPath()+'RFATR92.XML'
    Local nTotal       := 0
    Local oFWMsExcel
    Local oExcel
    Local cWorkSheet   := "Relatorio"
    Local cTitulo      := "Relatorio de faturamento gestores"
    Local nAtual       := 0
    Local _cRepres := Space(6)
    Local _cSuperv := Space(6)

    Private cPerg   := "RFATR92"
    _aAcesso := U_fAcesVend(@_cRepres)


    If _cRepres <> ""
    SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3")+_cRepres))
	_cFiltro1 := SA3->A3_COD
EndIf


_aAcesso := U_fAcVen1(@_cSuperv)
If _cSuperv <> ""
    SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3")+_cSuperv))  //Posiciona no registro do supervisor do 
	If(SA3->A3_SUPER <> "")
		_cFiltro2 := SA3->A3_SUPER
	EndIf
EndIf


    ValidSX1()
    Pergunte(cPerg,.T.)
    
    cQuery := " SELECT A3.A3_SUPER, A3.A3_NOME, A1.A1_GRPVEN, A1.A1_COD, A1.A1_NOME, "
    cQuery += " C5.C5_NUM, C5.C5_NOTA, C5.C5_EMISSAO, "
    cQuery += " SUM(C6.C6_VALOR) AS VALOR_FATURADO, "
    cQuery += " SUM((C6.C6_QTDVEN - C6.C6_QTDENT) * C6.C6_PRCVEN) AS VALOR_A_FATURAR, "
    cQuery += " SUPER.A3_NOME AS SUPERVISOR_NOME "
    cQuery += " FROM " + RetSqlName("SC5") + " C5 "
    cQuery += " INNER JOIN " + RetSqlName("SC6") + " C6 WITH (NOLOCK) ON C5.C5_NUM = C6.C6_NUM AND C5.C5_FILIAL = C6.C6_FILIAL "
    cQuery += " INNER JOIN " + RetSqlName("SA1") + " A1 WITH (NOLOCK) ON A1.A1_COD + A1.A1_LOJA = C5.C5_CLIENTE + C5.C5_LOJACLI "
    cQuery += " INNER JOIN " + RetSqlName("SA3") + " A3 WITH (NOLOCK) ON A3.A3_COD = C5.C5_VEND1 "
    cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SUPER WITH (NOLOCK) ON A3.A3_SUPER = SUPER.A3_COD " 
    cQuery += " WHERE C5.C5_FILIAL = '" + xFilial("SC5") + "' AND C6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += " AND A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A3.A3_FILIAL = '" + xFilial("SA3") + "' "
    cQuery += " AND C6.C6_ENTREG >= '" + dTos(mv_par01) + "' AND C6.C6_ENTREG <= '" + dTos(mv_par02) + "' "
    cQuery += " AND C5.D_E_L_E_T_ = '' AND C6.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' AND A3.D_E_L_E_T_ = '' "
    
        /* Aqui aplicamos o filtro para supervisor */
    If !Empty(_cFiltro2)
        cQuery += " AND A3.A3_SUPER = '" + _cFiltro2 + "' "  /* Filtro pelo supervisor */
    EndIf
        
    cQuery += " GROUP BY A3.A3_SUPER, A3.A3_NOME, SUPER.A3_NOME, A1.A1_GRPVEN, A1.A1_COD, A1.A1_NOME, C5.C5_NUM, C5.C5_NOTA, C5.C5_EMISSAO "
    cQuery += " ORDER BY A3.A3_SUPER, A3.A3_NOME, A1.A1_GRPVEN, A1.A1_COD, A1.A1_NOME, C5.C5_NUM, C5.C5_NOTA, C5.C5_EMISSAO "


    TCQUERY cQuery Alias "QRY" New

    oFWMsExcel := FWMsExcelEx():New() 
    oFWMsExcel:AddworkSheet(cWorkSheet)

    oFWMsExcel:AddTable(cWorkSheet, cTitulo)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Supervisor",1,1)
    OFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Nome Supervisor",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Representante",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Grupo Cliente",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"COD Cliente",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Cliente",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Pedido",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"NF",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Data Faturamento",1,1)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"Valor Faturado",3,3)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo,"A faturar",3,3)

    Count To nTotal
    ProcRegua(nTotal)    
    QRY->(DbGoTop())

    While !(QRY->(EoF()))
        
        nAtual++
        IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
            QRY->A3_SUPER,;         // Supervisor
            QRY->SUPERVISOR_NOME,;  // Nome Supervisor
            QRY->A3_NOME,;          // Representante
            QRY->A1_GRPVEN,;        // Grupo Cliente
            QRY->A1_COD,;           // COD Cliente
            QRY->A1_NOME,;          // Cliente
            QRY->C5_NUM,;           // Pedido
            QRY->C5_NOTA,;          // Nota Fiscal
            sToD(QRY->C5_EMISSAO),; // Data de Faturamento
            QRY->VALOR_FATURADO,;   // Valor Faturado
            QRY->VALOR_A_FATURAR})  // Valor a Faturar

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

    Aadd(aPergs,{"Data Inicial?  ","","","mv_ch1","D", 8,0,0,"G",,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    Aadd(aPergs,{"Data Final?    ","","","mv_ch2","D", 8,0,0,"G",,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

Return(.T.)



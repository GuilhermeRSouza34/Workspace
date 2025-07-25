#include "TOPCONN.CH"
#include "PROTHEUS.CH"
#include "TBICONN.CH"
#include "ap5mail.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*-------------------------------------------------------------------------------*
 | Programa 	: VENDDIA.PRW													 |
 | Data 		: 09/07/2025													 |
 | Autor    	: Guilherme Souza            	                     			 |
 | Uso      	: Relatorio para vendas diarias                          		 |
 *-------------------------------------------------------------------------------*/


User Function VENDDIA(cAlias,nReg,nOpcX,lSched,aParam)

    Local CbTxt
    Local wnrel
    Local cPerg         := Padr("RFAT37",10)
    Local cDesc1        := "Este relatorio emite a relacao de vendas diarias (pedidos SC5/SC6) e devolucoes."
    Local cDesc2        := ""
    Local cString       := "SC5"

    Private titulo      := "Mapa de Vendas Diarias"
    Private _nNumDias   := 0
    Private nomeprog    := "RFAT37"
    Private tamanho     := "G"
    Private aReturn     := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
    Private cabec1      := ''
    Private cabec2      := ''
    Private nLastKey    := 0

    Private lAuto		:= (nReg!=Nil)

    Default lSched      := .F.
    Default aParam      :=     {"01","01"}

    // Prepara ambiente para execução agendada
    If lSched
        Reset Environment
        RPCSetType(3)
        If FindFunction("WFPREPENV")
            WfPrepENV(aParam[1],aParam[2])
        Else
            Prepare Environment Empresa aParam[1] Filial aParam[2]
        EndIf
    Endif

    ValidSX1()

    // Exibe perguntas para o usuário conforme contexto (agendado, automático ou manual)
    If lSched 
        Pergunte(cPerg,.F.)
        lAuto:= .F.
    Else
        If lAuto 
            Pergunte(cPerg,.F.)
        Else
            Pergunte(cPerg,.T.)
        EndIf	
    Endif

    cbtxt    := SPACE(10)
    li       := 80
    m_pag    := 01

    // Configuração do spool de impressão
    wnrel  := "RFAT37"
    wnrel  := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,"",.F.,"",,Tamanho)

    If nLastKey==27
        dbClearFilter()
        Return
    Endif

    SetDefault(aReturn,cString)

    If nLastKey==27
        dbClearFilter()
        Return
    Endif

    // Executa a função principal de impressão do relatório
    RptStatus({|lEnd| VENDDIAImp(@lEnd,wnRel,cString,nomeprog,Titulo,nReg,lSched)},"Aguarde...","Executando relatorio...")

    Set Device To Screen

    If ( aReturn[5] = 1 )
        dbCommitAll()
        Set Printer To
        OurSpool(wnrel)
    Endif

    MS_FLUSH()

Return

/*-------------------------------------------------------------------------------*
 | Static Function : VENDDIAImp                                                  |
 | Uso             : Impressão do relatório de vendas diárias                    |
 *-------------------------------------------------------------------------------*/
Static Function VENDDIAImp(lEnd,wnrel,cString,nomeprog,Titulo,nReg,lSched)

    Local cRodaTxt 		:= "REGISTRO(S)"
    Local nCntImpr 		:= 0
    Local dDataIni 
    Local dDataFim 

    If lSched
        mv_par01 := STRZERO(MONTH(dDataBase),2)
        mv_par02 := STRZERO(YEAR(dDataBase),4)
    Else
        If lAuto
            mv_par01 := STRZERO(MONTH(dDataBase),2)
            mv_par02 := STRZERO(YEAR(dDataBase),4)
        EndIf
    Endif

    dDataIni := Ctod("01/"+MV_PAR01+"/"+mv_par02)
    dDataFim := LastDay(Ctod("01/"+MV_PAR01+"/"+mv_par02))

    Titulo   := "MAPA DE VENDAS DIARIAS - Periodo de: "+DTOC(dDataIni)+" até "+DTOC(dDataFim)

    cabec1:= "DIA |          VENDAS          | TRANSFERENCIA |       REMESSA        |      FATURA TUDO      |        DEVOLUCOES        |      DEV REMESSA    |   DEV  FATURA TUDO   |      TOTAL ENTREGUE      |      TOTAL VENDIDO        |"
    cabec2:= "    |   Qtde         Valor     |     Qtde      |    Qtde      Valor   |   Qtde        Valor   |     Qtde       Valor     |   Qtde      Valor   |     Qtde     Valor   |    Qtde         Valor    |   Qtde           Valor    |"
    //        99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99   99,999,999.99
    //        0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\
    fQuery()
    dbSelectArea("TRB")
    dbGotop()
    nReg 	   := 0
    dbEval({|| nReg++})
    SetRegua(nReg)
    dbGotop()

    If li > 70
        cabec(titulo,cabec1,cabec2,nomeprog,tamanho,1)
    Endif

    // Inicializa totais
    nTQtdVend   := 0
    nTVlrVend   := 0
    nTQtdTransf := 0     
    nTVlrTransf := 0
    nTQtdRem    := 0
    nTVlrRem    := 0
    nTQtdFatTd  := 0
    nTVlrFatTd  := 0
    nTQtdDev    := 0
    nTVlrDev    := 0
    nTQtdDevREM := 0
    nTVlrDevREM := 0
    nTQtdDevFTD := 0
    nTVlrDevFTD := 0

    While ! Eof()
        IncRegua()
        IF li > 70
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,1)
        EndIF

        // Impressão dos dados por dia
        @li, 00  PSAY TRB->DIA
        @li, 03  PSAY '|'
        @li, 04  PSAY TRB->QTDE_VENDIDA  PICTURE "@E 99,999,999.99"
        @li, 16  PSAY TRB->VLR_VENDIDO   PICTURE "@E 999,999,999.99"
        @li, 30  PSAY '|'
        @li, 30  PSAY TRB->QTDETRANSF    PICTURE "@E 99,999,999.99"
        @li, 45  PSAY '|'
        @li, 44  PSAY TRB->QTDREM        PICTURE "@E 99,999,999.99"
        @li, 56  PSAY TRB->VLRREM        PICTURE "@E 999,999,999.99"
        @li, 70  PSAY '|'
        @li, 68  PSAY TRB->QTDFATTD      PICTURE "@E 99,999,999.99"
        @li, 80  PSAY TRB->VLRFATTD      PICTURE "@E 999,999,999.99"
        @li, 94  PSAY '|'
        @li, 93  PSAY IIF(TRB->QTDDEV > 0 , -TRB->QTDDEV, TRB->QTDDEV)  PICTURE "@E 99,999,999.99"
        @li,105  PSAY IIF(TRB->VLRDEV > 0 , -TRB->VLRDEV, TRB->VLRDEV)  PICTURE "@E 999,999,999.99"
        @li,121  PSAY '|'
        @li,118  PSAY IIF(TRB->QTDDEVREM > 0 , -TRB->QTDDEVREM, TRB->QTDDEVREM)  PICTURE "@E 99,999,999.99"
        @li,128  PSAY IIF(TRB->VLRDEVREM > 0 , -TRB->VLRDEVREM, TRB->VLRDEVREM)  PICTURE "@E 999,999,999.99"
        @li,144  PSAY '|'
        @li,141   PSAY IIF(TRB->QTDDEVFTD > 0 , -TRB->QTDDEVFTD, TRB->QTDDEVFTD)  PICTURE "@E 99,999,999.99"
        @li,152   PSAY IIF(TRB->VLRDEVFTD > 0 , -TRB->VLRDEVFTD, TRB->VLRDEVFTD)  PICTURE "@E 999,999,999.99"
        @li,167  PSAY '|'
        @li,166  PSAY (TRB->QTDE_VENDIDA+TRB->QTDETRANSF+TRB->QTDREM)-(TRB->QTDDEV)-(TRB->QTDDEVREM) PICTURE "@E 99,999,999.99"
        @li,178  PSAY (TRB->VLR_VENDIDO+TRB->VLRREM)-(TRB->VLRDEV)-(TRB->VLRDEVREM) PICTURE "@E 999,999,999.99"
        @li,193  PSAY '|'
        @li,193  PSAY (TRB->QTDE_VENDIDA+TRB->QTDFATTD)-(TRB->QTDDEV)-(TRB->QTDDEVFTD) PICTURE "@E 99,999,999.99"
        @li,205  PSAY (TRB->VLR_VENDIDO+TRB->VLRFATTD)-(TRB->VLRDEV)-(TRB->VLRDEVFTD) PICTURE "@E 999,999,999.99"
        @li,219  PSAY '|'

        li++

        // Soma totais
        nTQtdVend   += TRB->QTDE_VENDIDA
        nTVlrVend   += TRB->VLR_VENDIDO
        nTQtdTransf += TRB->QTDETRANSF   
        nTVlrTransf += TRB->VLRTRANSF    
        nTQtdRem    += TRB->QTDREM
        nTVlrRem    += TRB->VLRREM
        nTQtdFatTd  += TRB->QTDFATTD
        nTVlrFatTd  += TRB->VLRFATTD
        nTQtdDev    += TRB->QTDDEV
        nTVlrDev    += TRB->VLRDEV
        nTQtdDevREM += TRB->QTDDEVREM
        nTVlrDevREM += TRB->VLRDEVREM
        nTQtdDevFTD += TRB->QTDDEVFTD
        nTVlrDevFTD += TRB->VLRDEVFTD

        dbSkip()
    Enddo

   // Impressão dos totais finais
    If li != 80
        If li > 70
            cabec(titulo,cabec1,cabec2,nomeprog,tamanho,1)
        Endif
        li++
        @ Li, 000 PSAY Replicate("-",220)
        li++
        @li, 03  PSAY '|'
        @li, 04  PSAY nTQtdVend    PICTURE "@E 99,999,999.99"
        @li, 16  PSAY nTVlrVend    PICTURE "@E 999,999,999.99"
        @li, 30  PSAY '|'
        @li, 30  PSAY nTQtdTransf  PICTURE "@E 99,999,999.99"
        @li, 45  PSAY '|'
        @li, 44  PSAY nTQtdRem     PICTURE "@E 99,999,999.99"
        @li, 56  PSAY nTVlrRem     PICTURE "@E 999,999,999.99"
        @li, 70  PSAY '|'
        @li, 68  PSAY nTQtdFatTd   PICTURE "@E 99,999,999.99"
        @li, 80  PSAY nTVlrFatTd   PICTURE "@E 999,999,999.99"
        @li, 94  PSAY '|'
        @li, 93  PSAY IIF(nTQtdDev > 0,-nTQtdDev,nTQtdDev)   PICTURE "@E 99,999,999.99"
        @li,105  PSAY IIF(nTVlrDev > 0,-nTVlrDev,nTVlrDev)   PICTURE "@E 999,999,999.99"
        @li,121  PSAY '|'
        @li,118  PSAY IIF(nTQtdDevREM > 0,-nTQtdDevREM,nTQtdDevREM)   PICTURE "@E 99,999,999.99"
        @li,128  PSAY IIF(nTVlrDevREM > 0,-nTVlrDevREM,nTVlrDevREM)   PICTURE "@E 999,999,999.99"
        @li,144  PSAY '|'
        @li,141  PSAY IIF(nTQtdDevFTD > 0,-nTQtdDevFTD,nTQtdDevFTD)   PICTURE "@E 99,999,999.99"
        @li,152  PSAY IIF(nTVlrDevFTD > 0,-nTVlrDevFTD,nTVlrDevFTD)   PICTURE "@E 999,999,999.99"
        @li,167  PSAY '|'
        @li,166  PSAY (nTQtdVend+nTQtdTransf+nTQtdRem)-(nTQtdDev)-(nTQtdDevREM) PICTURE "@E 99,999,999.99"
        @li,178  PSAY (nTVlrVend+nTVlrRem)-(nTVlrDev)-(nTVlrDevREM) PICTURE "@E 999,999,999.99"
        @li,193  PSAY '|'
        @li,193  PSAY (nTQtdVend+nTQtdFatTd)-(nTQtdDev)-(nTQtdDevFTD) PICTURE "@E 99,999,999.99"
        @li,205  PSAY (nTVlrVend+nTVlrFatTd)-(nTVlrDev)-(nTVlrDevFTD) PICTURE "@E 999,999,999.99"
        @li,219  PSAY '|'
        li++
        @Li, 000 PSAY Replicate("-",220)
        li++
    EndIF

    Roda(nCntImpr,cRodaTxt,Tamanho)

    TRB->(dbCloseArea())
    TCDelFile("TRB")

Return


/*-------------------------------------------------------------------------------*
 | Static Function : fQuery                                                      |
 | Uso             : Monta e executa a query de vendas diárias e transferências  |
 *-------------------------------------------------------------------------------*/
Static Function fQuery()

    Local cQuery := ""

    // Vendas, remessa, fatura tudo, devoluções, devolução remessa, devolução fatura tudo, transferência
    cQuery += "SELECT DIA, "
    cQuery += "QTDE_VENDIDA = SUM(QTDE_VENDIDA), VLR_VENDIDO = SUM(VLR_VENDIDO), "
    cQuery += "QTDREM = SUM(QTDREM), VLRREM = SUM(VLRREM), "
    cQuery += "QTDFATTD = SUM(QTDFATTD), VLRFATTD = SUM(VLRFATTD), "
    cQuery += "QTDDEV = SUM(QTDDEV), VLRDEV = SUM(VLRDEV), "
    cQuery += "QTDDEVREM = SUM(QTDDEVREM), VLRDEVREM = SUM(VLRDEVREM), "
    cQuery += "QTDDEVFTD = SUM(QTDDEVFTD), VLRDEVFTD = SUM(VLRDEVFTD), "
    cQuery += "QTDETRANSF = SUM(QTDETRANSF), VLRTRANSF = SUM(VLRTRANSF) "
    cQuery += "FROM ( "

    // Vendas (Pedidos SC5/SC6) - usando lógica do RFATR37 adaptada
    cQuery += "SELECT DAY(SC5.C5_EMISSAO) AS DIA, "
    cQuery += "SUM(CASE WHEN SB1.B1_TIPO = 'PA' THEN (SC6.C6_QTDVEN * SB1.B1_PESO) ELSE 0 END) AS QTDE_VENDIDA, "
    cQuery += "SUM(SC6.C6_VALOR) AS VLR_VENDIDO, "
    cQuery += "0 AS QTDREM, 0 AS VLRREM, "
    cQuery += "0 AS QTDFATTD, 0 AS VLRFATTD, "
    cQuery += "0 AS QTDDEV, 0 AS VLRDEV, "
    cQuery += "0 AS QTDDEVREM, 0 AS VLRDEVREM, "
    cQuery += "0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "0 AS QTDETRANSF, 0 AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SC5") + " SC5 INNER JOIN "
    cQuery += RetSqlName("SC6") + " SC6 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL INNER JOIN "
    cQuery += RetSqlName("SF4") + " SF4 ON SC6.C6_TES = SF4.F4_CODIGO INNER JOIN "
    cQuery += RetSqlName("SA1") + " SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA INNER JOIN "
    cQuery += RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
    cQuery += "WHERE MONTH(SC5.C5_EMISSAO) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SC5.C5_EMISSAO) = '" + mv_par02 + "' "
    cQuery += "AND SC5.C5_TIPOSAI NOT IN ('S','D') "
    cQuery += "AND SC5.C5_TIPO NOT IN ('B', 'D','P','I') "
    cQuery += "AND SF4.F4_ESTOQUE = 'S' "
    cQuery += "AND SB1.B1_TIPO IN ('PA', 'PR') "
    cQuery += "AND SC5.C5_CLIENTE NOT IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
    cQuery += "AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += "AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
    cQuery += "AND SC5.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SC5.C5_EMISSAO) "

    cQuery += " UNION "

    // Remessa  
    cQuery += "SELECT DAY(SC5.C5_EMISSAO) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, "
    cQuery += "SUM(SC6.C6_QTDVEN) AS QTDREM, "
    cQuery += "SUM(SC6.C6_VALOR) AS VLRREM, "
    cQuery += "0 AS QTDFATTD, 0 AS VLRFATTD, "
    cQuery += "0 AS QTDDEV, 0 AS VLRDEV, "
    cQuery += "0 AS QTDDEVREM, 0 AS VLRDEVREM, "
    cQuery += "0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "0 AS QTDETRANSF, 0 AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SC5") + " SC5 INNER JOIN "
    cQuery += RetSqlName("SC6") + " SC6 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL "
    cQuery += "WHERE MONTH(SC5.C5_EMISSAO) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SC5.C5_EMISSAO) = '" + mv_par02 + "' "
    cQuery += "AND SC5.C5_TIPOSAI = 'E' "
    cQuery += "AND SC5.C5_TIPO NOT IN ('B', 'D','P','I') "
    cQuery += "AND SC5.C5_CLIENTE NOT IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
    cQuery += "AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += "AND SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SC5.C5_EMISSAO) "

    cQuery += " UNION "

    // Fatura Tudo
    cQuery += "SELECT DAY(SC5.C5_EMISSAO) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, "
    cQuery += "0 AS QTDREM, 0 AS VLRREM, "
    cQuery += "SUM(SC6.C6_QTDVEN) AS QTDFATTD, "
    cQuery += "SUM(SC6.C6_VALOR) AS VLRFATTD, "
    cQuery += "0 AS QTDDEV, 0 AS VLRDEV, "
    cQuery += "0 AS QTDDEVREM, 0 AS VLRDEVREM, "
    cQuery += "0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "0 AS QTDETRANSF, 0 AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SC5") + " SC5 INNER JOIN "
    cQuery += RetSqlName("SC6") + " SC6 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL "
    cQuery += "WHERE MONTH(SC5.C5_EMISSAO) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SC5.C5_EMISSAO) = '" + mv_par02 + "' "
    cQuery += "AND SC5.C5_TIPOSAI = 'D' "
    cQuery += "AND SC5.C5_TIPO NOT IN ('B', 'D','P','I') "
    cQuery += "AND SC5.C5_CLIENTE NOT IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
    cQuery += "AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += "AND SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SC5.C5_EMISSAO) "

    cQuery += " UNION "

    // Devolução - usando lógica do RFATR37 (SF1/SD1)
    cQuery += "SELECT DAY(SF1.F1_DTDIGIT) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, 0 AS QTDREM, 0 AS VLRREM, 0 AS QTDFATTD, 0 AS VLRFATTD, "
    cQuery += "SUM(CASE WHEN SB1.B1_TIPO = 'PA' THEN (SD1.D1_QUANT * SB1.B1_PESO) ELSE 0 END) AS QTDDEV, "
    cQuery += "SUM(SD1.D1_TOTAL - SD1.D1_VALDESC) AS VLRDEV, "
    cQuery += "0 AS QTDDEVREM, 0 AS VLRDEVREM, 0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "0 AS QTDETRANSF, 0 AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SF1") + " SF1 INNER JOIN "
    cQuery += RetSqlName("SD1") + " SD1 ON SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE "
    cQuery += "AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA INNER JOIN "
    cQuery += RetSqlName("SF4") + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO INNER JOIN "
    cQuery += RetSqlName("SB1") + " SB1 ON SD1.D1_COD = SB1.B1_COD "
    cQuery += "WHERE MONTH(SF1.F1_DTDIGIT) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SF1.F1_DTDIGIT) = '" + mv_par02 + "' "
    cQuery += "AND SD1.D1_TIPO = 'D' "
    cQuery += "AND SB1.B1_TIPO IN ('PA', 'PR') "
    cQuery += "AND SF4.F4_DUPLIC = 'S' "
    cQuery += "AND SF4.F4_ESTOQUE = 'S' "
    cQuery += "AND SF1.F1_FORNECE NOT IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
    cQuery += "AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
    cQuery += "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += "AND SF1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SF1.F1_DTDIGIT) "

    cQuery += " UNION "

    // Devolução Remessa - usando lógica do RFATR37 (SF1/SD1)
    cQuery += "SELECT DAY(SF1.F1_DTDIGIT) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, 0 AS QTDREM, 0 AS VLRREM, 0 AS QTDFATTD, 0 AS VLRFATTD, 0 AS QTDDEV, 0 AS VLRDEV, "
    cQuery += "SUM(CASE WHEN SB1.B1_TIPO = 'PA' THEN (SD1.D1_QUANT * SB1.B1_PESO) ELSE 0 END) AS QTDDEVREM, "
    cQuery += "SUM(SD1.D1_TOTAL - SD1.D1_VALDESC) AS VLRDEVREM, "
    cQuery += "0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "0 AS QTDETRANSF, 0 AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SF1") + " SF1 INNER JOIN "
    cQuery += RetSqlName("SD1") + " SD1 ON SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE "
    cQuery += "AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA INNER JOIN "
    cQuery += RetSqlName("SF4") + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO INNER JOIN "
    cQuery += RetSqlName("SB1") + " SB1 ON SD1.D1_COD = SB1.B1_COD "
    cQuery += "WHERE MONTH(SF1.F1_DTDIGIT) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SF1.F1_DTDIGIT) = '" + mv_par02 + "' "
    cQuery += "AND SD1.D1_TIPO = 'D' "
    cQuery += "AND SB1.B1_TIPO IN ('PA', 'PR') "
    cQuery += "AND SF4.F4_ESTOQUE = 'S' "
    cQuery += "AND SD1.D1_FILIAL+SD1.D1_FORNECE+SD1.D1_LOJA+SD1.D1_NFORI+SD1.D1_SERIORI+SD1.D1_ITEMORI IN "
    cQuery += "(SELECT SD2.D2_FILIAL+SD2.D2_CLIENTE+SD2.D2_LOJA+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_ITEM FROM " + RetSqlName("SD2") + " SD2 "
    cQuery += "WHERE SD2.D_E_L_E_T_ = '' AND SD1.D1_FILIAL+SD1.D1_FORNECE+SD1.D1_LOJA+SD1.D1_NFORI+SD1.D1_SERIORI+SD1.D1_ITEMORI = SD2.D2_FILIAL+SD2.D2_CLIENTE+SD2.D2_LOJA+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_ITEM AND SD2.D2_CF IN ('5116','6116')) "
    cQuery += "AND SF1.F1_FORNECE NOT IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
    cQuery += "AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
    cQuery += "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += "AND SF1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SF1.F1_DTDIGIT) "

    cQuery += " UNION "

    // Devolução Fatura Tudo - usando lógica do RFATR37 (SF1/SD1)
    cQuery += "SELECT DAY(SF1.F1_DTDIGIT) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, 0 AS QTDREM, 0 AS VLRREM, 0 AS QTDFATTD, 0 AS VLRFATTD, 0 AS QTDDEV, 0 AS VLRDEV, 0 AS QTDDEVREM, 0 AS VLRDEVREM, "
    cQuery += "SUM(CASE WHEN SB1.B1_TIPO = 'PA' THEN (SD1.D1_QUANT * SB1.B1_PESO) ELSE 0 END) AS QTDDEVFTD, "
    cQuery += "SUM(SD1.D1_TOTAL - SD1.D1_VALDESC) AS VLRDEVFTD, "
    cQuery += "0 AS QTDETRANSF, 0 AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SF1") + " SF1 INNER JOIN "
    cQuery += RetSqlName("SD1") + " SD1 ON SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE "
    cQuery += "AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA INNER JOIN "
    cQuery += RetSqlName("SF4") + " SF4 ON SD1.D1_TES = SF4.F4_CODIGO INNER JOIN "
    cQuery += RetSqlName("SB1") + " SB1 ON SD1.D1_COD = SB1.B1_COD "
    cQuery += "WHERE MONTH(SF1.F1_DTDIGIT) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SF1.F1_DTDIGIT) = '" + mv_par02 + "' "
    cQuery += "AND SD1.D1_TIPO = 'D' "
    cQuery += "AND SB1.B1_TIPO IN ('PA', 'PR') "
    cQuery += "AND SF4.F4_DUPLIC = 'S' "
    cQuery += "AND SD1.D1_FILIAL+SD1.D1_FORNECE+SD1.D1_LOJA+SD1.D1_NFORI+SD1.D1_SERIORI+SD1.D1_ITEMORI IN "
    cQuery += "(SELECT SD2.D2_FILIAL+SD2.D2_CLIENTE+SD2.D2_LOJA+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_ITEM FROM " + RetSqlName("SD2") + " SD2 "
    cQuery += "WHERE SD2.D_E_L_E_T_ = '' AND SD1.D1_FILIAL+SD1.D1_FORNECE+SD1.D1_LOJA+SD1.D1_NFORI+SD1.D1_SERIORI+SD1.D1_ITEMORI = SD2.D2_FILIAL+SD2.D2_CLIENTE+SD2.D2_LOJA+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_ITEM AND SD2.D2_CF IN ('5922','6922')) "
    cQuery += "AND SF1.F1_FORNECE NOT IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
    cQuery += "AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
    cQuery += "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += "AND SF1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SF1.F1_DTDIGIT) "

    cQuery += " UNION "

    // Transferência - Usando a mesma lógica do RFATR37 adaptada para SC5/SC6
    cQuery += "SELECT DAY(SC5.C5_EMISSAO) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, 0 AS QTDREM, 0 AS VLRREM, 0 AS QTDFATTD, 0 AS VLRFATTD, 0 AS QTDDEV, 0 AS VLRDEV, 0 AS QTDDEVREM, 0 AS VLRDEVREM, 0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "SUM(CASE WHEN SB1.B1_TIPO = 'PA' THEN (SC6.C6_QTDVEN * SB1.B1_PESO) ELSE 0 END) AS QTDETRANSF, "
    cQuery += "SUM(SC6.C6_VALOR) AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SC5") + " SC5 INNER JOIN "
    cQuery += RetSqlName("SC6") + " SC6 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL INNER JOIN "
    cQuery += RetSqlName("SF4") + " SF4 ON SC6.C6_TES = SF4.F4_CODIGO INNER JOIN "
    cQuery += RetSqlName("SA1") + " SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA INNER JOIN "
    cQuery += RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
    cQuery += "WHERE MONTH(SC5.C5_EMISSAO) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SC5.C5_EMISSAO) = '" + mv_par02 + "' "
    cQuery += "AND SF4.F4_ESTOQUE = 'S' "
    cQuery += "AND SC5.C5_TIPO NOT IN ('B', 'D','P','I') "
    cQuery += "AND SB1.B1_TIPO IN ('PA', 'PR') "
    cQuery += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
    cQuery += "AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += "AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
    cQuery += "AND SC5.C5_CLIENTE IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SC5.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SC5.C5_EMISSAO) "

    cQuery += " UNION "

    // Devolução de Transferência - Usando a mesma lógica do RFATR37 adaptada para SC5/SC6 (valor negativo)
    cQuery += "SELECT DAY(SC5.C5_EMISSAO) AS DIA, "
    cQuery += "0 AS QTDE_VENDIDA, 0 AS VLR_VENDIDO, 0 AS QTDREM, 0 AS VLRREM, 0 AS QTDFATTD, 0 AS VLRFATTD, 0 AS QTDDEV, 0 AS VLRDEV, 0 AS QTDDEVREM, 0 AS VLRDEVREM, 0 AS QTDDEVFTD, 0 AS VLRDEVFTD, "
    cQuery += "SUM(CASE WHEN SB1.B1_TIPO = 'PA' THEN (SC6.C6_QTDVEN * SB1.B1_PESO) * -1 ELSE 0 END) AS QTDETRANSF, "
    cQuery += "SUM(SC6.C6_VALOR * -1) AS VLRTRANSF "
    cQuery += "FROM " + RetSqlName("SC5") + " SC5 INNER JOIN "
    cQuery += RetSqlName("SC6") + " SC6 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL INNER JOIN "
    cQuery += RetSqlName("SF4") + " SF4 ON SC6.C6_TES = SF4.F4_CODIGO INNER JOIN "
    cQuery += RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
    cQuery += "WHERE MONTH(SC5.C5_EMISSAO) = '" + mv_par01 + "' "
    cQuery += "AND YEAR(SC5.C5_EMISSAO) = '" + mv_par02 + "' "
    cQuery += "AND SC5.C5_TIPO = 'D' "
    cQuery += "AND (SC6.C6_TES = '5922' OR SC6.C6_TES = '6922') "
    cQuery += "AND SB1.B1_TIPO IN ('PA','PR') "
    cQuery += "AND SF4.F4_ESTOQUE = 'S' "
    cQuery += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
    cQuery += "AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
    cQuery += "AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += "AND SC5.C5_CLIENTE IN ('314844','319030','091773','180268','091542','321807','090003','305774','090004','300948','319222','010981','383587') "
    cQuery += "AND SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY DAY(SC5.C5_EMISSAO) "

    cQuery += ") AS FAT "
    cQuery += "GROUP BY DIA "
    cQuery += "ORDER BY DIA "

    cQuery := ChangeQuery(cQuery)

    IF Select("TRB") <> 0
        DbSelectArea("TRB")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery Alias TRB New
    TcSetField("TRB","QTDE_VENDIDA","N",12,2)
    TcSetField("TRB","VLR_VENDIDO","N",12,2)
    TcSetField("TRB","QTDREM","N",12,2)
    TcSetField("TRB","VLRREM","N",12,2)
    TcSetField("TRB","QTDFATTD","N",12,2)
    TcSetField("TRB","VLRFATTD","N",12,2)
    TcSetField("TRB","QTDDEV","N",12,2)
    TcSetField("TRB","VLRDEV","N",12,2)
    TcSetField("TRB","QTDDEVREM","N",12,2)
    TcSetField("TRB","VLRDEVREM","N",12,2)
    TcSetField("TRB","QTDDEVFTD","N",12,2)
    TcSetField("TRB","VLRDEVFTD","N",12,2)
    TcSetField("TRB","QTDETRANSF","N",12,2)
    TcSetField("TRB","VLRTRANSF","N",12,2)

Return


/*-------------------------------------------------------------------------------*
 | Static Function : ValidSX1                                                    |
 | Uso             : Validação das perguntas SX1 (não cria perguntas dinâmicas)  |
 *-------------------------------------------------------------------------------*/
 static function ValidSX1()

Local aPergs 	:= {}

Aadd(aPergs,{"Mes Desejado?          ","","","mv_ch1","C", 2,0,0,"G",,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ano Desejado?          ","","","mv_ch2","C", 4,0,0,"G",,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Moeda?                 ","","","mv_ch3","N", 1,0,0,"C",,"mv_par03","Moeda1","Moeda1","Moeda1","","","Moeda2","Moeda2","Moeda2","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Considera Nota p/Grupo?","","","mv_ch4","N", 1,0,0,"C",,"mv_par04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","",""})

//AjustaSx1("RFAT37",aPergs)

return

/*-------------------------------------------------------------------------------*
 | Static Function : SchedDef                                                    |
 | Uso             : Parâmetros para agendamento do relatório no Protheus        |
 *-------------------------------------------------------------------------------*/
 Static Function SchedDef()

    Local aOrd  := {}
    Local aPar  := {}
    Local cPerg := "RFAT37" // Pergunta do relatorio ou processo

   aPar := {"R"  ,;         // Tipo R para relatorio e P para processo
            cPerg,;         // Pergunte do relatorio ou processo
            "SC5",;         // Alias
            aOrd,  ;        // Array de ordens de impressao do relatorio
            "Relatorio de Vendas Diarias"  }

Return(aPar)

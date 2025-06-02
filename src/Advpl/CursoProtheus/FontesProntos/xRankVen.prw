#Include "protheus.ch"  
#Include "TopConn.ch"
#Include "TOTVS.CH"
#Include "MsOle.ch"
#Include "Report.ch"                 
#Include "SHELL.CH"
#Include "FWPrintSetup.ch"
#Include "TBICONN.CH"
#Include "RPTDEF.CH"
#Include "Colors.ch"
#Include 'parmtype.ch'

#Define TOT_KG 1
#Define TOT_VALOR 2
#Define TOT_QTD1UM 3
#Define TOT_QTD2UM 4
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)

/*/{Protheus.doc} xRankVen
    Relatório traz os produtos mais vendidos dentro de um determinado periodo. 
    Traz valor de venda, quantidade na 1º unidade de medida, na 2º unidade de medida e em quilos.    
    Observação: Relatório não faz abatimento de devoluções de venda.			

    @author  	Súlivan      
    @since  	19/12/2021 
    @version    1.0
    @return 	Undefinied
/*/
User Function xRankVen()

    Local aArea := GetArea()
	Local cPerg := "XRANKVEN"
    Private nTotAux_ := 0
	
	If( Pergunte(cPerg)	)	
		 Processa( {|| xRankVen_() },;
                   "Aguarde...",;
                   "Processando informações... ",;
                   .F. )
	Endif    
				
	RestArea(aArea)	 
Return

//-------------------------------------
/*/{Protheus.doc} xRankVen_
Executa o processamento do relatório.
@author     Súlivan
@since      19/12/2021
/*/
//-------------------------------------
Static Function xRankVen_()

	Local aArea	   	 := GetArea()
	Local lAcao		 := .T. //.F. = Altera, .T.= Inclui
	Local oTempTable := Nil
	Local cTempTable := ""
	Local cAliasQry	 := ""
    Local cQry       := ""
    Local cAliasMain := "TEMPXRANKVEN_"+FWTimeStamp(1)
    Local aOrdens    := {"PRODUTO", "VLR_TOTAL DESC", "QTD_1UM DESC", "QTD_2UM DESC", "CFOP"}

	//Parametros
    Private nOrdem_         := MV_PAR01
	Private dDaEmissao_	    := MV_PAR02 
	Private dAteEmissao_    := MV_PAR03 
    Private cDoProduto_     := MV_PAR04
    Private cAteProduto_    := MV_PAR05
    Private cDoCFOP_        := MV_PAR06
    Private cAteCFOP_       := MV_PAR07	
    Private nTesEst_        := MV_PAR08 //1=Movimenta estoque; 2=Não movimenta; 3=Ambas
    Private nTesFin_        := MV_PAR09 //1=Gera financeiro; 2=Não gera; 3=Ambas
	Private lJuntaCFOP_     := MV_PAR10==2 //1=Separa por Produto; 2=Separa por Produto x CFOP

    //Ajusta os parametros caso não estejam coerentes
    //A ordenação pode ser por CFOP caso o relatório esteja separando por CFOP
    nOrdem_ := Iif(lJuntaCFOP_ .And. nOrdem_ == 5, 1, nOrdem_)
    nOrdem_ := Iif(!lJuntaCFOP_.And. nOrdem_ != 5, 5, nOrdem_)

	//Constrói estrutura da temporária
	cTempTable := fBuildTmp(@oTempTable) 
	
	//Pega result set da query principal
	cAliasQry := fExecQry() 
			
    IncProc("Populando tabela temporária..") 
	DbSelectArea(cTempTable)								
    (cAliasQry)->(DbGoTop())
	While !(cAliasQry)->( Eof() ) 
			
		If RecLock(cTempTable, lAcao) 
			
			(cTempTable)->PRODUTO	:= (cAliasQry)->D2_COD
			(cTempTable)->DESCRICAO	:= Posicione("SB1",1,FWxFilial("SB1")+(cAliasQry)->D2_COD,"B1_DESC")
			(cTempTable)->VLR_TOTAL	:= (cAliasQry)->D2_TOTAL
			(cTempTable)->UM_1	    := (cAliasQry)->D2_UM
			(cTempTable)->QTD_1UM	:= (cAliasQry)->D2_QUANT
            (cTempTable)->UM_2	    := (cAliasQry)->D2_SEGUM
			(cTempTable)->QTD_2UM	:= (cAliasQry)->D2_QTSEGUM 
			(cTempTable)->QTD_KG	:= (cAliasQry)->D2_PESO 
			(cTempTable)->CFOP  	:= (cAliasQry)->D2_CF
			(cTempTable)->( MsUnLock() ) 	
		Endif
		
		(cAliasQry)->( DbSkip() )
	Enddo	
	(cAliasQry)->( DbCloseArea() )
    
    IncProc("Consultando temporária e ordenando informações..") 
    cQry:= " SELECT PRODUTO, "
    cQry+= "        DESCRICAO, "
    cQry+= Iif(lJuntaCFOP_, " ", " CFOP, ")
    cQry+= "        SUM(VLR_TOTAL) AS VLR_TOTAL, "
	cQry+= "        UM_1, "
	cQry+= "        SUM(QTD_1UM) AS QTD_1UM, "
	cQry+= "        UM_2, "
	cQry+= "        SUM(QTD_2UM) AS QTD_2UM, "
	cQry+= "        SUM(QTD_KG)  AS QTD_KG "
    cQry+= " FROM "+oTempTable:GetRealName()
    cQry+= " GROUP BY PRODUTO, DESCRICAO, UM_1, UM_2 " + Iif(lJuntaCFOP_, " ", " ,CFOP ")
    cQry+= " ORDER BY "+aOrdens[nOrdem_]
    
    cQry:=ChangeQuery(cQry)
    VarInfo(FunName()+" Query 2 -> ",cQry)
    TCQuery cQry New Alias (cAliasMain)

	//Aciona a impressão.
	fPrintPDF( cAliasMain, oTempTable:GetRealName() )
	
	oTempTable:Delete()
	FreeObj(oTempTable)
	RestArea(aArea)
Return 

//-------------------------------------
/*/{Protheus.doc} fBuildTmp
Constrói tabela temporária.
@author     Súlivan
@since      19/12/2021
@param		Object, Endereço do content da temporária
@return 	Character, nome da tabela criada.	
/*/
//-------------------------------------
Static Function fBuildTmp(oTempTable)

	Local cAliasTemp := "XRANKVEN_"+FWTimeStamp(1)
	Local aFields    := {}
		
	//Monta estrutura de campos da temporária
	aAdd(aFields, { "PRODUTO"  , GetSx3Cache("D2_COD"    ,"X3_TIPO"), GetSx3Cache("D2_COD"     ,"X3_TAMANHO"), GetSx3Cache("D2_COD"    ,"X3_DECIMAL")  })
    aAdd(aFields, { "DESCRICAO", GetSx3Cache("B1_DESC"   ,"X3_TIPO"), GetSx3Cache("B1_DESC"    ,"X3_TAMANHO"), GetSx3Cache("B1_DESC"   ,"X3_DECIMAL")  })
	aAdd(aFields, { "VLR_TOTAL", GetSx3Cache("D2_TOTAL"  ,"X3_TIPO"), GetSx3Cache("D2_TOTAL"   ,"X3_TAMANHO"), GetSx3Cache("D2_TOTAL"  ,"X3_DECIMAL")  })
    aAdd(aFields, { "UM_1"     , GetSx3Cache("D2_UM"     ,"X3_TIPO"), GetSx3Cache("D2_UM"      ,"X3_TAMANHO"), GetSx3Cache("D2_UM"     ,"X3_DECIMAL")  })
    aAdd(aFields, { "QTD_1UM"  , GetSx3Cache("D2_QUANT"  ,"X3_TIPO"), GetSx3Cache("D2_QUANT"   ,"X3_TAMANHO"), GetSx3Cache("D2_QUANT"  ,"X3_DECIMAL")  })
    aAdd(aFields, { "UM_2"     , GetSx3Cache("D2_UM"     ,"X3_TIPO"), GetSx3Cache("D2_UM"      ,"X3_TAMANHO"), GetSx3Cache("D2_UM"     ,"X3_DECIMAL")  })
    aAdd(aFields, { "QTD_2UM"  , GetSx3Cache("D2_QTSEGUM","X3_TIPO"), GetSx3Cache("D2_QTSEGUM" ,"X3_TAMANHO"), GetSx3Cache("D2_QTSEGUM","X3_DECIMAL")  })
    aAdd(aFields, { "QTD_KG"   , GetSx3Cache("D2_PESO"   ,"X3_TIPO"), GetSx3Cache("D2_PESO"    ,"X3_TAMANHO"), GetSx3Cache("D2_PESO"   ,"X3_DECIMAL")  })			
    aAdd(aFields, { "CFOP"     , GetSx3Cache("D2_CF"     ,"X3_TIPO"), GetSx3Cache("D2_CF"      ,"X3_TAMANHO"), GetSx3Cache("D2_CF"     ,"X3_DECIMAL")  })			
	
	oTempTable:= FWTemporaryTable():New(cAliasTemp)
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("01", {"PRODUTO"} )	
	oTempTable:Create()	

Return oTempTable:GetAlias()

//-------------------------------------
/*/{Protheus.doc} fExecQry
Executa a query que comporá o relatório
@author     Súlivan
@since      19/12/2021
@return 	Character, nome do alias da query	
/*/
//-------------------------------------
Static function fExecQry()
	
	Local cQry    	 := "" 
	Local cAliasTemp := "TBRXRANKVEN_"+FWTimeStamp(1)
	Local cFilSD2    := FWxFilial("SD2")
	Local cFilSF4    := FWxFilial("SF4")
	Local cNameSD2   := RetSqlName("SD2")
	Local cNameSF4   := RetSqlName("SF4")
    Local aEstoque   := {"'S'","'N'","'N','S'"}
    Local aFinanceiro:= {"'S'","'N'","'N','S'"}

    ProcRegua(nTotAux_)
    IncProc("Montando consulta principal do relatório..")

	cQry:= " SELECT D2_COD, "
    cQry+= "        SUM(D2_TOTAL) AS D2_TOTAL, "
	cQry+= "        D2_UM, "
	cQry+= "        SUM(D2_QUANT) AS D2_QUANT, "
	cQry+= "        D2_SEGUM, "
	cQry+= "        SUM(D2_QTSEGUM) AS D2_QTSEGUM, "
	cQry+= "        SUM(D2_PESO) AS D2_PESO,
    cQry+= "        D2_CF "
    cQry+= " FROM "+cNameSD2+" AS SD2 "
    cQry+= " INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D2_TES "
    cQry+= " WHERE D2_FILIAL = '"+cFilSD2+"' AND F4_FILIAL = '"+cFilSF4+"' "
    cQry+= "   AND D2_EMISSAO BETWEEN '"+dTos(dDaEmissao_)+"' AND '"+dTos(dAteEmissao_)+"' "
    cQry+= "   AND D2_COD     BETWEEN '"+cDoProduto_      +"' AND '"+cAteProduto_      +"' "
    cQry+= "   AND D2_CF	  BETWEEN '"+cDoCFOP_         +"' AND '"+cAteCFOP_         +"' "
    cQry+= "   AND D2_TIPO = 'N' " //Filtra somente pedidos normais
    cQry+= "   AND F4_ESTOQUE IN ("+aEstoque[nTesEst_]   +") "
    cQry+= "   AND F4_DUPLIC  IN ("+aFinanceiro[nTesFin_]+") "
    cQry+= "   AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' "
    cQry+= " GROUP BY D2_COD, D2_UM, D2_SEGUM, D2_CF "
	
	cQry := ChangeQuery(cQry)	
    VarInfo(FunName()+" Query 1 -> ",cQry)
	TcQuery cQry New Alias (cAliasTemp)
    //Define o tamanho da régua
    Count to nTotAux_
    ProcRegua(nTotAux_)
		
Return cAliasTemp

//-------------------------------------
/*/{Protheus.doc}  fCalcTot
Cálcula os totais do relatório
@author     Súlivan
@since      19/12/2021
@param      Array, aTotais, referencia do array que será populado com totais do estado.	
@param      Character, cTempTable, nome da tabela temporaria do relatório.
@param      Character, cCFOP, cfop que será totalizado, caso não informado será feito o total geral.
/*/
//-------------------------------------
Static Function fCalcTot( aTotais, cTempTable, cCFOP )

	Local cQry 		 := ""
	Local cAliasTemp := "FCALCTOT_"+FWTimeStamp(1)
    
    Default cCFOP:= ''
		
	cQry:= " SELECT SUM(QTD_KG)    AS PESO  , "
	cQry+= " 	    SUM(QTD_1UM)   AS QTD1UM, "
    cQry+= " 	    SUM(QTD_2UM)   AS QTD2UM, "
	cQry+= " 	    SUM(VLR_TOTAL) AS VLRTOT  "
	cQry+= " FROM "+cTempTable
    If !Empty(cCFOP)
        cQry+= " WHERE CFOP = '"+cCFOP+"' "
    EndIf
		
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias (cAliasTemp)
	
	If( !(cAliasTemp)->( Eof() ) )
		
		aTotais[TOT_VALOR ]:= (cAliasTemp)->VLRTOT
        aTotais[TOT_QTD1UM]:= (cAliasTemp)->QTD1UM
		aTotais[TOT_QTD2UM]:= (cAliasTemp)->QTD2UM
		aTotais[TOT_KG    ]:= (cAliasTemp)->PESO
	Endif
	(cAliasTemp)->( DbCloseArea() )
Return 

//-------------------------------------
/*/{Protheus.doc} fPrintPDF
Realiza a montagem e impressão do relatório em PDF
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      19/12/2021
@param      Character, cAliasTmp, nome do alias da tabela temporaria do relatório.
@param      Character, cTempTable, nome da tabela temporaria do relatório.
/*/
//-------------------------------------
Static Function fPrintPDF( cAliasTmp, cTempTable )
	   
    Local nAtuAux      := 0
    Local cArquivo     := FWTimeStamp(1)+"_relatorio produtos mais vendidos.pdf"
    Local cPictureNum1 := GetSx3Cache("D2_TOTAL","X3_PICTURE")
    Local aTotais      := {0/*Peso*/,0/*Valor*/,0/*Quantidade 1Um*/, 0/*Quantidade 2Um*/}
    Local cCFOPAtual   := ""

    Private oPrintPvt  := ""
    Private oBrushAzul := TBRUSH():New(,nCorAzul)
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 580
    Private nColIni    := 010
    Private nColFin    := 815
    Private nEspCol    := (nColFin-(nColIni+150))/13
    Private nColMeio   := (nColFin-nColIni)/2
    //Colunas dos relatorio
    Private nColProd    := nColIni
    Private nColDesc    := nColIni + 050
    Private nColVlrTot  := nColFin - 425
    Private nCol1Unid   := nColFin - 340
    Private nColQtd1UM  := nColFin - 300
    Private nCol2Unid   := nColFin - 200
    Private nColQtd2UM  := nColFin - 150
    Private nColKg      := nColFin - 100
    Private nColCFOP    := nColFin - 030
    //Declarando as fontes
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
        
    (cAliasTmp)->(DbGoTop())
     
    //Somente se tiver dados
    If ! (cAliasTmp)->(EoF())
        //Criando o objeto de impressao
       	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., GetTempPath(), .T., , , @oPrintPvt , , , .F., )
        If(oPrintPvt:nModalResult == PD_CANCEL)
		    FreeObj(oPrintPvt)
            (cAliasTmp)->(DbCloseArea())
		    Return
	    Endif
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetLandscape()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
 
        //Imprime os dados
        fImpCab()
        While ! (cAliasTmp)->(EoF())
            nAtuAux++
            IncProc("Imprimindo registro " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux_) + "...")
 
            //Se atingiu o limite, quebra de pagina
            fQuebra()
             
            //Faz o zebrado ao fundo
            If nAtuAux % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
            EndIf
 
            //Imprime a linha atual
            oPrintPvt:SayAlign(nLinAtu, nColProd  , (cAliasTmp)->PRODUTO                           , oFontDet,  (nColDesc   - nColProd) , 10, , PAD_LEFT  ,  )
            oPrintPvt:SayAlign(nLinAtu, nColDesc  , (cAliasTmp)->DESCRICAO                         , oFontDet,  (nColVlrTot - nColDesc) , 10, , PAD_LEFT  ,  )
            oPrintPvt:SayAlign(nLinAtu, nColVlrTot, Transform((cAliasTmp)->VLR_TOTAL, cPictureNum1), oFontDet,  (nCol1Unid - nColVlrTot), 10, , PAD_RIGHT ,  )
            oPrintPvt:SayAlign(nLinAtu, nCol1Unid , (cAliasTmp)->UM_1                              , oFontDet,  (nColQtd1UM - nCol1Unid), 10, , PAD_RIGHT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColQtd1UM, Transform((cAliasTmp)->QTD_1UM, cPictureNum1)  , oFontDet,  (nCol2Unid - nColQtd1UM), 10, , PAD_RIGHT ,  )
            oPrintPvt:SayAlign(nLinAtu, nCol2Unid , (cAliasTmp)->UM_2                              , oFontDet,  (nColQtd2UM - nCol2Unid), 10, , PAD_RIGHT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColQtd2UM, Transform((cAliasTmp)->QTD_2UM, cPictureNum1)  , oFontDet,  (nColKg - nColQtd2UM)   , 10, , PAD_RIGHT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColKg    , Transform((cAliasTmp)->QTD_KG, cPictureNum1)   , oFontDet,  (nColCFOP - nColKg)     , 10, , PAD_RIGHT,  )
            If !lJuntaCFOP_
                oPrintPvt:SayAlign(nLinAtu, nColCFOP, (cAliasTmp)->CFOP,    oFontDet,  (nColFin - nColCFOP),    10, , PAD_RIGHT,  )
            EndIf
            nLinAtu += 15
            oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)

            //Se atingiu o limite, quebra de pagina
            fQuebra()
            
            //Pega o cfop atual para comparar depois
            If !lJuntaCFOP_
                cCFOPAtual:= (cAliasTmp)->CFOP
            Endif
              
            (cAliasTmp)->(DbSkip())

            //Totalizo por CFOP
            If !lJuntaCFOP_ .And. ( (cAliasTmp)->(Eof()) .Or. (cAliasTmp)->CFOP != cCFOPAtual )
                fCalcTot(@aTotais, cTempTable, cCFOPAtual)		
                oPrintPvt:SayAlign(nLinAtu, nColProd  , "Total do CFOP: "+cCFOPAtual ,    oFontDet,  (nColVlrTot - nColDesc),    10, , PAD_LEFT,  )
                oPrintPvt:SayAlign(nLinAtu, nColVlrTot, Transform(aTotais[TOT_VALOR ], cPictureNum1),    oFontDet,  (nCol1Unid - nColVlrTot),    10, , PAD_RIGHT,  )
                oPrintPvt:SayAlign(nLinAtu, nColQtd1UM, Transform(aTotais[TOT_QTD1UM], cPictureNum1),    oFontDet,  (nCol2Unid - nColQtd1UM),    10, , PAD_RIGHT,  )
                oPrintPvt:SayAlign(nLinAtu, nColQtd2UM, Transform(aTotais[TOT_QTD2UM], cPictureNum1),    oFontDet,  (nColKg    - nColQtd2UM),    10, , PAD_RIGHT,  )
                oPrintPvt:SayAlign(nLinAtu, nColKg    , Transform(aTotais[TOT_KG    ], cPictureNum1),    oFontDet,  (nColCFOP  - nColKg)    ,    10, , PAD_RIGHT,  )
                fImpRod()
                fQuebra( !(cAliasTmp)->(Eof()) )
            EndIf
        EndDo
        fQuebra()

        fCalcTot(@aTotais, cTempTable)		
        nLinAtu+=12
        oPrintPvt:SayAlign(nLinAtu, nColProd  , "Total Geral",    oFontDet,  (nColDesc   - nColProd),    10, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColVlrTot, Transform(aTotais[TOT_VALOR ], cPictureNum1),    oFontDet,  (nCol1Unid - nColVlrTot),    10, , PAD_RIGHT,  )
        oPrintPvt:SayAlign(nLinAtu, nColQtd1UM, Transform(aTotais[TOT_QTD1UM], cPictureNum1),    oFontDet,  (nCol2Unid - nColQtd1UM),    10, , PAD_RIGHT,  )
        oPrintPvt:SayAlign(nLinAtu, nColQtd2UM, Transform(aTotais[TOT_QTD2UM], cPictureNum1),    oFontDet,  (nColKg - nColQtd2UM)   ,    10, , PAD_RIGHT,  )
        oPrintPvt:SayAlign(nLinAtu, nColKg    , Transform(aTotais[TOT_KG    ], cPictureNum1),    oFontDet,  (nColCFOP - nColKg)     ,    10, , PAD_RIGHT,  )
        fImpRod()
        
        IncProc("Abrindo relatório..")
        oPrintPvt:Preview()
    Else
        MsgStop("Não foram encontradas informações com os parâmetros informados!", "Atenção")
    EndIf
    (cAliasTmp)->(DbCloseArea())
    FreeObj(oPrintPvt) 
Return

//-------------------------------------
/*/{Protheus.doc} fImpCab
imprime o cabecalho do relatório
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      19/12/2021
/*/
//------------------------------------- 
Static Function fImpCab()

    Local cTexto   := ""
    Local nLinCab  := 015
     
    //Iniciando Pagina
    oPrintPvt:StartPage()
     
    //Cabecalho
    cTexto := "Produtos mais vendidos"
    oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
    oPrintPvt:SayAlign(nLinCab - 03, nColFin-300, "De: "  + dToc(dDaEmissao_) , oFontDetN,  300, 20, , PAD_RIGHT, )
    oPrintPvt:SayAlign(nLinCab + 07, nColFin-300, "Até: " + dToc(dAteEmissao_), oFontDetN,  300, 20, , PAD_RIGHT, )
     
    //Linha Separatoria
    nLinCab += 020
    oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
     
    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinCab + 5
 
    oPrintPvt:SayAlign(nLinAtu+00, nColProd   ,   "Código"            , oFontMin,  (nColDesc   - nColProd)  ,   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+10, nColProd   ,   "Produto"           , oFontMin,  (nColDesc   - nColProd)  ,   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColDesc   ,   "Descrição"         , oFontMin,  (nColVlrTot - nColDesc)  ,   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColVlrTot ,   "Valor Vendido (R$)", oFontMin,  (nCol1Unid - nColVlrTot) ,   10, nCorCinza, PAD_RIGHT,  )    
    oPrintPvt:SayAlign(nLinAtu+00, nCol1Unid  ,   "1º Unidade"        , oFontMin,  (nColQtd1UM - nCol1Unid) ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nCol1Unid  ,   "de Medida"         , oFontMin,  (nColQtd1UM - nCol1Unid) ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nColQtd1UM ,   "Quantidade"        , oFontMin,  (nCol2Unid  - nColQtd1UM),   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColQtd1UM ,   "1º Unidade"        , oFontMin,  (nCol2Unid  - nColQtd1UM),   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nCol2Unid  ,   "2º Unidade"        , oFontMin,  (nColQtd2UM - nCol2Unid) ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nCol2Unid  ,   "de Medida"         , oFontMin,  (nColQtd2UM - nCol2Unid) ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nColQtd2UM ,   "Quantidade"        , oFontMin,  (nColKg - nColQtd2UM)    ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColQtd2UM ,   "2º Unidade"        , oFontMin,  (nColKg - nColQtd2UM)    ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nColKg     ,   "Quantidade"        , oFontMin,  (nColCFOP - nColKg)      ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColKg     ,   "Em quilos"         , oFontMin,  (nColCFOP - nColKg)      ,   10, nCorCinza, PAD_RIGHT,  )
    If !lJuntaCFOP_
        oPrintPvt:SayAlign(nLinAtu+05, nColCFOP,   "CFOP"     , oFontMin,  (nColFin - nColCFOP   ),   10, nCorCinza, PAD_RIGHT,  )
    EndIf
    nLinAtu += 25
Return
 
//-------------------------------------
/*/{Protheus.doc} fImpRod
imprime o rodape do relatório
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      19/12/2021
/*/
//-------------------------------------
Static Function fImpRod()
    Local nLinRod:= nLinFin
    Local cTexto := ''
 
    //Linha Separatoria
    oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (xRankVen)     " + UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
     
    //Direita
    cTexto := "Pagina "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
     
    //Finalizando a pagina e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return

//-------------------------------------
/*/{Protheus.doc} fQuebra
Realiza a finalização de uma página e inicialização de outra quando necessário.
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      19/12/2021
@param      Logical, lForce, força a finalização de uma página e inicialização de outra 
            mesmo que a página não tenha acabado. Default .F.
/*/
//------------------------------------- 
Static Function fQuebra(lForce)

    Default lForce := .F.

    If lForce .Or. nLinAtu >= nLinFin-10
        fImpRod()
        fImpCab()
    EndIf
Return

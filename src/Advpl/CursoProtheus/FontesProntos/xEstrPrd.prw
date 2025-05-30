#Include "TOTVS.CH"
#Include "TopConn.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
Static oPrintPvt := Nil 
Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)

/*/{Protheus.doc} xEstrPrd
    Relatório traz a estrutura do produto e o saldo em estoque 
    atual dos componentes que a compõe

    @author  	Súlivan      
    @since  	05/01/2022 
    @version    1.0
    @return 	Undefinied
    @see        https://tdn.totvs.com/pages/releaseview.action?pageId=287060852
    @see        https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018659571-MP-ADVPL-FIMESTRUT2-N%C3%83O-FECHA-TABELA-ESTRUT    
    @see        https://tdn.totvs.com/pages/releaseview.action?pageId=287060899
/*/
User Function xEstrPrd()

    Local aArea := GetArea()
	Local cPerg := "XESTRPRD"
    Private nTotAux_ := 0
	
	If( Pergunte(cPerg)	)	
		 Processa( {|| xEstrPrd_() },;
                   "Aguarde...",;
                   "Processando informações... ",;
                   .F. )
	Endif    
				
	RestArea(aArea)	 
Return

//-------------------------------------
/*/{Protheus.doc} xEstrPrd_
Executa o processamento do relatório.
@author     Súlivan
@since      05/01/2022
/*/
//-------------------------------------
Static Function xEstrPrd_()

	Local aArea	   	 := GetArea()
	Local oTempTable := Nil
	Local cAliasEstru:= "TEMPXESTRPRD_"+FWTimeStamp(1)
	Local cAliasQry	 := ""
    Local lAsShow    := .T.

    Private nEstru   := 0 //De uso interno da função Estrut2

	//Parametros
    Private cDoProduto_    := MV_PAR01
    Private cAtProduto_    := MV_PAR02
    Private cDoArmazem_    := MV_PAR03 
    Private cAtArmazem_    := MV_PAR04
    Private nQuantidade_   := MV_PAR05
	
	//Pega result set da query principal
	cAliasQry := fExecQry() 

    //Percorrendo consulta principal
    (cAliasQry)->(DbGoTop())
	While !(cAliasQry)->( Eof() ) 
			
        IncProc("Simulando empenhos do produto "+(cAliasQry)->PRODUTO )
        Estrut2( (cAliasQry)->PRODUTO,;
                 nQuantidade_        ,;
                 cAliasEstru         ,;
                 @oTempTable         ,;
                 lAsShow              )

        IncProc("Imprimindo estrutura do produto "+(cAliasQry)->PRODUTO )
	    fPrintPDF( cAliasEstru )

        //Efetua o fechamento da tabela criada pela Estrut2
        FimEstrut2(@cAliasEstru, @oTempTable)
        nEstru:=0
		(cAliasQry)->( DbSkip() )
	Enddo	
	(cAliasQry)->( DbCloseArea() ) 	

    IncProc("Abrindo relatório..")
    oPrintPvt:Preview()
	
	FreeObj(oTempTable)
    FreeObj(oPrintPvt) 
	RestArea(aArea)
Return 

//-------------------------------------
/*/{Protheus.doc} fExecQry
Executa a query que comporá o relatório
@author     Súlivan
@since      05/01/2022
@return 	Character, nome do alias da query	
/*/
//-------------------------------------
Static function fExecQry()
	
	Local cQry    	 := "" 
	Local cAliasTemp := "TBRXESTRPRD_"+FWTimeStamp(1)
	Local cNameSG1   := RetSqlName("SG1")
	Local cFilSG1    := FWxFilial("SG1")
	
    ProcRegua(nTotAux_)
    IncProc("Montando consulta principal do relatório..")

	cQry:= " SELECT G1_COD AS PRODUTO "
    cQry+= " FROM "+cNameSG1+" AS SG1 "
    cQry+= " WHERE G1_FILIAL = '"+cFilSG1+"' "
    cQry+= "   AND G1_COD BETWEEN '"+cDoProduto_+"' AND '"+cAtProduto_+"' "
    cQry+= "   AND SG1.D_E_L_E_T_ = '' "
	cQry+= " GROUP BY G1_COD "

	cQry := ChangeQuery(cQry)	
    VarInfo(FunName()+" Query 1 -> ",cQry)
	TcQuery cQry New Alias (cAliasTemp)
    //Define o tamanho da régua
    Count to nTotAux_
    ProcRegua(nTotAux_)
		
Return cAliasTemp

//-------------------------------------
/*/{Protheus.doc} fGetSaldo
Pega o saldo total do componente nos armazéns informados nos parametros. 
@author     Súlivan 
@since      08/01/2022
@param      Character, Character, produto componente que será capturado o saldo
@Obs        Retorno de CalcEst()
                aArray – Array contendo:
                    Elemento 1 – Quantidade inicial em estoque na data
                    Elemento 2 – Custo inicial na data na moeda 1
                    Elemento 3 – Custo inicial na data na moeda 2
                    Elemento 4 – Custo inicial na data na moeda 3
                    Elemento 5 – Custo inicial na data na moeda 4   
                    Elemento 6 – Custo inicial na data na moeda 5
                    Elemento 7 – Quantidade inicial na segunda unidade de medida
/*/
//------------------------------------- 
Static Function fGetSaldo(cProduto)
    Local aArea      := GetArea()
    Local aAreaSB2   := SB2->(GetArea())
    Local nSaldo     := 0
    Local nPosQtd1UM := 1
    Local cQuery     := ""
    Local cAliasSaldo:= "fGetSaldo_"+FWTimeStamp(1)
    Local cFilSB2    := FWxFilial("SB2")
    Local cNameSB2   := RetSqlName("SB2")
    
    cQuery := " SELECT B2_LOCAL FROM "+cNameSB2+" AS SB2 "
    cQuery += " WHERE B2_FILIAL = '"+cFilSB2+"' "
    cQuery += "   AND B2_COD = '"+cProduto+"' "
    cQuery += "   AND B2_LOCAL BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' "
    cQuery += "   AND SB2.D_E_L_E_T_ = '' "

    cQuery:= ChangeQuery(cQuery)
    VarInfo(FunName()+" Query auxiliar -> ",cQuery)
    TcQuery cQuery New Alias (cAliasSaldo)

    (cAliasSaldo)->(DbGoTop())
    While !(cAliasSaldo)->(Eof())

        nSaldo += CalcEst(cProduto, (cAliasSaldo)->B2_LOCAL, DaySum(Date(),1))[nPosQtd1UM]
        (cAliasSaldo)->(DbSkip())
    Enddo
    (cAliasSaldo)->(DbCloseArea())

    RestArea(aAreaSB2)
    Restarea(aArea)
Return nSaldo

//-------------------------------------
/*/{Protheus.doc} fPrintPDF
Realiza a montagem e impressão do relatório em PDF
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      05/01/2022
@param      Character, cAliasEstru, nome do alias da tabela temporaria do relatório.
/*/
//-------------------------------------
Static Function fPrintPDF( cAliasEstru )
	   
    Local nAtuAux      := 0
    Local cArquivo     := FWTimeStamp(1)+"_relatorio de estrutura de produtos.pdf"
    
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
    Private nColInfoProd:= nColIni + 095
    Private nColDescProd:= nColIni + 050
    Private nColQtdBase := nColFin - 150
    Private nColUnid    := nColFin - 425
    Private nColQtdNec  := nColFin - 270
    Private nColQtdSaldo:= nColFin - 200
    Private nColProx    := nColFin - 150
    
    //Declarando as fontes
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
        
    (cAliasEstru)->(DbGoTop())
     
    //Somente se tiver dados
    If ! (cAliasEstru)->(EoF())
        //Criando o objeto de impressao
        If( oPrintPvt == Nil )
            oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., GetTempPath(), .T., , , @oPrintPvt , , , .F., )
            If(oPrintPvt:nModalResult == PD_CANCEL)
                FreeObj(oPrintPvt)
                Return
            Endif
            oPrintPvt:cPathPDF := GetTempPath()
            oPrintPvt:SetResolution(72)
            oPrintPvt:SetLandscape()
            oPrintPvt:SetPaperSize(DMPAPER_A4)
            oPrintPvt:SetMargin(0, 0, 0, 0)
        EndIf
        
        //Imprime os dados
        fImpCab()
        nLinAtu+=10
        oPrintPvt:SayAlign(nLinAtu, nColIni     , "Produto"                  , oFontDet,  (nColInfoProd - nColIni ) , 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfoProd, " : "+(cAliasEstru)->CODIGO, oFontDet,  (nColUnid - nColDescProd) , 10,           , PAD_LEFT  ,  )
        nLinAtu+=10
        oPrintPvt:SayAlign(nLinAtu, nColIni     , "Descrição"                                                               , oFontDet,  (nColInfoProd - nColIni ) , 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfoProd, " : "+Posicione("SB1",1,FWxFilial("SB1")+(cAliasEstru)->CODIGO,"B1_DESC") , oFontDet,  (nColUnid - nColDescProd) , 10,           , PAD_LEFT  ,  )
        nLinAtu+=10
        oPrintPvt:SayAlign(nLinAtu, nColIni     , "Quantidade base"                                                                  , oFontDet,  (nColInfoProd - nColIni) , 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfoProd, " : "+cValToChar(Posicione("SB1",1,FWxFilial("SB1")+(cAliasEstru)->CODIGO,"B1_QB")), oFontDet,  (nColProx - nColQtdSaldo), 10,           , PAD_LEFT  ,  )
        nLinAtu+=10
        oPrintPvt:SayAlign(nLinAtu, nColIni     , "Quantidade Necessária"        , oFontDet,  (nColInfoProd - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfoProd, " : "+cValToChar(nQuantidade_) , oFontDet,  (nColInfoProd - nColIni), 10,           , PAD_LEFT  ,  )
        nLinAtu+=10

        fImpSubCab()
        While ! (cAliasEstru)->(EoF())
            nAtuAux++
            IncProc("Imprimindo componentes da estrutura " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux_) + "...")
 
            //Se atingiu o limite, quebra de pagina
            fQuebra()
             
            //Faz o zebrado ao fundo
            If nAtuAux % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
            EndIf

            //Imprime a linha atual
            oPrintPvt:SayAlign(nLinAtu, nColProd    , (cAliasEstru)->COMP                                              , oFontDet, (nColDescProd - nColProd)  , 10, , PAD_LEFT  , )
            oPrintPvt:SayAlign(nLinAtu, nColDescProd, Posicione("SB1",1,FWxFilial("SB1")+(cAliasEstru)->COMP,"B1_DESC"), oFontDet, (nColUnid - nColDescProd)  , 10, , PAD_LEFT  , )
            oPrintPvt:SayAlign(nLinAtu, nColUnid    , Posicione("SB1",1,FWxFilial("SB1")+(cAliasEstru)->COMP,"B1_UM")  , oFontDet, (nColQtdNec - nColUnid)    , 10, , PAD_RIGHT , )
            oPrintPvt:SayAlign(nLinAtu, nColQtdNec  , cValToChar((cAliasEstru)->QUANT)                                 , oFontDet, (nColQtdSaldo - nColQtdNec), 10, , PAD_RIGHT , )
            oPrintPvt:SayAlign(nLinAtu, nColQtdSaldo, cValToChar(fGetSaldo((cAliasEstru)->COMP))                       , oFontDet, (nColProx - nColQtdSaldo)  , 10, , PAD_RIGHT , )
                      
            nLinAtu += 15
            oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)

            //Se atingiu o limite, quebra de pagina
            fQuebra()                  
              
            (cAliasEstru)->(DbSkip())           
        EndDo        
        fImpRod()                
    Else
        MsgStop("Não foram encontradas informações com os parâmetros informados!", "Atenção")
    EndIf    
Return

//-------------------------------------
/*/{Protheus.doc} fImpCab
imprime o cabecalho do relatório
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      05/01/2022
/*/
//------------------------------------- 
Static Function fImpCab()

    Local cTexto   := ""
    Local nLinCab  := 015

    oPrintPvt:StartPage()

    //Cabecalho
    cTexto := "Estrutura de produtos"
    oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
     
    //Linha Separatoria
    nLinCab += 020
    oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
    
    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinCab + 5
Return

//-------------------------------------
/*/{Protheus.doc} fImpSubCab
imprime o sub-cabecalho do relatório
@author     Súlivan 
@since      05/01/2022
/*/
//------------------------------------- 
Static Function fImpSubCab()
    
    nLinAtu+=2
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)

    nLinAtu+=5
    oPrintPvt:SayAlign(nLinAtu+00, nColProd    ,   "Código"       , oFontMin,  (nColDescProd - nColProd)  , 10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+10, nColProd    ,   "Componente"   , oFontMin,  (nColDescProd - nColProd)  , 10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+00, nColDescProd,   "Descrição do" , oFontMin,  (nColUnid - nColDescProd)  , 10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+10, nColDescProd,   "componente"   , oFontMin,  (nColUnid - nColDescProd)  , 10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+00, nColUnid    ,   "Unidade de"   , oFontMin,  (nColQtdNec - nColUnid)    , 10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColUnid    ,   "Medida"       , oFontMin,  (nColQtdNec - nColUnid)    , 10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+00, nColQtdNec  ,   "Quantidade"   , oFontMin,  (nColQtdSaldo - nColQtdNec), 10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+10, nColQtdNec  ,   "Necessária"   , oFontMin,  (nColQtdSaldo - nColQtdNec), 10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+05, nColQtdSaldo,   "Saldo Atual"  , oFontMin,  (nColProx   - nColQtdSaldo), 10, nCorCinza, PAD_RIGHT,  )
    
    oPrintPvt:Line(nLinAtu+22, nColIni, nLinAtu+22, nColFin)
        
    nLinAtu += 25
Return
 
//-------------------------------------
/*/{Protheus.doc} fImpRod
imprime o rodape do relatório
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      05/01/2022
/*/
//-------------------------------------
Static Function fImpRod()
    Local nLinRod:= nLinFin
    Local cTexto := ''
 
    //Linha Separatoria
    oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (xEstrPrd)     " + UsrRetName(RetCodUsr())
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
@since      05/01/2022
@param      Logical, lForce, força a finalização de uma página e inicialização de outra 
            mesmo que a página não tenha acabado. Default .F.
/*/
//------------------------------------- 
Static Function fQuebra(lForce)

    Default lForce := .F.

    If lForce .Or. nLinAtu >= nLinFin-10
        fImpRod()
        fImpCab()
        fImpSubCab()
    EndIf
Return

#Include 'totvs.ch'
#Include 'msobject.ch'
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#Define PAINEL_LINHA01_ID "_LINHA01_"
#Define PAINEL_LINHA02_ID "_LINHA02_"
#Define PAINEL_BOX01_ID "_BOX01_"
#Define PAINEL_BOX02_ID "_BOX02_"
#Define PAINEL01_ID "_PAINEL01_"
#Define PAINEL02_ID "_PAINEL02_"

#Define POS_DATA 1
#Define POS_DOCUMENTO 2
#Define POS_OBS 3
#Define POS_QTD 4

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

Static bClose 	:= Nil
Static bImprime := Nil

Static oPrintPvt := Nil 
Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)

/*/{Protheus.doc} zPainelKrdxT
	Fornece um painel com cabe�alho e grid para exibir o resultado 
	da consulta Kardex de porder de terceiro. 
	Al�m disso, tamb�m oferece a op��o para imprimir os resultados em PDF

	@version 1.0
/*/
Class zPainelKrdxT

    Private Data oModalDialog    As Object
	Private Data oPainelLayer    As Object
    Private Data oBrowse         As Object
	Private Data oInfosGerais    As Object
    Private Data aMovimentos     As Array
    
    //Construtor
    Public Method New()	Constructor
    
    //Getters
    Private Method GetPainelLayer() As Object
    Private Method GetModalDialog() As Object
    Private Method GetBrowse()      As Object
    Private Method GetHeaderGrid( oGrid As Object )   As Array

    //Outros M�todos	
	Private Method Initialize()   	  As Undefinied
	Private Method Config1Layer()     As Undefinied	
  	Private Method Config2Layer()     As Undefinied	
	Public  Method CloseWindow()  	  As Undefinied
	Public  Method OpenWindow()   	  As Undefinied
	Public  Method Imprime()		  As Undefinied
			
	Public  Method SetMovimentos() As Undefinied
	Public  Method SetInformacoesGerais(oCabecalho As Object) As Undefinied
EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
@author  	S�livan
/*/
Method New() Class zPainelKrdxT As Object
	::Initialize()
Return Self

/*/{Protheus.doc} Initialize 
@description inicializa componentes para montar a tela.
@author  	S�livan
@since		12/02/2022
@return 	Undefinied
/*/  
Method Initialize() Class zPainelKrdxT As Undefinied
           
    ::oModalDialog  := Nil    	
	::oPainelLayer  := Nil
	::oBrowse       := Nil
	::oInfosGerais	:= Nil
	::aMovimentos   := {}
	
	bClose		 := {|| @::CloseWindow() }
	bImprime	 := {|| Processa( {|| @::Imprime()() }, "Aguarde...", "Imprimindo informa��es... ", .F. ) }	

	::GetPainelLayer()
	::Config1Layer()
	::Config2Layer()
Return 

/*/{Protheus.doc} GetPainelLayer 
@description Retorna a FwLayer  que armazenar� os componentes 
@author  	S�livan
@since		12/12/2022
@return 	Object, objeto contendo FwLayer
/*/
Method GetPainelLayer() Class zPainelKrdxT As Object

	Local cTitulo01 
	Local cTitulo02

	If(::oPainelLayer == Nil)
	
	   cTitulo01 := "Informa��es gerais"
	   cTitulo02 := "Movimenta��es"	
					
	   ::oPainelLayer:= FWLayer():New()		
	   ::oPainelLayer:Init( ::GetModalDialog():getPanelMain(), .F. )		
	   ::oPainelLayer:AddLine( PAINEL_LINHA01_ID, 25 )
	   ::oPainelLayer:AddLine( PAINEL_LINHA02_ID, 75 )		
	   ::oPainelLayer:AddCollumn( PAINEL_BOX01_ID, 100,, PAINEL_LINHA01_ID )
	   ::oPainelLayer:AddCollumn( PAINEL_BOX02_ID, 100,, PAINEL_LINHA02_ID )		
	   ::oPainelLayer:AddWindow( PAINEL_BOX01_ID, PAINEL01_ID, cTitulo01, 100, .F.,,, PAINEL_LINHA01_ID )
	   ::oPainelLayer:AddWindow( PAINEL_BOX02_ID, PAINEL02_ID, cTitulo02, 100, .F.,,, PAINEL_LINHA02_ID )
	Endif	
Return ::oPainelLayer

/*/{Protheus.doc} GetModalDialog 
@description Retorna a Dialog  que armazenar� o Layer
@author  	S�livan
@return 	Object, objeto contendo FwDialogModal
/*/
Method GetModalDialog() Class zPainelKrdxT As Object

	Local aTamanho	:= {}
	Local nJanLarg	:= 0
	Local nJanAltu	:= 0
	Local aButtons  := {}
	
	If(::oModalDialog == Nil)
		
	   //Tamanho da Janela
	   aTamanho	:= MsAdvSize()
	   nJanLarg	:= aTamanho[5]/2
	   nJanAltu	:= aTamanho[6]/2

	   //Bot�es
	   aAdd(aButtons,{/*cResource*/, "Imprime", bImprime		 , "Imprime", /*nShortCut*/, .T., .F.})
	   
	   ::oModalDialog:= FwDialogModal():New() 
	   ::oModalDialog:setTitle(" Kardex de poder de 3� ")
	   ::oModalDialog:SetEscClose(.F.) 
	   ::oModalDialog:setSize(nJanAltu, nJanLarg)
	   ::oModalDialog:createDialog()
	   ::oModalDialog:addButtons(aButtons)
	   ::oModalDialog:addCloseButton(bClose, "Fechar")
	Endif
Return ::oModalDialog

/*/{Protheus.doc} Config1Layer 
@description Configura o layer1 adicionando seus componentes.
@author  	S�livan
@since		12/12/2022
@return 	Undefinied
/*/
Method Config1Layer()  Class zPainelKrdxT As Undefinied
	
	Local oPanel 	  := ::GetPainelLayer():GetWinPanel( PAINEL_BOX01_ID, PAINEL01_ID, PAINEL_LINHA01_ID )
	
	TSay():New( 001, 009,{||'Produto: '  },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
    TSay():New( 009, 009,{||'Unidade:'   },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
    TSay():New( 016, 009,{||'Armaz�m(s):'},oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)

	TSay():New( 009, 100,{||'Saldo Inicial:'},oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
    TSay():New( 016, 100,{||'Saldo Final:'  },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
	
	TSay():New( 009, 210,{||'Per�odo:'			 },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
    TSay():New( 016, 210,{||'Tipo da opera��o:'  },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
	
Return 

/*/{Protheus.doc} ConfigureLayer2 
@description Configura o layer2 adicionando seus componentes.
@author  	S�livan
@since		12/02/2022
@return 	Undefinied
/*/
Method Config2Layer() Class zPainelKrdxT As Undefinied
	
	Local oPanel := ::GetPainelLayer():GetWinPanel( PAINEL_BOX02_ID, PAINEL02_ID, PAINEL_LINHA02_ID )	
	::GetBrowse():SetOwner(oPanel)
Return 


/*/{Protheus.doc} GetBrowse 
@description Retorna a Grid com listagem que conter� listagem dos movimentos
@author  	S�livan
@since		12/02/2022
@return 	Object, objeto contendo FWBrowse
/*/
Method GetBrowse() Class zPainelKrdxT As Undefinied
   
    Local aTamanho := 0
	Local nJanLarg := 0
    Local nJanAltu := 0
    Local aCols    := {}
    	
	If(::oBrowse == Nil)
	
		If( Len(aCols) < 1 )
			aAdd(aCols, { "" /*Data*/, "" /*Documento*/, "" /*Observa��o*/,0 /*Quantidade*/,.F. /*N�o deletado*/})	
		Endif	
	
		//Tamanho da Janela
		aTamanho	:= MsAdvSize()
		nJanLarg	:= aTamanho[5]/2
		nJanAltu	:= aTamanho[6]/4
		
		::oBrowse:= FWBrowse():New()
		::oBrowse:DisableFilter()
		::oBrowse:DisableConfig()
		::oBrowse:DisableReport()
		::oBrowse:DisableSeek()
		::oBrowse:DisableSaveConfig()	
		::oBrowse:SetDataArray()
		::oBrowse:lHeaderClick:= .F.	
		::oBrowse:SetColumns(::GetHeaderGrid(@::oBrowse))
		::oBrowse:SetArray(aCols)	
	Endif
Return ::oBrowse

/*/{Protheus.doc} GetHeaderGrid 
@description Cria estrutura do Header do Browse das movimenta��es
@author  	S�livan
@since		12/02/2022
@param 		Object, Referencia do Grid que vai ser usado o Header
@return 	Array, Cont�m array do Header dos grids configurados
/*/
Method GetHeaderGrid(oGrid)  Class zPainelKrdxT As Array
	
	Local aHeadAux   := {}
	Local aHeader	 := {}
	Local nIndice    := 0 
	
	aAdd(aHeadAux, {"Data"      , "D", 15 								   , GetSx3Cache("D1_DATA" ,"X3_DECIMAL"), GetSx3Cache("D1_DATA" ,"X3_PICTURE")})
	aAdd(aHeadAux, {"Documento" , "C", 15								   , 0									 , '@!'								   })
	aAdd(aHeadAux, {"Observa��o", "C", 55								   , 0									 , '@!'								   })
	aAdd(aHeadAux, {"Quantidade", "N", GetSx3Cache("D1_QUANT","X3_TAMANHO"), GetSx3Cache("D1_QUANT","X3_DECIMAL"), GetSx3Cache("D1_QUANT","X3_PICTURE")})
		
	//Percorrendo e criando as colunas
	For nIndice := 1 To Len(aHeadAux)
		aAdd(aHeader, FWBrwColumn():New())
		aHeader[nIndice]:SetData(&("{||oGrid:oData:aArray[oGrid:At(),"+Str(nIndice)+"]}"))
		aHeader[nIndice]:SetTitle( aHeadAux[nIndice][1] )
		aHeader[nIndice]:SetType(aHeadAux[nIndice][2] )
		aHeader[nIndice]:SetSize( aHeadAux[nIndice][3] )
		aHeader[nIndice]:SetDecimal( aHeadAux[nIndice][4] )
		aHeader[nIndice]:SetPicture( aHeadAux[nIndice][5] )			 
	Next	
Return aHeader

/*/{Protheus.doc} SetMovimentos 
@description Faz input dos dados no browse da consulta
@author  	S�livan
@since		12/02/2022
@param		aDados, Array, array que cont�m as informa��es das movimenta��es de estoque do kardex
			Esturtura do array: 
				aDados
					[01] - Data da movimenta��o
					[02] - Documento (NF-e + S�rie) do movimento
					[03] - Observa��o do movimento
					[04] - Quantiade movimentada
@return 	Undefinied
/*/
Method SetMovimentos(aDados)  Class zPainelKrdxT As Undefinied
	
	::aMovimentos:= @aDados
	
	::GetBrowse():SetArray(::aMovimentos)
	::GetBrowse():Refresh(.T.)
Return

/*/{Protheus.doc} SetInformacoesGerais 
@description Faz input dos dados no cabecalho de informa��es gerais
@author  	S�livan
@since		13/02/2022
@param		oCabecalho, Object, objeto JSON que cont�m informa��es do cabe�alho.
@return 	Undefinied
@obs		M�todo Config1Layer possui os TSay dos t�tulos de cada informa��o 
/*/
Method SetInformacoesGerais(oCabecalho)  Class zPainelKrdxT As Undefinied
	
	Local oPanel 	  := ::GetPainelLayer():GetWinPanel( PAINEL_BOX01_ID, PAINEL01_ID, PAINEL_LINHA01_ID )	
	::oInfosGerais:= @oCabecalho

	TSay():New( 001, 045, {|| oCabecalho['PRODUTO'] }		,oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,150,010)
    TSay():New( 009, 045, {|| oCabecalho['UNIDADE_MEDIDA'] },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,150,010)
    TSay():New( 016, 045, {|| oCabecalho['ARMAZEM'] }		,oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,150,010)

	TSay():New( 009, 135, {|| oCabecalho['SALDO_INICIAL'] } ,oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,200,010)
    TSay():New( 016, 135, {|| oCabecalho['SALDO_FINAL'] }	,oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,200,010)

	TSay():New( 009, 255, {|| oCabecalho['PERIODO'] } 		,oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,400,010)
    TSay():New( 016, 255, {|| oCabecalho['TIPO_OPERACAO'] }	,oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,400,010)	
Return

/*/{Protheus.doc} Imprime 
@description imprime os registros da tela em PDF
@author  	S�livan
@since		19/02/2022
@return 	Undefinied
/*/
Method Imprime()  Class zPainelKrdxT As Undefinied
	
	Local nAtuAux      := 0
    Local cArquivo     := FWTimeStamp(1)+"_kardex poder de terceiro.pdf"
    Local nLinha	   := 1
	Local oPrintPvt    := Nil

    Private oBrushAzul := TBRUSH():New(,nCorAzul)
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 580
    Private nColIni    := 010
    Private nColFin    := 815
	Private nColIni2   := nColFin/4
	Private nColIni3   := nColFin/1.9
    Private nEspCol    := (nColFin-(nColIni+150))/13
    Private nColMeio   := (nColFin-nColIni)/2
    //Colunas dos relatorio
    Private nColDtMov    := nColIni    
    Private nColInfo1	:= nColIni + 095
	Private nColInfo2	:= nColIni2 + 045
	Private nColInfo3	:= nColIni3 + 70
    Private nColDoc		:= nColIni + 070
	Private nColProd	:= nColIni + 050
    Private nColQtdBase := nColFin - 150
    Private nColUnid    := nColFin - 425
    Private nColObs  	:= nColFin - 650
    Private nColQtdSaldo:= nColFin - 185
    Private nColProx    := nColFin - 150
    
    //Declarando as fontes
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)

	//Somente se tiver dados
    If  Len(::aMovimentos) > 2

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

			ProcRegua(Len(::aMovimentos))
        EndIf
        
        //Imprime os dados
        fImpCab(@oPrintPvt, @::oInfosGerais)
        fImpSubCab(@oPrintPvt)		
        For nLinha := 1 To Len(::aMovimentos)
            nAtuAux++
            IncProc("Imprimindo movimenta��es do kardex " + cValToChar(nAtuAux) + " de " + cValToChar(Len(::aMovimentos)) + "...")
 
            //Se atingiu o limite, quebra de pagina
            fQuebra(Nil, @oPrintPvt,  @::oInfosGerais)
             
            //Faz o zebrado ao fundo
            If nAtuAux % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
            EndIf

            //Imprime a linha atual
            oPrintPvt:SayAlign(nLinAtu, nColDtMov   , Iif(ValType(::aMovimentos[nLinha][POS_DATA])=='D',dToC(::aMovimentos[nLinha][POS_DATA]),::aMovimentos[nLinha][POS_DATA]), oFontDet, (nColDoc - nColDtMov) 	 , 10, , PAD_LEFT  , )
            oPrintPvt:SayAlign(nLinAtu, nColDoc		, Alltrim(::aMovimentos[nLinha][POS_DOCUMENTO])																			  , oFontDet, (nColObs - nColDoc)  	 	 , 10, , PAD_LEFT  , )
            oPrintPvt:SayAlign(nLinAtu, nColObs     , Alltrim(::aMovimentos[nLinha][POS_OBS]) 																				  , oFontDet, (nColQtdSaldo - nColObs)   , 10, , PAD_LEFT  , )
            oPrintPvt:SayAlign(nLinAtu, nColQtdSaldo, cValToChar(::aMovimentos[nLinha][POS_QTD]) 						                      								  , oFontDet, (nColProx - nColQtdSaldo)  , 10, , PAD_RIGHT , )
                      
            nLinAtu += 15
            oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)

            //Se atingiu o limite, quebra de pagina
            fQuebra(Nil,@oPrintPvt, @::oInfosGerais)                  
        Next
        fImpRod(@oPrintPvt)                
		
		IncProc("Abrindo relat�rio..")
    	oPrintPvt:Preview()
		FreeObj(oPrintPvt)
    Else
        MsgStop("N�o � poss�vel imprimir kardex sem movimenta��o!", "Aten��o")
    EndIf    

	/*/{Protheus.doc} fImpCab
	imprime o cabecalho do relat�rio
	@author     Daniel Atilio ( Cria��o da l�gica de estiliza��o do relat�rio )
	@author     S�livan (Realizado adpata��es para regra de neg�cio)
	@since 		19/02/2022
	@param 		oPrintPvt, Object, objeto de impress�o
	@param 		oInfosGerais, Object, objeto do cabe�alho a ser impresso
	/*/
	Static Function fImpCab(oPrintPvt, oInfosGerais)

		Local cTexto   := ""
		Local nLinCab  := 015

		oPrintPvt:StartPage()

		//Cabecalho
		cTexto := "Kardex poder de 3�"
		oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
		
		//Linha Separatoria
		nLinCab += 020
		oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
		
		//Atualizando a linha inicial do relatorio
		nLinAtu := nLinCab + 5

		oPrintPvt:SayAlign(nLinAtu, nColIni  , "Produto"    		              , oFontDet,  (nColInfo1 - nColIni ) , 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : "+oInfosGerais['PRODUTO']      , oFontDet,  (nColUnid - nColProd ) , 10,           , PAD_LEFT  ,  )
    
        nLinAtu+=10

        oPrintPvt:SayAlign(nLinAtu, nColIni  , "Unidade"                             , oFontDet,  (nColInfo1 - nColIni),  10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : "+oInfosGerais['UNIDADE_MEDIDA']  , oFontDet,  (nColInfo1 - nColIni),  10,           , PAD_LEFT  ,  )		        
        oPrintPvt:SayAlign(nLinAtu, nColIni2 , "Saldo Inicial"   		       	     , oFontDet,  (nColInfo1 - nColIni),  10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo2, " : "+oInfosGerais['SALDO_INICIAL']   , oFontDet,  (nColInfo1 - nColIni),  10,           , PAD_LEFT  ,  )
		oPrintPvt:SayAlign(nLinAtu, nColIni3 , "Per�odo do Kardex"        	  		 , oFontDet,  (nColInfo1 - nColIni),  10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo3, " : "+oInfosGerais['PERIODO'] 	     , oFontDet,  (nColInfo1+50- nColIni),10,           , PAD_LEFT  ,  )
        
		nLinAtu+=10

		oPrintPvt:SayAlign(nLinAtu, nColIni  , "Armaz�m(s)" 			       	    , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : "+oInfosGerais['ARMAZEM'] 		, oFontDet,  (nColInfo1 - nColIni), 10,           , PAD_LEFT  ,  )
		oPrintPvt:SayAlign(nLinAtu, nColIni2 , "Saldo Final"        				, oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo2, " : "+oInfosGerais['SALDO_FINAL']    , oFontDet,  (nColInfo1 - nColIni), 10,           , PAD_LEFT  ,  )
		oPrintPvt:SayAlign(nLinAtu, nColIni3 , "Tipo da opera��o"        	 	    , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
        oPrintPvt:SayAlign(nLinAtu, nColInfo3, " : "+oInfosGerais['TIPO_OPERACAO']  , oFontDet,  (nColInfo1 - nColIni), 10,           , PAD_LEFT  ,  )
		
		nLinAtu+=10
	Return

	/*/{Protheus.doc} fImpSubCab
	imprime o sub-cabecalho do relat�rio
	@author     S�livan 
	@since      19/02/2022
	@param 		oPrintPvt, Object, objeto de impress�o
	/*/
	Static Function fImpSubCab(oPrintPvt)
		
		nLinAtu+=2
		oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)

		nLinAtu+=5
		oPrintPvt:SayAlign(nLinAtu+00, nColDtMov   ,   "Data"         , oFontMin,  (nColDoc - nColDtMov)  , 10, nCorCinza, PAD_LEFT,   )
		oPrintPvt:SayAlign(nLinAtu+10, nColDtMov   ,   "Movimenta��o" , oFontMin,  (nColDoc - nColDtMov)  , 10, nCorCinza, PAD_LEFT,   )
		oPrintPvt:SayAlign(nLinAtu+05, nColDoc	   ,   "Documento"    , oFontMin,  (nColUnid - nColDoc)  , 10, nCorCinza, PAD_LEFT,   )
		oPrintPvt:SayAlign(nLinAtu+05, nColObs     ,   "Observa��o"   , oFontMin,  (nColQtdSaldo - nColObs), 10, nCorCinza, PAD_LEFT,   )
		oPrintPvt:SayAlign(nLinAtu+05, nColQtdSaldo,   "Quantidade"   , oFontMin,  (nColProx   - nColQtdSaldo), 10, nCorCinza, PAD_RIGHT,  )
		
		oPrintPvt:Line(nLinAtu+22, nColIni, nLinAtu+22, nColFin)
			
		nLinAtu += 25
	Return

	/*/{Protheus.doc} fImpRod
	imprime o rodape do relat�rio
	@author     Daniel Atilio ( Cria��o da l�gica de estiliza��o do relat�rio )
	@author     S�livan (Realizado adpata��es para regra de neg�cio)
	@since      19/02/2022
	@param 		oPrintPvt, Object, objeto de impress�o
	/*/
	Static Function fImpRod(oPrintPvt)
		Local nLinRod:= nLinFin
		Local cTexto := ''
	
		//Linha Separatoria
		oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
		nLinRod += 3
		
		//Dados da Esquerda
		cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (zKardexT)     " + UsrRetName(RetCodUsr())
		oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
		
		//Direita
		cTexto := "Pagina "+cValToChar(nPagAtu)
		oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
		
		//Finalizando a pagina e somando mais um
		oPrintPvt:EndPage()
		nPagAtu++
	Return

	/*/{Protheus.doc} fQuebra
	Realiza a finaliza��o de uma p�gina e inicializa��o de outra quando necess�rio.
	@author     Daniel Atilio ( Cria��o da l�gica de estiliza��o do relat�rio )
	@author     S�livan (Realizado adpata��es para regra de neg�cio)
	@since      19/02/2022
	@param      Logical, lForce, for�a a finaliza��o de uma p�gina e inicializa��o de outra 
				mesmo que a p�gina n�o tenha acabado. Default .F.
	@param 		oPrintPvt, Object, objeto de impress�o
	@param 		oInfosGerais, Object, objeto do cabe�alho a ser impresso
	/*/
	Static Function fQuebra(lForce, oPrintPvt, oInfosGerais)

		Default lForce := .F.

		If lForce .Or. nLinAtu >= nLinFin-10
			fImpRod(@oPrintPvt)
			fImpCab(@oPrintPvt, @oInfosGerais)
			fImpSubCab(@oPrintPvt)
		EndIf
	Return
Return 

/*/{Protheus.doc} OpenWindow 
@description Abre a janela para o usu�rio
@author  	S�livan
@since		12/02/2022
@return 	Undefinied
/*/
Method OpenWindow()  Class zPainelKrdxT As Undefinied
	::GetBrowse():Activate()
	::GetModalDialog():Activate()
Return 

/*/{Protheus.doc} CloseWindow 
@description Fecha a janela para o usu�rio e destr�i os objetos criados.
@author  	S�livan
@since		12/02/2022
@return 	Undefinied
/*/
Method CloseWindow()  Class zPainelKrdxT As Undefinied
	
	::GetModalDialog():DeActivate()
 	::aMovimentos := {}		
	FreeObj(::oInfosGerais)
Return 


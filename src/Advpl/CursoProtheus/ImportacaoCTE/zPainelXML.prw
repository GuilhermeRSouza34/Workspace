#Include 'totvs.ch'

#Define XML_DE_CTE 1
#Define XML_DE_NFE 2
#Define MATA103_CTE_NOTA 2
#Define MATA103_CTE_PRE_NOTA 1
#Define MATA116 3

#Define PAINEL_LINHA01_ID "_LINHA01_"
#Define PAINEL_LINHA02_ID "_LINHA02_"
#Define PAINEL_BOX01_ID "_BOX01_"
#Define PAINEL_BOX02_ID "_BOX02_"
#Define PAINEL01_ID "_PAINEL01_"
#Define PAINEL02_ID "_PAINEL02_"

Static bAtualizaTela := Nil
Static bInsert 		 := Nil
Static bClose  		 := Nil

/*/{Protheus.doc} zPainelXML
@description	Fornece tela para usuario realizar importacao de XML.
@author    		Súlivan Simões (sulivan@atiliosistemas.com)
@since		    04/2022
/*/
Class zPainelXML From LongNameClass 
	
	Private Data oModalDialog    As Object
	Private Data oPainelLayer    As Object
    Private Data oMarkBrowse     As Object
    Private Data oTempTable	     As Object
    Private Data cDiretorioArq   As Character
	Private Data nTipoXML		 As Numeric
	Private Data nOperation		 As Numeric

    //Construtor
    Public Method New()	Constructor
    
    //Getters
    Private Method GetPainelLayer() As Object
    Private Method GetModalDialog() As Object
    Private Method GetMarkBrowse()  As Object
    Private Method GetTempTable()   As Object
        
    //Outros Metodos	
	Private Method Initialize()   	  As Undefinied
	Private Method ConfigureLayer1()  As Undefinied
	Private Method ConfigureLayer2()  As Undefinied	
	Public  Method CloseWindow()  	  As Undefinied
	Public  Method OpenWindow()   	  As Undefinied
			
	/*Metodos Publicos apenas para poderem ser acessados via Bloco de codigo*/
	Public  Method UpdateMarkBrowse(cDiretorioArquivos As Character) As Logical
	Public  Method ExecuteActions() As Undefinied
EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
@author Sulivan Simoes (sulivan@atiliosistemas.com)
/*/
Method New() Class zPainelXML As Object
	::Initialize()
Return Self

/*/{Protheus.doc} Initialize 
@description inicializa componentes para montar a tela.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Undefinied
/*/  
Method Initialize() Class zPainelXML As Undefinied
           
    ::oModalDialog  := Nil    	
	::oPainelLayer  := Nil
	::oMarkBrowse   := Nil
	::oTempTable    := Nil
	::cDiretorioArq := PadR(cDiretorio_,100,Space(100)) 
	
	::nTipoXML		:= XML_DE_CTE //No futuro quando implementar de NF-e obter informação por meio dos MV_PAR..
	::nOperation    := nRotina_	  

	bAtualizaTela:= {|| @::UpdateMarkBrowse() }
	bInsert		 := {|| @::ExecuteActions() }
	bClose		 := {|| @::CloseWindow() }
	
	::GetPainelLayer()
	::ConfigureLayer1()
	::ConfigureLayer2()
Return 

/*/{Protheus.doc} GetTempTable 
@description Retorna a intancia da tabela temporaria  que amazena os registros para marcaÃ§Ã£o.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Object, objeto contendo tabela FWTemporaryTable.
/*/
Method GetTempTable() Class zPainelXML As Object
	
	If( ::oTempTable == Nil )
		
		zImportacaoXMLUtils():BuildTempTable(@::oTempTable)
		::UpdateMarkBrowse( ::cDiretorioArq )
	Endif
Return ::oTempTable

/*/{Protheus.doc} GetMarkBrowse 
@description Retorna a FWMarkBrowse  que amazenarÃ¡ os registros para marcaÃ§Ã£o.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Object, objeto contendo FWMarkBrowse
/*/
Method GetMarkBrowse() Class zPainelXML As Object
		
	Local aColumns	:= {}
	
	If (::oMarkBrowse == Nil)
				 			 		
		aColumns  := zImportacaoXMLUtils():GetColumnsMarkBrowse()
				
		::oMarkBrowse:= FWMarkBrowse():New()
	    ::oMarkBrowse:SetAlias(::GetTempTable():GetAlias())	     	   
	    ::oMarkBrowse:SetDescription('Seleção de arquivos')
	    ::oMarkBrowse:DisableReport()
	    ::oMarkBrowse:DisableFilter()
	    ::oMarkBrowse:SetFieldMark( 'OK' )	//Campo que serÃ¡ marcado/desmarcado
	    ::oMarkBrowse:SetTemporary(.T.)
		::oMarkBrowse:AddLegend( "!Empty(Alltrim(OBS))", "RED"  , "Nao esta apto para importacao" )
		::oMarkBrowse:AddLegend( "Empty(Alltrim(OBS))" , "GREEN", "Apto para importacao" )
	    ::oMarkBrowse:SetColumns(aColumns)
	    ::oMarkBrowse:AllMark() 		
	Endif
Return ::oMarkBrowse

/*/{Protheus.doc} GetPainelLayer 
@description Retorna a FwLayer  que armazena os componentes 
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Object, objeto contendo FwLayer
/*/
Method GetPainelLayer() Class zPainelXML As Object

	Local cTitulo01 
	Local cTitulo02
    
	If(::oPainelLayer == Nil)
	
	   cTitulo01 := "Parametros utilizados"
	   cTitulo02 := "Seleção de arquivos"	
					
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
@description Retorna a Dialog  que armazenarÃ¡ o Layer
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@return 	Object, objeto contendo FwDialogModal
/*/
Method GetModalDialog() Class zPainelXML As Object
	
	Local aTamanho	:= {}
	Local nJanLarg	:= 0
	Local nJanAltu	:= 0
	Local aButtons  := {}
	
	If(::oModalDialog == Nil)
		
	   //Tamanho da Janela
	   aTamanho	:= MsAdvSize()
	   nJanLarg	:= aTamanho[5]/2
	   nJanAltu	:= aTamanho[6]/2
	   
	   //Botoes Principais
	   aAdd(aButtons,{/*cResource*/, "Importa XML"	  , bInsert		 , "Importa XML"	, /*nShortCut*/, .T., .F.})
	   aAdd(aButtons,{/*cResource*/, "Atualiza Tela"  , bAtualizaTela, "Atualiza Tela"  , /*nShortCut*/, .T., .F.})
	
	   ::oModalDialog:= FwDialogModal():New() 
	   ::oModalDialog:setTitle(" Importador de XML ")
	   ::oModalDialog:SetEscClose(.F.) 
	   ::oModalDialog:setSize(nJanAltu, nJanLarg)
	   ::oModalDialog:createDialog()
	   ::oModalDialog:addButtons(aButtons)
	   ::oModalDialog:addCloseButton(bClose, "Fechar")
	Endif
Return ::oModalDialog

/*/{Protheus.doc} ConfigureLayer1 
@description Configura o layer1 adicionando seus componentes.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Undefinied
/*/
Method ConfigureLayer1()  Class zPainelXML As Undefinied
	Local cDir   := ::cDiretorioArq
	Local nRotina:= ::nOperation
	Local aRotinas := {"1=[MATA140] Pré Nota", "2=[MATA103] Classificação em Documento de Entrada", "3=[MATA116] NF de conhecimento de frete"}
	Local oPanel := ::GetPainelLayer():GetWinPanel( PAINEL_BOX01_ID, PAINEL01_ID, PAINEL_LINHA01_ID )

	TSay():New( 001, 009,{||'Pasta com arquivos para importação:'},oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)	
   	TSay():New( 001, 100,{||cDir 								 },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,300,010)

    TSay():New( 009, 009,{||'Produto:'   						 },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
	TSay():New( 009, 040,{||cCodPro_ 							 },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,300,010)

    TSay():New( 016, 009,{||'Armazém:'							 },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
	TSay():New( 016, 040,{||cParArm_ 							 },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,300,010)

	TSay():New( 023, 009,{||'Tipo importação:'					 },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
	TSay():New( 023, 050,{||aRotinas[nRotina] 					 },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,300,010)

	TSay():New( 009, 100,{||'TES:'								 },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
    TSay():New( 009, 115,{||cParTes_ 							 },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,300,010)	
	
	TSay():New( 016, 100,{||'Condição de pagamento:'			 },oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
    TSay():New( 016, 160,{||cParCond_ 							 },oPanel,,,,,,.T.,RGB(0, 0, 0),CLR_WHITE,300,010)	
Return 

/*/{Protheus.doc} ConfigureLayer2 
@description Configura o layer2 adicionando seus componentes.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Undefinied
/*/
Method ConfigureLayer2()  Class zPainelXML As Undefinied
	
	Local oPanel := ::GetPainelLayer():GetWinPanel( PAINEL_BOX02_ID, PAINEL02_ID, PAINEL_LINHA02_ID )	
	::GetMarkBrowse():SetOwner(oPanel)
Return 

/*/{Protheus.doc} UpdateMarkBrowse 
@description Atualiza o markbrowse
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@param		Character, nome de alias da tabela temporaria criada.
@return 	Logical, Deve sempre retornar .T. para poder ser acionado via valids nos Gets
/*/
Method UpdateMarkBrowse(cDiretorioArquivos)  Class zPainelXML As Logical
	
	Local lRet := .T.		
	Default cDiretorioArquivos :=  ::cDiretorioArq
	
	::cDiretorioArq := cDiretorioArquivos
	
	zImportacaoXMLUtils():PopulateTempTable(::GetTempTable():GetAlias(), cDiretorioArquivos, ::nTipoXML )
	::GetMarkBrowse():Refresh(.T.)
Return lRet

/*/{Protheus.doc} ExecuteActions 
@description Executa acoes necessarias para realizar a inclusao dos registros no sistema
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Undefinied
/*/
Method ExecuteActions()  Class zPainelXML As Undefinied
	
	Local aArea 	  := GetArea()
	Local oNota		  := Nil
	Local oPersistence:= Nil
	Local aXML	 	  := {}
	Local nIndice	  := 0
	Local nPosXML	  := 1
	Local nPosArquivo := 2
	Local lStatus	  := .T.
	Local lNadaValido := .T.

	//Pegando a factory de persistencia de acordo com a opcao escolhida nos parametros. 
	oPersistence:= zDocEntFactory():GetStrategyFor(::nOperation)
    
	//Obtendo somente XML marcados no browse e sem observacoes
    aXML:= zImportacaoXMLUtils():GetContentFiles(::GetMarkBrowse()		   ,;
	 											 ::GetTempTable():GetAlias())
			
    oNota:= zConvetFileToObjectFactory():GetStrategyFor(::nTipoXML) 
	For nIndice := 1 To Len(aXML)
	   //Convertendo XML para Objetos e validando
	   oNota:ConvertToObject(aXML[nIndice][nPosXML], Nil)
	   If oNota:IsXMLValid()
	   		FWMsgRun( ,;
	 			      {|| lStatus:= oPersistence:Commit(oNota) },;
				 	  "Aguarde",;
				 	  "Realizando lançamento dos documentos...";
				 	)
						
			zImportacaoXMLUtils():MoveFiles(::cDiretorioArq, aXML[nIndice][nPosArquivo], lStatus)			
	   		lNadaValido:=.F.
	   Endif
	Next
	::UpdateMarkBrowse()

	If lNadaValido
		MsgInfo("Nenhum XML está válido para importação, vide a coluna observações","Aviso")
	Endif

	FreeObj(oNota)
	FreeObj(oPersistence)
	RestArea( aArea )
Return

/*/{Protheus.doc} OpenWindow 
@description Abre a janela para o usuario
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Undefinied
/*/
Method OpenWindow()  Class zPainelXML As Undefinied
	::GetMarkBrowse():Activate()
	::GetModalDialog():Activate()
Return 

/*/{Protheus.doc} CloseWindow 
@description Fecha a janela para o usuario e destrÃ³i os objetos criados.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
@return 	Undefinied
/*/
Method CloseWindow()  Class zPainelXML As Undefinied
	
	//Fecha o Modal
	::GetModalDialog():DeActivate()
Return 

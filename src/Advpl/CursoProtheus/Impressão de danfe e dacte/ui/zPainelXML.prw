#Include 'Totvs.ch'

#Define XML_DE_NFE 1
#Define XML_DE_CTE 2

#Define PAINEL_LINHA01_ID "_LINHA01_"
#Define PAINEL_LINHA02_ID "_LINHA02_"
#Define PAINEL_BOX01_ID "_BOX01_"
#Define PAINEL_BOX02_ID "_BOX02_"
#Define PAINEL01_ID "_PAINEL01_"
#Define PAINEL02_ID "_PAINEL02_"

Static bAtualizaTela := Nil
Static bPrint 		 := Nil
Static bClose  		 := Nil

/*/{Protheus.doc} zPainelXML
	Fornece tela para usuario realizar impressao de danfe a partir do XML.
	@author Sulivan Simoes (sulivansimoes@gmail.com)
	@since 26/08/2024
	@version 1.0.0
	/*/
Class zPainelXML From LongNameClass 
	
	Private Data oModalDialog    As Object
	Private Data oPainelLayer    As Object
    Private Data oMarkBrowse     As Object
    Private Data oTempTable	     As Object
    Private Data cDiretorioArq   As Character
    Private Data aOrigensArquivo As Array

    //Construtor
    Public Method New()	Constructor
    
    //Getters
    Private Method GetPainelLayer() As Object
    Private Method GetModalDialog() As Object
    Private Method GetMarkBrowse()  As Object
    Private Method GetTempTable()   As Object
        
    //Outros Metodos	
	Private Method Initialize()   	 
	Private Method ConfigureLayer1() 
	Private Method ConfigureLayer2() 
	Public  Method CloseWindow()  	 
	Public  Method OpenWindow()   	 
			
	/*Metodos Publicos apenas para poderem ser acessados via Bloco de codigo*/
	Public  Method UpdateMarkBrowse(cDiretorioArquivos As Character) As Logical
	Public  Method ExecuteActions() 
EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
@author Sulivan Simoes (sulivansimoes@gmail.com)
/*/
Method New() Class zPainelXML As Object
	::Initialize()
Return Self

/*/{Protheus.doc} Initialize 
@description inicializa componentes para montar a tela.
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Undefinied
/*/  
Method Initialize() Class zPainelXML 
           
    ::oModalDialog  := Nil    	
	::oPainelLayer  := Nil
	::oMarkBrowse   := Nil
	::oTempTable    := Nil
	::cDiretorioArq := PadR(GetTempPath(),100,Space(100)) 
	::aOrigensArquivo:= {"NF-e", "CT-e"} 
	
	bAtualizaTela:= {|| @::UpdateMarkBrowse() }
	bPrint		 := {|| @::ExecuteActions() }
	bClose		 := {|| @::CloseWindow() }
	
	::GetPainelLayer()
	::ConfigureLayer1()
	::ConfigureLayer2()
Return 

/*/{Protheus.doc} GetTempTable 
@description Retorna a intancia da tabela temporaria  que amazena os registros para marcacao.
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Object, objeto contendo tabela FWTemporaryTable.
/*/
Method GetTempTable() Class zPainelXML As Object
	
	If( ::oTempTable == Nil )
		
		zPainelXMLUtils():BuildTempTable(@::oTempTable)
		::UpdateMarkBrowse( ::cDiretorioArq )
	Endif
Return ::oTempTable

/*/{Protheus.doc} GetMarkBrowse 
@description Retorna a FWMarkBrowse  que armazenara os registros para marcacao
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Object, objeto contendo FWMarkBrowse
/*/
Method GetMarkBrowse() Class zPainelXML As Object
		
	Local aColumns	:= {}
	
	If (::oMarkBrowse == Nil)
				 			 		
		aColumns  := zPainelXMLUtils():GetColumnsMarkBrowse()
				
		::oMarkBrowse:= FWMarkBrowse():New()
	    ::oMarkBrowse:SetAlias(::GetTempTable():GetAlias())	     	   
	    ::oMarkBrowse:SetDescription('Seleção de arquivos')
	    ::oMarkBrowse:DisableReport()
	    ::oMarkBrowse:DisableFilter()
	    ::oMarkBrowse:SetFieldMark( 'OK' )	//Campo que sera marcado/desmarcado
	    ::oMarkBrowse:SetTemporary(.T.)
		::oMarkBrowse:AddLegend( "!Empty(Alltrim(OBS))", "RED"  , "Nao esta apto para impressao" )
		::oMarkBrowse:AddLegend( "Empty(Alltrim(OBS))" , "GREEN", "Apto para impressao" )
	    ::oMarkBrowse:SetColumns(aColumns)
	    ::oMarkBrowse:AllMark() 		
	Endif
Return ::oMarkBrowse

/*/{Protheus.doc} GetPainelLayer 
@description Retorna a FwLayer  que armazena os componentes 
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
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
@description Retorna a Dialog  que armazenara o Layer
@author Sulivan Simoes (sulivansimoes@gmail.com)
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
	   aAdd(aButtons,{/*cResource*/, "Imprime danfe/dacte", bPrint		 , "Imprime Danfe/Dacte"	, /*nShortCut*/, .T., .F.})
	   aAdd(aButtons,{/*cResource*/, "Atualiza Tela"  	  , bAtualizaTela, "Atualiza Tela"  , /*nShortCut*/, .T., .F.})
	
	   ::oModalDialog:= FwDialogModal():New() 
	   ::oModalDialog:SetTitle(" Impressao de Danfe/Dacte ")
	   ::oModalDialog:SetEscClose(.F.) 
	   ::oModalDialog:SetSize(nJanAltu, nJanLarg)
	   ::oModalDialog:CreateDialog()
	   ::oModalDialog:AddButtons(aButtons)
	   ::oModalDialog:AddCloseButton(bClose, "Fechar")
	Endif
Return ::oModalDialog

/*/{Protheus.doc} ConfigureLayer1 
@description Configura o layer1 adicionando seus componentes.
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Undefinied
/*/
Method ConfigureLayer1()  Class zPainelXML 

	Local oPanel 	  := ::GetPainelLayer():GetWinPanel( PAINEL_BOX01_ID, PAINEL01_ID, PAINEL_LINHA01_ID )
	Local oSay1		  := Nil			 
	Local oGet1 	  := Nil
	Local oButton1	  := Nil //Botão para pesquisar diretório. A consulta padrão AGRXDIR não está funcionando corretamente.
	Local cGet1  	  := @::cDiretorioArq	
	Local bValid 	  := {|| ::UpdateMarkBrowse(cGet1) }
	
	oSay1 := TSay():New( 005, 009,{||'Pasta com arquivos XML'},oPanel,,,,,,.T.,CLR_BLUE,CLR_WHITE,150,010)
	oGet1 := TGet():New( 012, 009,{|u| If( PCount() == 0, cGet1, cGet1 := u ) },oPanel, 150, 010, "!@",bValid, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet1",,,,.T.)
	oButton1:= TButton():New( 012, 158, "Pesquisar",oPanel,{|| zPainelXMLUtils():F3Diretorio(@cGet1), ::UpdateMarkBrowse(cGet1) }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )		
Return 

/*/{Protheus.doc} ConfigureLayer2 
@description Configura o layer2 adicionando seus componentes.
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Undefinied
/*/
Method ConfigureLayer2()  Class zPainelXML 
	
	Local oPanel := ::GetPainelLayer():GetWinPanel( PAINEL_BOX02_ID, PAINEL02_ID, PAINEL_LINHA02_ID )	
	::GetMarkBrowse():SetOwner(oPanel)
Return 

/*/{Protheus.doc} UpdateMarkBrowse 
@description Atualiza o markbrowse
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@param		cDiretorioArquivos, Character, nome de alias da tabela temporaria criada.
@return 	Logical, Deve sempre retornar .T. para poder ser acionado via valids nos Gets
/*/
Method UpdateMarkBrowse(cDiretorioArquivos)  Class zPainelXML As Logical
	
	Local lRet := .T.	
			
	Default cDiretorioArquivos :=  ::cDiretorioArq
	
	::cDiretorioArq := cDiretorioArquivos
	
	zPainelXMLUtils():PopulateTempTable(::GetTempTable():GetAlias(), cDiretorioArquivos )
	::GetMarkBrowse():Refresh(.T.)
Return lRet

/*/{Protheus.doc} ExecuteActions 
@description Executa acoes necessarias para realizar a inclusao dos registros no sistema
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Undefinied
/*/
Method ExecuteActions()  Class zPainelXML 
	
	Local aArea 	  := FwGetArea()
	Local oNota		  := Nil
	Local aXML	 	  := {}
	Local nIndice	  := 0
	Local nPosXML	  := 1
	Local nPosArquivo := 2
	Local lNadaValido := .T.
	Local nTipoXML	  := 0

	// XML_DE_NFE = 1
 	// XML_DE_CTE = 2
	For nTipoXML:= 1 To 2

		//Obtendo somente XML marcados no browse e sem observacoes
    	aXML:= zPainelXMLUtils():GetContentFiles(::GetMarkBrowse()		   ,;
		 										 ::GetTempTable():GetAlias())

    	oNota:= zConvetFileToObjectFactory():GetStrategyFor(nTipoXML) 
		oNota:SetDestino(Alltrim(::cDiretorioArq))

		For nIndice := 1 To Len(aXML)

		   //Convertendo XML para Objetos e validando
		   oNota:ConvertToObject(aXML[nIndice][nPosXML], Nil)
		   If oNota:IsXMLValid()	   					

		   		FWMsgRun( ,;
		 			      {|| oNota:Print() },;
					 	  "Aguarde",;
					 	  "Gerando os documentos em "+::cDiretorioArq+Iif(nTipoXML == XML_DE_CTE,"dacte\","danfe\")+"...";
					 	)

				zPainelXMLUtils():MoveFiles(::cDiretorioArq, aXML[nIndice][nPosArquivo], nTipoXML)			
		   		lNadaValido:=.F.
		   Endif
		Next
	Next
	::UpdateMarkBrowse()

	If lNadaValido
		MsgInfo("Nenhum XML está válido para imprimir","Aviso")
	Endif

	FwFreeObj(oNota)
	FwRestArea( aArea )
Return

/*/{Protheus.doc} OpenWindow 
@description Abre a janela para o usuario
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Undefinied
/*/
Method OpenWindow()  Class zPainelXML 
	::GetMarkBrowse():Activate()
	::GetModalDialog():Activate()
Return 

/*/{Protheus.doc} CloseWindow 
@description Fecha a janela para o usuario e destroi os objetos criados.
@author Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@return 	Undefinied
/*/
Method CloseWindow()  Class zPainelXML 
	
	//Fecha o Modal
	::GetModalDialog():DeActivate()
Return 

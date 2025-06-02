#Include "totvs.ch"
#Include "FWMBrowse.ch"
#Include "FWMVCDEF.CH"

#Define MVC_TITLE "Gestao de pedidos de venda"
#Define TABLE "SC5"
#Define CONDITION_LEGENDA 1
#Define COLOR_LEGENDA 2
#Define TITLE_LEGENDA 3

/*/{Protheus.doc} zGestPV
    
    Fornece uma rotina que permite ao usuario fazer a gestão do pedido de venda
    > Centraliza funções de pedido de venda em um único lugar

    @type  Function
    @author Súlivan Simoes (sulivansimoes@gmail.com)
    @since 10/01/2022
    @version 1.0
    @example
        u_zGestPV()    
/*/
User Function zGestPV()

    Local aArea      := GetArea()
    Local oBrowse    := Nil
    Local nOffWaring := 0
    Local nIndice    := 0

    Private aLegenda   := {}
    Private aRotina    := MenuDef()
    Private cCadastro  := MVC_TITLE
    Private L410AUTO      := .F. //Uso interno da MATA410A
    Private ACOLTRFEXC    := {}  //Uso interno da MATA410
    Private aColsCCust    := {}  //Uso interno da MATA410
    Private aBkpAgg       := {}  //Uso interno da MATA410

    fDefineLegenda(@aLegenda)

    //Instanciando FWMBrowse, setando a tabela, a descricao e ativando a navegacao
    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( TABLE )
    oBrowse:SetMenuDef("zGestPV")
    oBrowse:SetDescription( MVC_TITLE )
    oBrowse:DisableDetails()

    // //Definindo Legendas 	        
    For nIndice := 1 To Len(aLegenda)    	
    	oBrowse:AddLegend(aLegenda[nIndice][CONDITION_LEGENDA],;
    					  aLegenda[nIndice][COLOR_LEGENDA]	  ,;
    					  aLegenda[nIndice][TITLE_LEGENDA]    ,)
    Next

    oBrowse:Activate()

    //Trataviva para os Warning
    If nOffWaring == 1
        MenuDef()
        ModelDef()
        ViewDef()
    EndIf

    //Apos o uso, limpa os objetos da memoria
    oBrowse:DeActivate()
    oBrowse:Destroy()

    FreeObj(oBrowse)
    RestArea(aArea)

Return

//-------------------------------------
/*/{Protheus.doc} MenuDef do Browser
@author  	Súlivan
@return 	aRot (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------
Static Function MenuDef()

    Local aRotina  := {}
    Local aSubRot01:= FwLoadMenuDef("MATA410")    
    Local aSubRel01:= {}

	ADD OPTION aRotina TITLE "Pedidos de Venda"     ACTION aSubRot01        OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Facilitador de finalização de pedido"          ACTION 'u_zAutGerDoc()' OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Liberacao de Pedido"  ACTION 'MATA440()'      OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Liberacao Est/Cred"	ACTION 'MATA456'        OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "NF-e Sefaz"	        ACTION 'SPEDNFE()'      OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Exclusao Doc.Saida"   ACTION 'MATA521A()'     OPERATION 6 ACCESS 0

    //Relatórios
    ADD OPTION aSubRel01 TITLE "Impressão de CC-e"    ACTION "MATR185()"  OPERATION 6 ACCESS 0
    ADD OPTION aSubRel01 TITLE "Pré nota"             ACTION "MATR730()"  OPERATION 6 ACCESS 0
    ADD OPTION aRotina   TITLE "Relatórios"           ACTION aSubRel01  OPERATION 6 ACCESS 0
Return aRotina


//-------------------------------------
/*/{Protheus.doc}  fDefineLegenda()
Popula o array com as legendas.
@author  	Súlivan
@param		Array, referencia do array das legandas que serÃ¡ preenchido 
@return 	Undefinied
/*/
//-------------------------------------
Static Function fDefineLegenda(aLegenda)

	aAdd( aLegenda,{ "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)"	,	'ENABLE'		,	'Pedido em Aberto'	})
	aAdd( aLegenda,{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)"	,	'DISABLE'		,	'Pedido Encerrado'	})	
    aAdd( aLegenda,{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)"	,	'BR_AMARELO'	,	'Pedido Liberado'	})	
    aAdd( aLegenda,{ "C5_BLQ == '1'"											,	'BR_AZUL'		,	'Pedido Bloquedo por regra'	})	
    aAdd( aLegenda,{ "C5_BLQ == '2'"											,	'BR_LARANJA'	,	'Pedido Bloquedo por regra'	})	

Return

//-------------------------------------
/*/{Protheus.doc} zGestLeg()
Exibição de legenda no MenuDef
@author  	Súlivan
@return 	Undefinied
@see		Link Totvs: https://tdn.totvs.com/display/public/PROT/BrwLegenda
/*/
//-------------------------------------
User Function zGestLeg()
	
	Local aLegend := {}
	Local nIndice := 0
	
	For nIndice := 1 To Len(aLegenda)    	
    	aAdd(aLegend, { aLegenda[nIndice][COLOR_LEGENDA] , aLegenda[nIndice][TITLE_LEGENDA] } )    		  
    Next
	BrwLegenda ( MVC_TITLE, "Legenda", aLegend  )
Return



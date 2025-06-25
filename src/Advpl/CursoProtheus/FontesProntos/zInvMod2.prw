#Include "protheus.ch"
#Include "totvs.ch"
#Include "topconn.ch"
#Include "FWMBrowse.ch"
#Include "FWMVCDEF.CH"

#Define TABLE "SB7"
#Define STRUCT_MODEL 1
#Define STRUCT_VIEW 2
#Define ID_CABECALHO "SB7MASTER"
#Define ID_GRID "SB7DETAIL"
#Define MVC_TITLE "Inventario Multiplo"
#Define MVC_VIEWDEF_NAME "VIEWDEF.zInvMod2"
#Define CONDITION_LEGENDA 1
#Define COLOR_LEGENDA 2
#Define TITLE_LEGENDA 3

/*/{Protheus.doc} zInvMod2
    
    Fornece uma rotina em MVC que permite ao usuario incluir/excluir/visualizar um inventario 
    com varios itens de uma unica vez.

    @type  Function
    @version 1.0
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=243651808
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=51250512
    @example
        u_zInvMod2()    
/*/
User Function zInvMod2()
    
    Local aArea      := GetArea()
    Local oBrowse    := Nil
    Local nOffWaring := 0
    Local nIndice    := 0

    Private aLegenda   := {}

    fDefineLegenda(@aLegenda)

    //InstÃ¢nciando FWMBrowse, setando a tabela, a descriÃ§Ã£o e ativando a navegaÃ§Ã£o
    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( TABLE )
    oBrowse:SetMenuDef("zInvMod2")
    oBrowse:SetDescription( MVC_TITLE )
    oBrowse:DisableDetails()

    //Definindo Legendas 	        
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

    //ApÃ³s o uso, limpa os objetos da memÃ³ria
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

    Local aRotina := {}

    ADD OPTION aRotina Title 'Visualizar' Action MVC_VIEWDEF_NAME OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotina Title 'Incluir'    Action MVC_VIEWDEF_NAME OPERATION MODEL_OPERATION_INSERT ACCESS 0
   	ADD OPTION aRotina TITLE "Legenda"    Action "u_zInvLeg()"    OPERATION 7 ACCESS 0	   
    ADD OPTION aRotina Title 'Excluir'    Action MVC_VIEWDEF_NAME OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRotina

//-------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo de Dados
@author  	Súlivan
@return 	oModel Objeto do Modelo
/*/
//-------------------------------------
Static Function ModelDef()
    
    Local oStruTable := FWFormStruct( STRUCT_MODEL, TABLE, /*bAvalCampo*/,/*lViewUsado*/ )
    Local oStruTMP   := Nil
    Local oModel     := Nil
    Local lObrigat   := .T.
    Local lVirtual   := .F.
    Local lNoUpd     := .F.
    Local lKey       := .F.
    Local bCommit    := {|oModel| fCommit(@oModel) }
    Local bLoad      := {|oModel, lCopy| fLoad(@oModel, lCopy)}

    //Criando estrutura fake de field para o cabecalho
    oStruTMP:=FWFormModelStruct():New()
    oStruTMP:AddTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})
    oStruTMP:AddField( Alltrim(GetSx3Cache("B7_DOC","X3_TITULO" )),;
                       Alltrim(GetSx3Cache("B7_DOC","X3_DESCRIC")),;
                       Alltrim(GetSx3Cache("B7_DOC","X3_CAMPO"  )),; 
                       Alltrim(GetSx3Cache("B7_DOC","X3_TIPO"   )),;
                       GetSx3Cache("B7_DOC","X3_TAMANHO"),;
                       GetSx3Cache("B7_DOC","X3_DECIMAL"),;
                       FWBuildFeature( STRUCT_FEATURE_VALID, GetSx3Cache("B7_DOC","X3_VALID") ),;
                       FWBuildFeature( STRUCT_FEATURE_WHEN , GetSx3Cache("B7_DOC","X3_WHEN" ) ),;
                       {},;
                       lObrigat,;
                       FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("B7_DOC","X3_VALID") ),;
                       lKey,;
                       lNoUpd,;
                       lVirtual )

    oStruTMP:AddField( Alltrim(GetSx3Cache("B7_DATA","X3_TITULO" )),;
                       Alltrim(GetSx3Cache("B7_DATA","X3_DESCRIC")),;
                       Alltrim(GetSx3Cache("B7_DATA","X3_CAMPO"  )),;
                       Alltrim(GetSx3Cache("B7_DATA","X3_TIPO"   )),;
                       GetSx3Cache("B7_DATA","X3_TAMANHO"),;
                       GetSx3Cache("B7_DATA","X3_DECIMAL"),;
                       FWBuildFeature( STRUCT_FEATURE_VALID, GetSx3Cache("B7_DATA","X3_VALID") ),;
                       FWBuildFeature( STRUCT_FEATURE_WHEN , GetSx3Cache("B7_DATA","X3_WHEN" ) ),;
                       {},;
                       lObrigat,;
                       FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("B7_DATA","X3_VALID") ),;
                       lKey,;
                       lNoUpd,;
                       lVirtual )                       

    //Ajustando estrutura do grid - Retira validações e inicializadores que não estão preparados para MVC
    oStruTable:SetProperty("B7_COD"    ,MODEL_FIELD_INIT ,'')
    oStruTable:SetProperty("B7_COD"    ,MODEL_FIELD_VALID,{|| Vazio() .Or. ExistCpo("SB1") })    
    oStruTable:SetProperty("B7_DESC"   ,MODEL_FIELD_INIT ,{|| Iif(INCLUI, "", Posicione("SB1",1,FWxFilial("SB1")+SB7->B7_COD,"B1_DESC") +" - "+ Posicione("SB1",1,FWxFilial("SB1")+SB7->B7_COD,"B1_UM") ) })
    oStruTable:SetProperty("B7_LOCAL"  ,MODEL_FIELD_VALID,{|| Vazio() .Or. ExistCpo("NNR") })
    oStruTable:SetProperty("B7_QUANT"  ,MODEL_FIELD_VALID,{|| Positivo() })      
    oStruTable:SetProperty("B7_QTSEGUM",MODEL_FIELD_VALID,{|| Positivo() })    
    oStruTable:SetProperty("B7_LOCALIZ",MODEL_FIELD_VALID,{||.T.})
    oStruTable:SetProperty("B7_NUMSERI",MODEL_FIELD_VALID,{||.T.})
    oStruTable:SetProperty("B7_LOTECTL",MODEL_FIELD_VALID,{||.T.})
    oStruTable:SetProperty("B7_NUMLOTE",MODEL_FIELD_VALID,{||.T.})
    oStruTable:SetProperty("B7_CONTAGE",MODEL_FIELD_VALID,{||.T.})
    
    //Inicializador padrão dos campos na Grid
    oStruTable:SetProperty("B7_DOC" ,MODEL_FIELD_INIT ,{||'*'})
    oStruTable:SetProperty("B7_DATA",MODEL_FIELD_INIT ,{||DDATABASE})

    //Adiciona gatilhos básicos na estrutura
    oStruTable:AddTrigger("B7_COD",;
                          "B7_TIPO",;
                          Nil,;
                          {|| Posicione("SB1",1,FWxFilial("SB1")+FwFldGet("B7_COD"),"B1_TIPO") })

    oStruTable:AddTrigger("B7_QUANT",;
                          "B7_QTSEGUM",;
                          Nil,;
                          {|| ConvUM( FwFldGet("B7_COD"), FwFldGet("B7_QUANT"), 0, 2) })                      

    oStruTable:AddTrigger("B7_QTSEGUM",;
                          "B7_QUANT",;
                          Nil,;
                          {|| ConvUM( FwFldGet("B7_COD"), 0,  FwFldGet("B7_QTSEGUM"), 1) })                                            

    oModel := MPFormModel():New( 'MZINVMOD2', /*bPreValidacao*/, /*bPosValidacao*/ , bCommit, /*bCancel*/ )   

    oModel:AddFields( ID_CABECALHO, /*cOwner*/,  oStruTMP, /*bPre*/, /*bPost*/, bLoad )
    oModel:AddGrid( ID_GRID, ID_CABECALHO, oStruTable, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/ )

    //Seta regra para nao haver repetição
    oModel:GetModel(ID_GRID):SetUniqueLine({"B7_COD", "B7_LOCAL", "B7_LOCALIZ", "B7_NUMSERI", "B7_LOTECTL", "B7_NUMLOTE"})

    oModel:SetPrimaryKey({})    

    //Faz relacionamento entre os compomentes do model
    oModel:SetRelation( ID_GRID, { { 'B7_DOC', 'B7_DOC' } , { 'B7_DATA', 'B7_DATA' }} )


    //Adiciona a descricao do novo componente
    oModel:SetDescription( MVC_TITLE )
Return oModel

//-------------------------------------
/*/{Protheus.doc}  ViewDef()
Definicao da View
@author  	Súlivan
@return 	oView Objeto do View
/*/
//-------------------------------------
Static Function ViewDef()

    Local oStruTable := Nil
    Local oStruTMP   := Nil
    Local oModel     := Nil
    Local oView      := Nil
        
    //Estrutura Fake de Field
    oStruTMP := FWFormViewStruct():New()
    oStruTMP:AddField( Alltrim(GetSx3Cache("B7_DOC","X3_CAMPO"  )),;
                       "01",;
                       GetSx3Cache("B7_DOC","X3_TITULO" ),;
                       GetSx3Cache("B7_DOC","X3_DESCRIC"),;
                       GetHlpSoluc("B7_DOC"),;
                       GetSx3Cache("B7_DOC","X3_TIPO"   ))

    oStruTMP:AddField( Alltrim(GetSx3Cache("B7_DATA","X3_CAMPO"  )),;
                       "02",;
                       GetSx3Cache("B7_DATA","X3_TITULO" ),;
                       GetSx3Cache("B7_DATA","X3_DESCRIC"),;
                       GetHlpSoluc("B7_DATA"),;
                       GetSx3Cache("B7_DATA","X3_TIPO"   ))
  
    //Estrutura de Grid
    oStruTable:= FWFormStruct( STRUCT_VIEW, TABLE )
    oStruTable:RemoveField("B7_DOC")
    oStruTable:RemoveField("B7_DATA")

    oModel:= FWLoadModel( 'zInvMod2' )
    oView := FWFormView():New()
    
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_MASTER', oStruTMP, ID_CABECALHO )
    oView:AddGrid(  'VIEW_DETAIL', oStruTable, ID_GRID )

    oView:CreateHorizontalBox( 'SUPERIOR', 15 )
    oView:CreateHorizontalBox( 'INFERIOR', 85 )

    oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_DETAIL', 'INFERIOR' )

Return oView

//-------------------------------------
/*/{Protheus.doc}  fCommit()
Realiza commit das informações no banco de dados.
Commit foi sobreescrito pois validações padrões de campos da rotina não
estão preparados para MVC
@author  	Súlivan
@param		Object, referencia do model
@return 	Logical, .T. caso commit tenha sido com sucesso, .F. caso contrário
/*/
//-------------------------------------
Static Function fCommit(oModel)

    Local lRet        := .T.
    Local oModelGrid  := oModel:GetModel(ID_GRID)
    Local oModelHeader:= oModel:GetModel(ID_CABECALHO)
    Local nLinha      := 0
    Local nColuna     := 0
    Local nPosCpo     := 2
    Local nAcao       := oModel:GetOperation()
    Local aCampos     := oModelGrid:aHeader
    Local aItensSB7   := {}

    Private lMsErroAuto := .F.

    //Quando for inclusao ajusto campos da grid conforme cabecalho
    If nAcao == MODEL_OPERATION_INSERT
        For nLinha:= 1 To oModelGrid:Length() 
            oModelGrid:GoLine(nLinha)
            oModelGrid:SetValue("B7_DOC" ,oModelHeader:GetValue("B7_DOC"))
            oModelGrid:SetValue("B7_DATA",oModelHeader:GetValue("B7_DATA"))
        Next
    EndIf   
    
    Begin Transaction
        For nLinha:= 1 To oModelGrid:Length()
            
            oModelGrid:GoLine(nLinha)  
            If oModelGrid:IsDeleted()
                Loop
            EndIf   

            //Populando array para ExecAuto
            For nColuna:= 1 To Len(aCampos)
                aAdd(aItensSB7, { aCampos[nColuna][nPosCpo], oModelGrid:GetValue(aCampos[nColuna][nPosCpo]) , Nil } )
            Next

            MsExecAuto({|a,b,c| MATA270(a,b,c)}, aItensSB7, .T., nAcao)
            aItensSB7:={}
            
            If lMsErroAuto
                DisarmTransaction()
                MostraErro()
                oModel:SetErrorMessage(ID_GRID, /*cIdField*/, ID_GRID, /*cIdFieldErr*/, "zCommit", "Erro ao salvar inventário", "Corrija os problemas apresentados e tente salvar novamente.", /*xValue*/, /*xOldValue*/ )
                lRet:= .F.   
                Exit
            EndIf
        Next
    End Transaction
Return lRet


//-------------------------------------
/*/{Protheus.doc}  fLoad()
Realiza load das informações na tela quando visualiza/exclui 
Load da estrutura fake do cabecalho
@author  	Súlivan
@param		Object, referencia do model
@return 	Array, Array com os dados
/*/
//-------------------------------------
Static Function fLoad(oModel,lCopy)
    
    Local aLoad := {(TABLE)->B7_DOC, (TABLE)->B7_DATA}
Return aLoad

//-------------------------------------
/*/{Protheus.doc}  fDefineLegenda()
Popula o array com as legendas.
@author  	Súlivan
@param		Array, referencia do array das legandas que serÃ¡ preenchido 
@return 	Undefinied
/*/
//-------------------------------------
Static Function fDefineLegenda(aLegenda)

	aAdd( aLegenda,{ "Alltrim(SB7->B7_STATUS)=='1'" ,"BR_BRANCO" ,"Inventario nao processado"})
	aAdd( aLegenda,{ "Alltrim(SB7->B7_STATUS)=='2'" ,"BR_VERDE"  ,"Inventario processado" 	 })	
Return

//-------------------------------------
/*/{Protheus.doc} zInvLeg()
ExibiÃ§Ã£o de legenda no MenuDef
@author  	Súlivan
@return 	Undefinied
@see		Link Totvs: https://tdn.totvs.com/display/public/PROT/BrwLegenda
/*/
//-------------------------------------
User Function zInvLeg()
	
	Local aLegend := {}
	Local nIndice := 0
	
	For nIndice := 1 To Len(aLegenda)    	
    	aAdd(aLegend, { aLegenda[nIndice][COLOR_LEGENDA] , aLegenda[nIndice][TITLE_LEGENDA] } )    		  
    Next
	BrwLegenda ( MVC_TITLE, "Legenda", aLegend  )
Return

#Include "totvs.ch"
#include 'FWMBrowse.ch'
#Include "FWMVCDEF.CH"

#Define STRUCT_MODEL 1
#Define STRUCT_VIEW 2

/*/{Protheus.doc} zKardexT
    Fornece uma tela contendo op��es de navega��o nos produtos, e consulta de Kardex de poder de teceiro.
    Para ativar a tela de parametros ap�s adentrar na rotina, basta usar a tecla F12

    @type  Function
    @author S�livan Sim�es (sulivansimoes@gmail.com)
    @since 12/02/2022
    @example
       U_zKardexT()

    @see Documenta��o Totvs
            https://tdn.totvs.com/pages/viewpage.action?pageId=446701767#PD3-PD3
            https://tdn.totvs.com/pages/viewpage.action?pageId=446701767#FAT0285PoderDE/EMTerceiro-RNRF
            https://centraldeatendimento.totvs.com/hc/pt-br/articles/360005090232-MP-SIGAEST-Como-efetuar-o-Controle-de-Poder-De-Em-Terceiros-        
/*/
User Function zKardexT()
    
    Local aArea    := GetArea()
    Local oBrowse  := NIL
    Local cFunBkp  := FunName()
    Local bPergunte:= {|| Pergunte("ZKARDEXT",.T.,"Configura��o para consultas")}
    Local nOffWarning := 1

    Private cCadastro := "Kardex poder de 3�"
    Private aRotina   := MenuDef()
   
    //Setando o nome da fun��o, para a fun��o customizada
    SetFunName("zKardexT")

    If eVal(bPergunte)

        SetKey( VK_F12, bPergunte )

        //Inst�nciando FWMBrowse, setando a tabela, a descri��o e ativando a navega��o
        oBrowse:= FWMBrowse():New()
        oBrowse:SetAlias("SB1")
        oBrowse:SetMenuDef("ZKARDEXT")
        oBrowse:SetDescription(cCadastro)
        oBrowse:DisableDetails()
                
        oBrowse:Activate()
                
        //Destr�i a classe      
        oBrowse:DeActivate()
    EndIf

    //Tratamento para n�o dar Warning por n�o chamar as fun��es no c�digo
    If nOffWarning == 0
        MenuDef()
        ModelDef()
        ViewDef()
    Endif

    //Voltando o nome da fun��o
    SetFunName(cFunBkp)
    FreeObj(oBrowse)
    RestArea(aArea)
Return 

//-------------------------------------
/*/{Protheus.doc} MenuDef do Browser
@author  	S�livan
@return 	aRot (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------
Static Function MenuDef()
	Local aRot		:= {}
		
	ADD OPTION aRot TITLE "Consulta"   ACTION "u_zConKdxT()"     OPERATION 5                      ACCESS 0 //"Consulta" 
	ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.ZKARDEXT" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //"Visualizar"
Return (aRot)

//-------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo de Dados
@author  	S�livan
@return 	oModel Objeto do Modelo
/*/
//-------------------------------------
Static Function ModelDef()
	Local oModel   := Nil
	Local oStruSB1 := FWFormStruct( STRUCT_MODEL, "SB1" )
	
	cKeySB1 := AllTrim(oStruSB1:aIndex[1][3]) //Retorna indice prim.
	
	oModel:= MpFormModel():New("MKARDEXT", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:SetDescription("Kardex porder de terceiro") 
	
	oModel:AddFields("SB1MASTER",/*cOwner*/,oStruSB1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( { cKeySB1 } )
Return(oModel)

//-------------------------------------
/*/{Protheus.doc}  ViewDef()
Definicao da View
@author  	S�livan
@return 	oView Objeto do View
/*/
//-------------------------------------
Static Function ViewDef()
	Local oView    := Nil
	Local oModel   := FWLoadModel("ZKARDEXT") 
	Local oStruSB1 := FWFormStruct( STRUCT_VIEW, "SB1" )
	
	oView:= FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_SB1", oStruSB1, "SB1MASTER")
Return(oView)

#Include 'totvs.ch'

/*/{Protheus.doc} zImpCTE
    Realiza importacao de CTE utilizando MATA103 e/ou MATA116
    @type  Function
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 21/03/2022
    @version 1.0
    @example
        u_zImpCTE()
    @see Links Totvs
            https://centraldeatendimento.totvs.com/hc/pt-br/articles/360025397031-MP-SIGACOM-Documento-de-Entrada-Rotina-Autom%C3%A1tica-MATA103-EXECAUTO-
            https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=516629672
            https://tdn.totvs.com/pages/releaseview.action?pageId=6085187
/*/    
User Function zImpCTE()
      
    Local aArea := GetArea()
    Local aPergs:= {}
    Local aRotinas := {"1=[MATA140] Pré Nota", "2=[MATA103] Classificação em Documento de Entrada", "3=[MATA116] NF de conhecimento de frete"}

    //Parametros
	Private cDiretorio_  := "C:\Temp\" + Space(50)
    Private nRotina_ := 2   
	Private cParTes_ := Space(GetSX3Cache('D1_TES','X3_TAMANHO'))
	Private cParArm_ := Space(GetSX3Cache('D1_LOCAL','X3_TAMANHO'))
	Private cParCond_:= Space(GetSX3Cache('F1_COND','X3_TAMANHO'))
	Private cCodPro_ := Space(GetSX3Cache('D1_COD','X3_TAMANHO'))
	Private nTipo    := 2
	
	//Adicionando os parâmetros da tela
	aAdd(aPergs, {1, "Pasta dos XMLs"     , cDiretorio_, "",             ".T.",        "DIRAGR",    ".T.", 120, .T.})
	aAdd(aPergs, {2, "Tipo Importação"    , nTipo      , aRotinas,     122, ".T.", .T.})
	aAdd(aPergs, {1, "TES (Doc.Ent)"      , cParTes_   , "",             ".T.",        "SF4", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Armazém (Doc.Ent)"  , cParArm_   , "",             ".T.",        "NNR", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Cond.Pgto (Doc.Ent)", cParCond_  , "",             ".T.",        "SE4", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Produto"            , cCodPro_   , "",             ".T.",        "SB1", ".T.", 80,  .T.})
	
	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os parametros")
		cDiretorio_   := Alltrim(MV_PAR01)
		nRotina_      := Val(cValToChar(MV_PAR02))
		cParTes_      := MV_PAR03
		cParArm_      := MV_PAR04
		cParCond_     := MV_PAR05
		cCodPro_      := MV_PAR06

        FWMsgRun( ,;
                  {|| fImpCTE() },;
                  "Aguarde",;
                  "Carregando arquivos...";
                 )
    Endif
    RestArea(aArea)
Return 

/*/{Protheus.doc} fImpCTE
    Apresenta painal para importação
    @type  Static Function
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 21/03/2022
    @version 1.0    
/*/
Static Function fImpCTE()

    Local oPainel:= zPainelXML():New()
    oPainel:OpenWindow()
    
    FreeObj(oPainel)
Return  

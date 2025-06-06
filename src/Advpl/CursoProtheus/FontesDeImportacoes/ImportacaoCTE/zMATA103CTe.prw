#Include 'totvs.ch'

#Define XML_DE_CTE 1
#Define XML_DE_NFE 2

/*/{Protheus.doc} zMATA103CTe
    obtem o persistencia  objeto de persistencia especifica
    @author Súlivan Simões (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @See Link Totvs
            https://tdn.totvs.com/pages/releaseview.action?pageId=6085199
            https://tdn.totvs.com.br/pages/releaseview.action?pageId=235592777
            https://centraldeatendimento.totvs.com/hc/pt-br/articles/360025397031-Cross-Segmentos-Totvs-Backoffice-Protheus-SIGACOM-Documento-de-Entrada-Rotina-Autom%C3%A1tica-MATA103-EXECAUTO-

/*/
Class zMATA103CTe
    
    Private Data nOperation As Numeric
    Private Data lIsPreNota As Logical

     //Construtor
	Public Method New()	Constructor

    //Outros Métodos
    Public Method Commit(oNF As Object) As Logical 

EndClass

/*/{Protheus.doc} New
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0   
    @param lIsPreNota, logical, .T. caso seja para classficar como pré-nota, .F. caso seja para classificar como documento.   
/*/
Method New(lPreNota) Class zMATA103CTe
    
    Default lPreNota:= .F.

    ::nOperation := 3
    ::lIsPreNota := lPreNota
    FwLogMsg("INFO", /*cTransactionId*/, "<zMATA103CTe>[New]", FunName(), "", "01", "Classe zMATA103CTe instanciada", 0, 0, {})
Return 

/*/{Protheus.doc} Commit
    Realiza o commit da nota pela rotina MATA103/MATA140 via execAuto
    @author Súlivan Simões (sulivan@atiliosistemas.com)
    @since 04/04/2022    
    @param oNF, Object, objeto de nf-e que deve ser persistido
    @return lMsErroAuto, Logical, .F. caso tenha ocorrido um erro no commit, .T. caso contrário
/*/
Method Commit(oNF) Class zMATA103CTe
   
    Local cCgcEmit   := oNF:GetGCG()
    Local cCodigo    := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_COD" )
    Local cLoja      := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_LOJA")
    Local cItem      := Soma1(Replicate('0', GetSX3Cache("D1_ITEM","X3_TAMANHO")))
    Local nTotalMerc := oNF:GetValorMercadoria()
    Local nSeguro    := 0
    Local nFrete     := 0
    Local nIcmsSubs  := 0
    Local nQtdeLote  := 1
    Local nValLote   := oNF:GetValorPrestacaoServico()
    Local aCabec     := {}
    Local aItens     := {}
    Local aItensRat  := {}
    Local aCodRet    := {}
    Local aLinha     := {}
    
    Private lMsErroAuto := .F.

	aAdd(aCabec, {"F1_TIPO"   , "N"                                      , Nil})
	aAdd(aCabec, {"F1_FORMUL" , "N"                                      , Nil})
	aAdd(aCabec, {"F1_DOC"    , oNF:GetNumeroNotaFiscal()                , Nil})
	aAdd(aCabec, {"F1_SERIE"  , oNF:GetSerieNotaFiscal()                 , Nil})
	aAdd(aCabec, {"F1_EMISSAO", oNF:GetDataEmissao()                     , Nil})
	aAdd(aCabec, {"F1_FORNECE", cCodigo                                  , Nil})
	aAdd(aCabec, {"F1_LOJA"   , cLoja                                    , Nil})
	aAdd(aCabec, {"F1_ESPECIE", "CTE"                                    , Nil})
	aAdd(aCabec, {"F1_SEGURO" , nSeguro                                  , Nil})
	aAdd(aCabec, {"F1_FRETE"  , nFrete                                   , Nil})
	aAdd(aCabec, {"F1_VALMERC", nTotalMerc                               , Nil})
	aAdd(aCabec, {"F1_VALBRUT", nTotalMerc + nSeguro + nFrete + nIcmsSubs, Nil})
	aAdd(aCabec, {"F1_COND"   , cParCond_                                , Nil})
	aAdd(aCabec, {"F1_CHVNFE" , oNF:GetChave()                           , Nil})
	aAdd(aCabec, {"F1_UFORITR", oNF:GetEstadoOrigem()                    , Nil})
	aAdd(aCabec, {"F1_MUORITR", oNF:GetMunOrigem()                       , Nil})
	aAdd(aCabec, {"F1_UFDESTR", oNF:GetEstadoDestino()                   , Nil})
	aAdd(aCabec, {"F1_MUDESTR", oNF:GetMunicipioDestino()                , Nil})
    aAdd(aLinha, {"D1_ITEM"   , cItem  	                                 , Nil})
    aAdd(aLinha, {"D1_COD"    , cCodPro_                                 , Nil})
    aAdd(aLinha, {"D1_QUANT"  , nQtdeLote                                , Nil})               
    aAdd(aLinha, {"D1_VUNIT"  , nValLote    	                         , Nil})
    aAdd(aLinha, {"D1_TOTAL"  , nValLote                                 , Nil})
	aAdd(aLinha, {"D1_TES"    , cParTes_                                 , Nil})
	aAdd(aLinha, {"D1_LOCAL"  , cParArm_                                 , Nil})
    aAdd(aLinha, {"D1_BASEICM", oNF:GetBaseDeCalculoICMS()               , Nil})
    aAdd(aLinha, {"D1_PICM"   , oNF:GetPercentualICMS()                  , Nil})
    aAdd(aLinha, {"D1_VALICM" , oNF:GetValorICMS()                       , Nil})
    aAdd(aLinha, {"D1_CONTA"  , ""                                       , Nil})               
    aAdd(aLinha, {"D1_VALDESC", 0   		                             , Nil})                
    aAdd(aLinha, {"D1_LOTEFOR", ""                                       , Nil})
    aAdd(aLinha, {"AUTDELETA" , "N"                                      , Nil})
    aAdd(aItens, aLinha)

    If ::lIsPreNota
        
        aAdd(aCabec,{"F1_STATUS" , "" , nil} )

        MSExecAuto({|x, y, z| MATA140(x, y, z)}, aCabec, aItens, ::nOperation)
    Else
	    MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCabec,aItens,::nOperation,aItensRat,aCodRet)		
    Endif

    If(lMsErroAuto)
       Alert( "Nota fiscal não importada: "+oNF:GetNumeroNotaFiscal()+"-"+oNF:GetSerieNotaFiscal() )
       MostraErro()
    EndIf

Return !lMsErroAuto

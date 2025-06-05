#Include 'totvs.ch'

/*/{Protheus.doc} zConvertXMLCTeStrategy 
@description Converte o XML oriundo de CTe para objetos.
@author  	Sulivan Simoes (sulivan@atiliosistemas.com)
@since		04/2022
/*/
Class zConvertXMLCTeStrategy From zConvertXML

    Private Data oXML As Object
    
    //Construtor
	Public Method New()	Constructor
    
    //Outros m√©todos
    Public Method IsXMLValid() As Logical
    Public Method GetValorMercadoria() As Numeric
    Public Method GetRazaoSocial() As Character
    Public Method GetGCG() As Character
    Public Method GetNumeroNotaFiscal() As Character
    Public Method GetSerieNotaFiscal() As Character
    Public Method GetDataEmissao() As Date
    Public Method GetEstadoDestino() As Character
    Public Method GetMunicipioDestino() As Character
    Public Method GetEstadoOrigem() As Character
    Public Method GetMunOrigem() As Character
    Public Method GetChave() As Character
    Public Method GetBaseDeCalculoICMS() As Numeric
    Public Method GetPercentualICMS() As Numeric
    Public Method GetValorICMS() As Numeric
    Public Method GetValorPrestacaoServico() As Numeric
EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
@author  	 Sulivan Simoes (sulivan@atiliosistemas.com)
/*/
Method New() Class zConvertXMLCTeStrategy As Object 
    _Super:New(::oXML)
    FwLogMsg("INFO", /*cTransactionId*/, "<zConvertXMLCTeStrategy>[New]", FunName(), "", "01", "Classe zConvertXMLCTeStrategy instanciada", 0, 0, {})
Return Self

/*/{Protheus.doc}IsXMLValid
    @description verifica se o XML tem uma estrutura v√°lida para CT-e
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, .T. se xml for de um ct-e, .F. caso contr√°rio
/*/
Method IsXMLValid() Class zConvertXMLCTeStrategy As Logical
    
    Local lRet := .F.

    If ::GetTagContent("oXML:_cteProc", "O") != Nil
		::oXML := ::oXML:_cteProc:_CTe
        lRet:= .T.
	Elseif ::GetTagContent("oXML:_CTe", "O") != Nil
		::oXML := ::oXML:_CTe
        lRet:= .T.
    Endif
Return lRet

/*/{Protheus.doc}GetValorMercadoria
    @description obtem valor da mercadoria extraido do XML
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, valor da mercadoria extraido do XML
/*/
Method GetValorMercadoria() Class zConvertXMLCTeStrategy As Numeric    
Return ::GetTagContent("oXML:_INFCTE:_vPREST:_vTPREST", "N")

/*/{Protheus.doc}GetRazaoSocial
    @description obtem raz√£o social extraido do XML
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, raz√£o social extraido do XML
/*/
Method GetRazaoSocial() Class zConvertXMLCTeStrategy As Numeric    
Return ::GetTagContent("oXML:_InfCTe:_Emit:_XNOME", "C")

/*/{Protheus.doc}GetGCG
    @since 04/04/2022
    @version 1.0
    @return Character, cnpj/cpf extraido do XML
/*/
Method GetGCG() Class  zConvertXMLCTeStrategy As Character  
    Local cCgcEmit:= ::GetTagContent("oXML:_InfCTe:_Emit:_XNOME", "C")
    If(!Empty(Alltrim(cCgcEmit)))
		cCgcEmit  := ::GetTagContent("oXML:_InfCTe:_Emit:_CNPJ", "C")
	Endif
Return cCgcEmit

/*/{Protheus.doc}GetNumeroNotaFiscal
    @description obtem numero da nota fiscal extraido do XML
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, numero da nota fiscal extraido do XML
/*/
Method GetNumeroNotaFiscal() Class zConvertXMLCTeStrategy As Character
Return StrZero(Val(::GetTagContent("oXML:_InfCTe:_IDE:_nCT", "C")),9)

/*/{Protheus.doc}GetSerieNotaFiscal
    @description obtem serie da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, serie da nota fiscal extraida do XML    
/*/
Method GetSerieNotaFiscal() Class zConvertXMLCTeStrategy As Character
Return Padr(::GetTagContent("oXML:_InfCTe:_IDE:_serie", "C"),3)

/*/{Protheus.doc} GetDataEmissao
    @description obtem data de emiss√£o da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Date, data da nota fiscal extraida do XML    
/*/
Method GetDataEmissao() Class zConvertXMLCTeStrategy As Date
    Local cData:= ::GetTagContent("oXML:_InfCTe:_IDE:_dhEmi", "C")
Return cToD(SubStr(cData,9,2) + "/" + SubStr(cData, 6, 2) + "/" + SubStr(cData, 1, 4))

/*/{Protheus.doc}GetEstadoDestino
    @description obtem estado da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, estado destino da nota fiscal extraida do XML    
/*/
Method GetEstadoDestino() Class zConvertXMLCTeStrategy As Character    
Return ::GetTagContent("oXML:_InfCTe:_IDE:_UFFim", "C")

/*/{Protheus.doc}GetMunicipioDestino
    @description obtem c√≥digo do municipio da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, municpio da nota fiscal extraida do XML    
/*/
Method GetMunicipioDestino() Class zConvertXMLCTeStrategy As Character
    Local cMunDest:= ::GetTagContent("oXML:_InfCTe:_IDE:_cMunFim", "C")
Return SubStr(cMunDest, 3, Len(cMunDest))

/*/{Protheus.doc}GetEstadoDestino
    @description obtem estado da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, estado destino da nota fiscal extraida do XML    
/*/
Method GetEstadoOrigem() Class zConvertXMLCTeStrategy As Character    
Return ::GetTagContent("oXML:_InfCTe:_IDE:_UFIni", "C")

/*/{Protheus.doc}GetMunicipioDestino
    @description obtem c√≥digo do municipio da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, municpio da nota fiscal extraida do XML    
/*/
Method GetMunOrigem() Class zConvertXMLCTeStrategy As Character
    Local cMunOrig:= ::GetTagContent("oXML:_InfCTe:_IDE:_cMunIni", "C")
Return SubStr(cMunOrig, 3, Len(cMunOrig))

/*/{Protheus.doc}GetChave
    @description obtem chave da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Character, chave da nota fiscal extraida do XML    
/*/
Method GetChave() Class zConvertXMLCTeStrategy As Character
Return  SubStr(::GetTagContent("oXML:_INFCTE:_ID", "C"),4,44)

/*/{Protheus.doc}GetBaseDeCalculoICMS
    @description obtem base de calculo de icms da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Numeric, base de calculo de icms da nota fiscal extraida do XML    
/*/
Method GetBaseDeCalculoICMS() Class zConvertXMLCTeStrategy As Numeric    
Return ::GetTagContent("oXML:_InfCTe:_Imp:_ICMS:_ICMS00:_vBC", "N")

/*/{Protheus.doc}GetPercentualICMS
    @description obtem percentual de calculo de icms da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Numeric, percentual de calculo de icms da nota fiscal extraida do XML    
/*/
Method GetPercentualICMS() Class zConvertXMLCTeStrategy As Numeric    
Return ::GetTagContent("oXML:_InfCTe:_Imp:_ICMS:_ICMS00:_pICMS", "N")

/*/{Protheus.doc}GetValorICMS
    @description obtem valor de icms da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Numeric, valor de icms da nota fiscal extraida do XML    
/*/
Method GetValorICMS() Class zConvertXMLCTeStrategy As Numeric    
Return ::GetTagContent("oXML:_InfCTe:_Imp:_ICMS:_ICMS00:_vICMS", "N")

/*/{Protheus.doc}GetValorPrestacaoServico
    @description obtem valor da prestaÁ„o de serviÁo da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 04/04/2022
    @version 1.0
    @return Numeric, da prestaÁ„o de serviÁo da nota fiscal extraida do XML    
/*/
Method GetValorPrestacaoServico() Class zConvertXMLCTeStrategy As Numeric    
Return ::GetTagContent("oXML:_InfCTe:_vPrest:_vTPrest", "N")

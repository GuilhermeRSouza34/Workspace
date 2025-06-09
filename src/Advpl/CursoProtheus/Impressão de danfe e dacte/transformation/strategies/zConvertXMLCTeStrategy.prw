#Include 'Totvs.ch'

/*/{Protheus.doc} zConvertXMLCTeStrategy 
@description Converte o XML oriundo de CTe para objetos.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		04/2022
/*/
Class zConvertXMLCTeStrategy From zConvertXML

    Private Data oXML As Object
    Private Data cTextXML As Character
    Private Data cDiretorio As Character    
    
    //Construtor
	Public Method New()	Constructor
    
    //Outros metodos
    Public Method IsXMLValid() As Logical
    Public Method Print(cXML As Character) 
    Public Method SetDestino(cDiretorio As Character)    

    Public Method GetValorMercadoria() As Numeric
    Public Method GetRazaoSocial() As Character
    Public Method GetGCG() As Character
    Public Method GetNumeroNotaFiscal() As Character
    Public Method GetSerieNotaFiscal() As Character
    Public Method GetDataEmissao() As Date
    Public Method GetChave() As Character
EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
@author  	 Sulivan Simoes (sulivansimoes@gmail.com)
/*/
Method New() Class zConvertXMLCTeStrategy As Object 
    _Super:New(::oXML, @::cTextXML)
    FwLogMsg("INFO", /*cTransactionId*/, "<zConvertXMLCTeStrategy>[New]", FunName(), "", "01", "Classe zConvertXMLCTeStrategy instanciada", 0, 0, {})
Return Self

/*/{Protheus.doc}IsXMLValid
    @description verifica se o XML tem uma estrutura valida para CT-e
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Character, .T. se xml for de um ct-e, .F. caso contrário
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

/*/{Protheus.doc} Print
@description Envia xml para impressao
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
/*/ 
Method Print() Class zConvertXMLCTeStrategy 
        
    Local cAviso     := ''
    Local cErro      := ''
    Local aXml       := {}
    Local cAutoriza  := ''
    Local cCodAutDPEC:= ''
    Local cHorAut    := ''
    Local cDatAut    := ''
    Local cNomePDF   := Alltrim(::GetChave())

    Default cArquivo := ''    

    If(Empty(Alltrim(::cTextXML)))
        u_zConOut("<zDacte>[Print] cXML esta vazio!!!")
    Endif

    ::oXML:= XmlParser(::cTextXML,"_",@cAviso,@cErro)
    If !Empty(cAviso+cErro)
        MsgAlert('Aviso:'+cAviso+;
        Chr(13) + Chr(10) +;
        'Erro:'+cErro,'Problema na leitura do XML')
    Else
    
       aAdd(aXml,{})
       aAdd(aXml[Len(aXml)],cAutoriza)
       aAdd(aXml[Len(aXml)],::cTextXML)
       aAdd(aXml[Len(aXml)],"")
       aAdd(aXml[Len(aXml)],"")
       aAdd(aXml[Len(aXml)],cCodAutDPEC)
       aAdd(aXml[Len(aXml)],cHorAut)
       aAdd(aXml[Len(aXml)],cDatAut)

       cNomePDF:= Iif(Empty(Alltrim(cNomePDF)), Nil, Alltrim(cNomePDF)+'.pdf' )

       U_zRTMSR35(aXml, ::cDiretorio, cNomePDF)
    Endif
Return 

/*/{Protheus.doc} SetDestino
@description Recebe diretorio destino onde sera salvo os dactes impressos
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@param 		cDiretorio, Character, diretorio onde serao salvos os arquivos pdf
/*/ 
Method SetDestino(cDiretorio) Class zConvertXMLCTeStrategy

    cDiretorio:= Alltrim(cDiretorio)+"dacte\"
    MakeDir(cDiretorio)

    ::cDiretorio := cDiretorio
Return 

/*/{Protheus.doc}GetValorMercadoria
    @description obtem valor da mercadoria extraido do XML
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Character, valor da mercadoria extraido do XML
/*/
Method GetValorMercadoria() Class zConvertXMLCTeStrategy As Numeric    
Return Round(::GetTagContent("oXML:_INFCTE:_vPREST:_vTPREST", "N"),2)

/*/{Protheus.doc}GetRazaoSocial
    @description obtem razao social extraido do XML
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Character, razao social extraido do XML
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
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Character, numero da nota fiscal extraido do XML
/*/
Method GetNumeroNotaFiscal() Class zConvertXMLCTeStrategy As Character
Return StrZero(Val(::GetTagContent("oXML:_InfCTe:_IDE:_nCT", "C")),9)

/*/{Protheus.doc}GetSerieNotaFiscal
    @description obtem serie da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Character, serie da nota fiscal extraida do XML    
/*/
Method GetSerieNotaFiscal() Class zConvertXMLCTeStrategy As Character
Return Padr(::GetTagContent("oXML:_InfCTe:_IDE:_serie", "C"),3)

/*/{Protheus.doc} GetDataEmissao
    @description obtem data de emissão da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Date, data da nota fiscal extraida do XML    
/*/
Method GetDataEmissao() Class zConvertXMLCTeStrategy As Date
    Local cData:= ::GetTagContent("oXML:_InfCTe:_IDE:_dhEmi", "C")
Return cToD(SubStr(cData,9,2) + "/" + SubStr(cData, 6, 2) + "/" + SubStr(cData, 1, 4))

/*/{Protheus.doc}GetChave
    @description obtem chave da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 04/04/2022
    @version 1.0
    @return Character, chave da nota fiscal extraida do XML    
/*/
Method GetChave() Class zConvertXMLCTeStrategy As Character
Return  SubStr(::GetTagContent("oXML:_INFCTE:_ID", "C"),4,44)


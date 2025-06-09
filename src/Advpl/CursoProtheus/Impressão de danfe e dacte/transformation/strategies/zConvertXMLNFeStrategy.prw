#Include 'Totvs.ch'

/*/{Protheus.doc} zConvertXMLNFeStrategy 
@description Converte o XML oriundo de NFe para objetos.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		09/2024
/*/
Class zConvertXMLNFeStrategy From zConvertXML

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
Method New() Class zConvertXMLNFeStrategy As Object 
    _Super:New(::oXML, @::cTextXML)    
    FwLogMsg("INFO", /*cTransactionId*/, "<zConvertXMLNFeStrategy>[New]", FunName(), "", "01", "Classe zConvertXMLNFeStrategy instanciada", 0, 0, {})
Return Self

/*/{Protheus.doc}IsXMLValid
    @description verifica se o XML tem uma estrutura valida para NF-e
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Character, .T. se xml for de um ct-e, .F. caso contrario
/*/
Method IsXMLValid() Class zConvertXMLNFeStrategy As Logical
    
    Local lRet := .F.

    If ::GetTagContent("oXML:_NfeProc", "O") != Nil
		::oXML := ::oXML:_NFeProc:_NFe
        lRet:= .T.
	Elseif ::GetTagContent("oXML:_NFe", "O") != Nil
		::oXML := ::oXML:_NFe
        lRet:= .T.
    Endif
Return lRet

/*/{Protheus.doc} Print
@description envia XML para impressao
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
/*/ 
Method Print() Class zConvertXMLNFeStrategy
        
    Local cAviso     := ''
    Local cErro      := ''
    Local cNomePDF   := Alltrim(::GetChave())

    If(Empty(Alltrim(::cTextXML)))
        u_zConOut("<zDanfe>[Print] cXML esta vazio!!!")
    Endif

    ::oXML:= XmlParser(::cTextXML,"_",@cAviso,@cErro)
    If !Empty(cAviso+cErro)
        MsgAlert('Aviso:'+cAviso+;
        Chr(13) + Chr(10) +;
        'Erro:'+cErro,'Problema na leitura do XML')
    Else

        If ::GetTagContent("oXML:_NfeProc", "O") != Nil
	    	::oXML := ::oXML:_NFeProc
        Endif
        
        cNomePDF:= Iif(Empty(Alltrim(cNomePDF)), Nil, Alltrim(cNomePDF)+'.pdf' )

        U_zPrtDanfe(/*oDanfe*/,;
                    ::oXML,;
                    /*cCodAutSef*/,;
                    /*cModalidade*/,;
                    /*oNfeDPEC*/,;
                    /*cCodAutDPEC*/,;
                    /*cDtHrRecCab*/,;
                    /*dDtReceb*/,;
                    /*aNota*/,;
                    /*cMsgRet*/,;
                    ::cDiretorio,;
                    cNomePDF)
    Endif
Return 

/*/{Protheus.doc} SetDestino
@description Recebe diretorio destino onde sera salvo os danfes impressos
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@param 		cDiretorio, Character, diretorio onde serao salvos os arquivos pdf
/*/ 
Method SetDestino(cDiretorio) Class zConvertXMLNFeStrategy

    cDiretorio:= Alltrim(cDiretorio)+"danfe\"
    MakeDir(cDiretorio)

    ::cDiretorio := cDiretorio
Return 

/*/{Protheus.doc}GetValorMercadoria
    @description obtem valor da mercadoria extraido do XML
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Character, valor da mercadoria extraido do XML
/*/
Method GetValorMercadoria() Class zConvertXMLNFeStrategy As Numeric    
Return Round(::GetTagContent("oXML:_InfNFe:_Total:_ICMSTot:_vNF", "N"),2)

/*/{Protheus.doc}GetRazaoSocial
    @description obtem razao social extraido do XML
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Character, razao social extraido do XML
/*/
Method GetRazaoSocial() Class zConvertXMLNFeStrategy As Numeric    
Return ::GetTagContent("oXML:_InfNfe:_Emit:_xNome", "C")

/*/{Protheus.doc}GetGCG
    @since 02/09/2024
    @version 1.0
    @return Character, cnpj/cpf extraido do XML
/*/
Method GetGCG() Class  zConvertXMLNFeStrategy As Character  
    Local cCgcEmit:= ::GetTagContent("oXML:_InfNfe:_Emit:_CNPJ", "C")
    If(Empty(Alltrim(cCgcEmit)))
		cCgcEmit  := ::GetTagContent("oXML:_InfNfe:_Emit:_CPF", "C")
	Endif
Return cCgcEmit

/*/{Protheus.doc}GetNumeroNotaFiscal
    @description obtem numero da nota fiscal extraido do XML
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Character, numero da nota fiscal extraido do XML
/*/
Method GetNumeroNotaFiscal() Class zConvertXMLNFeStrategy As Character
Return StrZero(Val(::GetTagContent("oXML:_InfNfe:_IDE:_nNF", "C")),9)

/*/{Protheus.doc}GetSerieNotaFiscal
    @description obtem serie da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Character, serie da nota fiscal extraida do XML    
/*/
Method GetSerieNotaFiscal() Class zConvertXMLNFeStrategy As Character
Return Padr(::GetTagContent("oXML:_InfNfe:_IDE:_Serie", "C"),3)

/*/{Protheus.doc} GetDataEmissao
    @description obtem data de emissão da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Date, data da nota fiscal extraida do XML    
/*/
Method GetDataEmissao() Class zConvertXMLNFeStrategy As Date
    Local cData:= ::GetTagContent("oXML:_InfNfe:_IDE:_dhEmi", "C")
Return cToD(SubStr(cData,9,2) + "/" + SubStr(cData, 6, 2) + "/" + SubStr(cData, 1, 4))

/*/{Protheus.doc}GetChave
    @description obtem chave da nota fiscal extraida do XML    
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 02/09/2024
    @version 1.0
    @return Character, chave da nota fiscal extraida do XML    
/*/
Method GetChave() Class zConvertXMLNFeStrategy As Character
Return  SubStr(::GetTagContent("oXML:_INFNFE:_ID", "C"),4,44)

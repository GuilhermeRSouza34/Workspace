#Include 'Totvs.ch'

#Define XML_DE_NFE 1
#Define XML_DE_CTE 2

/*/{Protheus.doc} zConvertXML 
@description Converte o XML oriundo de CTe para objetos.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		04/2022
/*/
Class zConvertXML From LongNameClass

    Private Data oXML As Object
    Private Data cTextXML As Character

    //Construtor
	Public Method New()	Constructor

    //Outros metodos
    Public Method ConvertToObject(cXML, cArquivo) As Object
    Public Method GetTagContent(cTag) As Variadic    
    Public Method GetTextXML() As Character
    
    Private Method FixType(xAtributo) As Variadic

EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
@author  	 Sulivan Simoes (sulivansimoes@gmail.com)
/*/
Method New(oXML, cTextXML) Class zConvertXML As Object 
    ::oXML     := oXML
    ::cTextXML := cTextXML
Return Self

/*/{Protheus.doc} ConvertToObject
@description Recebe o XML (em formato de texto) e monta o objeto.
             Caso não passe o XML, o metodo o busca pelo cArquivo
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@param 		cXML, Character, XML de CT-e
@param 		cArquivo, Character, diretório onde está o arquivo. Exemplo c:\temp\arquivo.xml.
            Esse parametro é usado caso cXML esteja em branco
/*/ 
Method ConvertToObject(cXML, cArquivo) Class zConvertXML As Object 
        
    Local cAviso     := ''
    Local cErro      := ''
    Default cXML     := ''
    Default cArquivo := ''    

    If(Empty(Alltrim(cXML)))
        cXML := MemoRead(Alltrim(cArquivo))
    Endif
    ::cTextXML:= cXML 

    ::oXML:= XmlParser(cXML,"_",@cAviso,@cErro)
    If !Empty(cAviso+cErro)
        MsgAlert('Aviso:'+cAviso+;
        Chr(13) + Chr(10) +;
        'Erro:'+cErro,'Problema na leitura do XML')
    Endif
Return 

/*/{Protheus.doc} GetTagContent
@description Recebe a tag a qual se deseja obter o conteudo. 
             Esse metodo ja traz os valores convertidos.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@param 		cTag, Character, tag que deseja-se obter o conteúdo. Exemplo: oXML:_InfCTe:_Emit:_CNPJ. Obrigatório iniciar o nó com oXML:
@param 		cType, Character, tipo de informação que é esperado. Exemplo
            'C' = Caracter
            'N' = Numérico
            Usado para o conteudo ja seja devolvido no tipo correto.
@return     xTagContent, Variadic, conteudo da tag que foi passada via parametro          
/*/ 
Method GetTagContent(cTag, cType) Class zConvertXML As Variadic

    Local xTagContent := Nil
    Private oXML      := ::oXML //Passando para private, para que possa ter tratamento adequado pela Type()

    Default cType := 'C'

    If Type(cTag) !='U'
        xTagContent:= &(Alltrim(cTag+':TEXT'))
    Endif
    xTagContent:= ::FixType(xTagContent,cType)
Return xTagContent

/*/{Protheus.doc} FixType
@description Ajusta o tipo do atributo para o correto que é esperado.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@param 		cTag, Character, tag que deseja-se obter o conteúdo. Exemplo: oNF:_InfCTe:_Emit:_CNPJ
@param 		cType, Character, tipo de informação que é esperado. Exemplo
            'C' = Caracter
            'N' = Numérico
            Usado para o conteudo ja seja devolvido no tipo correto.
@return     xAtributo, Variadic, atributo ja convertido para o tipo certo
/*/ 
Method FixType(xAtributo, cType) Class zConvertXML As Variadic
    
    cType := Upper(cType)
    If cType == 'C' .And. xAtributo == Nil
        xAtributo := ''
    Elseif cType == 'N'
        xAtributo := Iif(xAtributo == Nil, 0, Val(xAtributo) )    
    Endif

    If !(cType $ 'C-N')
        FwLogMsg("WARN", /*cTransactionId*/, "<zConvertXML>[FixType]", FunName(), "", "01", "Tipo: "+cType+" nao encontrado, tipos validos são: C,N", 0, 0, {})
    Endif
Return xAtributo

/*/{Protheus.doc} GetTextXML
@description retorna o xml em formato de uma string
@author  	Sulivan Simoes (sulivansimoes@gmail.com).
@return     cTextXML, Character, xml em caractere
/*/ 
Method GetTextXML() Class zConvertXML As Character
Return ::cTextXML

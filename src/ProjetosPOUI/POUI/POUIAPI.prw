#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} POUIAPI
API REST para integração com frontend POUI
@author Seu Nome
@since 01/01/2024
/*/
//-------------------------------------------------------------------
WSRESTFUL POUIAPI DESCRIPTION "API para integração com POUI"
    WSDATA name AS STRING
    WSDATA code AS INTEGER

    WSMETHOD POST DESCRIPTION "Salva dados do formulário" WSSYNTAX "/POUIAPI"
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Método para salvar dados do formulário
@author Seu Nome
@since 01/01/2024
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSRECEIVE name, code WSSERVICE POUIAPI
Local oResponse := JsonObject():New()
Local cError    := ""

Private oData := JsonObject():New()

::SetContentType("application/json")

Try
    // Recebe os dados do frontend
    oData:FromJson(Self:GetContent())
    
    // Aqui você pode implementar a lógica de negócio
    // Por exemplo, salvar em uma tabela do Protheus
    
    // Retorna sucesso
    oResponse['status'] := .T.
    oResponse['message'] := "Dados salvos com sucesso!"
    
    ::SetResponse(oResponse:ToJson())
    
    Return .T.
    
Catch oError
    // Em caso de erro
    oResponse['status'] := .F.
    oResponse['message'] := "Erro ao salvar: " + oError:Description
    
    ::SetResponse(oResponse:ToJson())
    
    Return .F.
EndTry
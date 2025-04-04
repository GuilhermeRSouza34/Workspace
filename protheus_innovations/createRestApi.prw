#Include "TOTVS.ch"

WSREST Service "MyRestService"
    Resource "example"
        Get ExampleGet()
    EndResource
EndWSREST

// Função para tratar requisição GET no endpoint /example
User Function ExampleGet()
    Local cResponse := '{"message": "Olá, este é um exemplo de Web Service REST no Protheus!"}'
    RestSetContentType("application/json")
    RestSetResponse(cResponse)
    Return

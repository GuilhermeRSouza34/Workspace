#Include "TOTVS.ch"

WSREST Service "MyRestService"
    Resource "example"
        Get ExampleGet()
    EndResource
EndWSREST

// Fun��o para tratar requisi��o GET no endpoint /example
User Function ExampleGet()
    Local cResponse := '{"message": "Ol�, este � um exemplo de Web Service REST no Protheus!"}'
    RestSetContentType("application/json")
    RestSetResponse(cResponse)
    Return

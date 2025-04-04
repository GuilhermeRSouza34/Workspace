#Include "TOTVS.ch"

User Function ConsumeRestApi()
    Local cUrl := "https://jsonplaceholder.typicode.com/posts/1" // URL do Web Service REST
    Local oHttp := HttpClient():New()
    Local cResponse := ""
    Local nStatusCode := 0

    // Realiza a requisi��o GET
    oHttp:Open("GET", cUrl)
    oHttp:Send()

    // Obt�m o c�digo de status da resposta
    nStatusCode := oHttp:nStatusCode

    If nStatusCode == 200
        // Obt�m o conte�do da resposta
        cResponse := oHttp:cResponse
        ConOut("Resposta da API: " + cResponse)
    Else
        ConOut("Erro ao consumir a API. C�digo de status: " + Str(nStatusCode))
    EndIf

    Return

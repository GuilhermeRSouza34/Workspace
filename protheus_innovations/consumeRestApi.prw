#Include "TOTVS.ch"

User Function ConsumeRestApi()
    Local cUrl := "https://jsonplaceholder.typicode.com/posts/1" // URL do Web Service REST
    Local oHttp := HttpClient():New()
    Local cResponse := ""
    Local nStatusCode := 0

    // Realiza a requisição GET
    oHttp:Open("GET", cUrl)
    oHttp:Send()

    // Obtém o código de status da resposta
    nStatusCode := oHttp:nStatusCode

    If nStatusCode == 200
        // Obtém o conteúdo da resposta
        cResponse := oHttp:cResponse
        ConOut("Resposta da API: " + cResponse)
    Else
        ConOut("Erro ao consumir a API. Código de status: " + Str(nStatusCode))
    EndIf

    Return

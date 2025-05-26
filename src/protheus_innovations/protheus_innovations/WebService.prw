#Include "TOTVS.ch"

WSREST Service "ServerTimeService"
    Resource "servertime"
        Get ServerTimeGet()
    EndResource
EndWSREST

// Função para tratar requisição GET no endpoint /servertime
User Function ServerTimeGet()
    Local cDate := DtoS(Date())
    Local cTime := Time()
    Local cResponse := '{"date": "' + cDate + '", "time": "' + cTime + '"}'
    RestSetContentType("application/json")
    RestSetResponse(cResponse)
    Return

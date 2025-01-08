#Include "TOTVS.ch"

Static Begin
    Local cCNPJ := "12345678901234" // CNPJ da empresa
    Local cChaveAcesso := "" // Chave de acesso gerada
    Local cUrlSEFAZ := "" // URL da SEFAZ
    Local cXmlnFe := "" // XML da NF-e

    //Busca os dados da venda
    Local aDadosVenda := GetDadosVenda()

    //Gera o XML da NF-e
    cXmlnFe := GerarXmlNFe(aDadosVenda, cCNPJ)

    //Envia o XML para a SEFAZ
    cChaveAcesso := EnviarXmlNFe(cXmlnFe, cUrlSEFAZ)

    //Verifica o retorno da SEFAZ
    If cChaveAcesso != ""
        Alert("NF-e emitida com sucesso! Chave de acesso: " + cChaveAcesso)
    Else
        Alert("Erro ao emitir NF-e!")
    EndIf
EndIf

Function GerarXmlNFe(aDadosVenda, cCNPJ)
    Local cXml := ""

    // Nessa parte vai o modelo da NF-e e o arquivo XML com base nos dadosda venda

    // Exmplo de estrutura:
    cXml := "<nfe>"
    cXml := cXml + "<infNfe>"
    cXml := cXml + "<emit CNPJ='" + cCNPJ + "'/>"
    // Aqui vai o restante do XML com os dados de produtos, impostos e ETC
    cXml := cXml + "</infNfe>"
    cXml := cXml + "</nfe>"

    Return cXml
End

Function EnviarNfeSEFAZ(cXml, cUrl)
    Local cRetorno := ""

    // Aqui vai o código para enviar o XML para a SEFAZ e receber a chave de acesso
    cRetorno := HttpPost(cUrl, cXml)

    Return cRetorno
End

//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "APWebSrv.ch"

/*
	WSDL:
	/zWsInvoice.apw?WSDL
*/

WsService zWsInvoice Description "WebService de Notas Fiscais"
    //Atributos
    WsData   cXMLRece   as String
    WsData   cXMLSend   as String
    WsData   cDanfeRece as String
    WsData   cDanfeSend as String
 
    //Métodos
    WsMethod GetXML        Description "Metodo para buscar o XML da NF"
    WsMethod GetDanfe      Description "Metodo para gerar o pdf da Danfe"
EndWsService

/*
    Método GetXML
    Metodo que retorna o xml da NF

    Exemplo do JSON que será recebido
	{
		"Dados": {
            "Filial": "aaaa",
			"NotaFiscal": "bbbb",
            "Serie": "cccc"
    	},
    	"Token" : "dddd"
	}
*/
 
WsMethod GetXML WsReceive cXMLRece WsSend cXMLSend WsService zWsInvoice
    Local lRet := .T.

    //Variável de Token pegando da tabela SX6
    Local cTokWs := Alltrim(GetMV('MV_X_TOKEN'))

	//Parâmetros vindos do JSON
	Local cParFilial := ""
	Local cParNotFis := ""
	Local cParSerie  := ""
	
	//Variáveis usadas para busca do xml
	Local cURLTss
    Local oWebServ
    Local cIdEnt
    Local cTextoXML    := ""

    //Variáveis usadas para transformar o JSON em Objeto
    Private oJSON    := JsonObject():New()
    Private oDados   := Nil

    //Deserializando o JSON
	cError := oJson:FromJson(::cXMLRece)
	If Empty(cError)
		oDados  := oJSON:GetJsonObject('Dados')
		cToken  := Iif(ValAtrib("oJSON:GetJsonObject('Token')") != "U", oJSON:GetJsonObject('Token'), "")
		
		//Se for o mesmo Token
		If cToken == cTokWs
			cParFilial := Iif(ValAtrib("oDados:Filial")   != "U", oDados:Filial, "")
			cParNotFis := Iif(ValAtrib("oDados:NotaFiscal")   != "U", oDados:NotaFiscal, "")
			cParSerie  := Iif(ValAtrib("oDados:Serie")   != "U", oDados:Serie, "")
			

            //Se não tiver os dados, retorna erro
            If Empty(cParFilial) .Or. Empty(cParNotFis) .Or. Empty(cParSerie)
                SetSoapFault('Erro', 'Filtro incorreto!')
			    lRet := .F.
            Else

                //Altera a filial e a empresa
                cEmpBkp := cEmpAnt
				cFilBkp := cFilAnt
                cNumEmpBkp := cNumEmp
                //cEmpAnt := SubStr(cParFilial, 1, 2)
				cFilAnt := cParFilial
                cNumEmp := Alltrim(cEmpAnt) + AllTrim(cFilAnt)
				OpenFile(cNumEmp)

				//Define as parametrizações
				cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
				cIdEnt       := RetIdEnti() //StaticCall(SPEDNFE, GetIdEnt)
				cParNotFis   := PadR(cParNotFis, TamSX3('F2_DOC')[1])
				cParSerie    := PadR(cParSerie,     TamSX3('F2_SERIE')[1])
				 
				//Instancia a conexão com o WebService do TSS    
				oWebServ:= WSNFeSBRA():New()
				oWebServ:cUSERTOKEN        := "TOTVS"
				oWebServ:cID_ENT           := cIdEnt
				oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
				oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
				aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
				aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cParSerie+cParNotFis)
				oWebServ:nDIASPARAEXCLUSAO := 0
				oWebServ:_URL              := AllTrim(cURLTss)+"NFeSBRA.apw"   
				 
				//Se tiver notas
				If oWebServ:RetornaNotas()
				 
					//Se tiver dados
					If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
					 
						//Se tiver sido cancelada
						If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
							cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
							 
						//Senão, pega o xml normal
						Else
							cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
						EndIf
						 
						//Retira as aspas do XML
						cTextoXML := StrTran(cTextoXML, '"', "'")
						
						//Define o retorno do webservice
						cDados := '  "Dados" : { '                       + CRLF
						cDados += '     "XML":"' + cTextoXML + '" '      + CRLF
						cDados += '  } '                                 + CRLF

						::cXMLSend := "{" + CRLF
						::cXMLSend += cDados
						::cXMLSend += "}" + CRLF
						 
					//Caso não encontre as notas, mostra mensagem
					Else
						SetSoapFault('Erro', "zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cParNotFis+"/"+cParSerie+")...")
						lRet := .F.
					EndIf
				 
				//Senão, houve erros na classe
				Else
					SetSoapFault('Erro', "zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
					lRet := .F.
				EndIf
				
                //Volta a empresa e filial
				cFilAnt := cFilBkp
                cNumEmp := cNumEmpBkp
                cEmpAnt := cEmpBkp
                OpenFile(cNumEmp)
                
            EndIf

        Else
            SetSoapFault('Erro', 'Token invalido!')
			lRet := .F.
        EndIf
    Else
        SetSoapFault('Erro', 'JSON nao deserializado!')
		lRet := .F.
    EndIf

Return lRet

/*
    Método GetDanfe
    Metodo que monta a Danfe da NFe

    Exemplo do JSON que será recebido
	{
		"Dados": {
            "Filial": "aaaa",
			"NotaFiscal": "bbbb",
            "Serie": "cccc"
    	},
    	"Token" : "dddd"
	}
*/
 
WsMethod GetDanfe WsReceive cDanfeRece WsSend cDanfeSend WsService zWsInvoice
    Local lRet := .T.

    //Variável de Token pegando da tabela SX6
    Local cTokWs := Alltrim(GetMV('MV_X_TOKEN'))

	//Parâmetros vindos do JSON
	Local cParFilial := ""
	Local cParNotFis := ""
	Local cParSerie  := ""

    //Variáveis usadas para transformar o JSON em Objeto
    Private oJSON    := JsonObject():New()
    Private oDados   := Nil

    //Deserializando o JSON
	cError := oJson:FromJson(::cDanfeRece)
	If Empty(cError)
		oDados  := oJSON:GetJsonObject('Dados')
		cToken  := Iif(ValAtrib("oJSON:GetJsonObject('Token')") != "U", oJSON:GetJsonObject('Token'), "")
		
		//Se for o mesmo Token
		If cToken == cTokWs
			cParFilial := Iif(ValAtrib("oDados:Filial")   != "U", oDados:Filial, "")
			cParNotFis := Iif(ValAtrib("oDados:NotaFiscal")   != "U", oDados:NotaFiscal, "")
			cParSerie  := Iif(ValAtrib("oDados:Serie")   != "U", oDados:Serie, "")
			

            //Se não tiver os dados, retorna erro
            If Empty(cParFilial) .Or. Empty(cParNotFis) .Or. Empty(cParSerie)
                SetSoapFault('Erro', 'Filtro incorreto!')
			    lRet := .F.
            Else

                //Altera a filial e a empresa
                cEmpBkp := cEmpAnt
				cFilBkp := cFilAnt
                cNumEmpBkp := cNumEmp
                //cEmpAnt := SubStr(cParFilial, 1, 2)
				cFilAnt := cParFilial
                cNumEmp := Alltrim(cEmpAnt) + AllTrim(cFilAnt)
				OpenFile(cNumEmp)

				//Define a pasta e o arquivo, caso a pasta não exista, cria
				cPasta := "\x_nfe\"
				cArqDanfe := "danfe_" + dToS(Date()) + "_" + StrTran(Time(), ':', '')
				
				If ! ExistDir(cPasta)
					MakeDir(cPasta)
				EndIf
				
				//Chama a geração da danfe
				u_zGerDanfe(cParNotFis, cParSerie, cPasta, cArqDanfe)
				
				//Se o arquivo existir
				If File(cPasta + cArqDanfe + ".pdf")
					//Tenta abrir o arquivo
					oFile   := FwFileReader():New(cPasta + cArqDanfe + ".pdf")
					If oFile:Open()
						cFileConteu     := oFile:FullRead()
						cFileEncode     := Encode64(cFileConteu, , .F., .F.)
						
						//Define o retorno do webservice
						cDados := '  "Dados" : { '                       + CRLF
						cDados += '     "Danfe":"' + cFileEncode + '" '  + CRLF
						cDados += '  } '                                 + CRLF

						::cDanfeSend := "{" + CRLF
						::cDanfeSend += cDados
						::cDanfeSend += "}" + CRLF
					
					Else
						SetSoapFault('Erro', "Falha ao processar o pdf da Danfe")
						lRet := .F.
					EndIf
				 
				//Senão, houve erros na classe
				Else
					SetSoapFault('Erro', "Falha ao gerar o pdf da Danfe")
					lRet := .F.
				EndIf
				
                //Volta a empresa e filial
				cFilAnt := cFilBkp
                cNumEmp := cNumEmpBkp
                cEmpAnt := cEmpBkp
                OpenFile(cNumEmp)
                
            EndIf

        Else
            SetSoapFault('Erro', 'Token invalido!')
			lRet := .F.
        EndIf
    Else
        SetSoapFault('Erro', 'JSON nao deserializado!')
		lRet := .F.
    EndIf

Return lRet

Static Function ValAtrib(xAtributo)
Return ( Type(xAtributo) )
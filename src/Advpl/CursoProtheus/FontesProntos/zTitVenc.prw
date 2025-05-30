//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zTitVenc
Job que notifica os títulos vencidos para clientes
@author Atilio
@since 10/09/2021
@version 1.0
@example
u_zTitVenc()
@obs O modelo do HTML usado, foi baixado em - https://unlayer.com/templates/registration-completion
/*/

User Function zTitVenc()
	Local aArea
	Local lContinua   := .F.
    Private lJobPvt      := .F.
	
	//Se o ambiente não estiver em pé, sobe para usar de maneira automática
    If Select("SX2") == 0
        lJobPvt := .T.
        lContinua := .T.
		RPCSetEnv("99", "01", "", "", "", "")
    EndIf
    aArea := GetArea()

    //Se não for modo automático, mostra uma pergunta
    If ! lJobPvt
        lContinua := MsgYesNo("Deseja gerar o e-Mail dos títulos vencidos?", "Atenção")
    EndIf

    //Se for continuar, faz a chamada para o disparo do e-Mail
    If lContinua
        Processa({|| fProcDad() }, "Processando...")
    EndIf
	
	RestArea(aArea)
Return

Static Function fProcDad()
	Local nAtual
	Local nTotal
	Local nDias		  := 2
	Local cQuery      := ""
	Local aSM0Data    := FWSM0Util():GetSM0Data(, cFilAnt, {"M0_NOME", "M0_ENDCOB", "M0_BAIRCOB", "M0_CIDCOB", "M0_ESTCOB"})
	//Variáveis usadas no disparo
	Private aDados	  := {}
	Private cParaCC   := "teste@teste.com;"
	Private cNomeEmpr := Alltrim(aSM0Data[01][2])
	Private cEndEmpr  := Alltrim(aSM0Data[02][2]) + " - " + Alltrim(aSM0Data[03][2]) + ", " + Alltrim(aSM0Data[04][2]) + " - " + Alltrim(aSM0Data[05][2])
	Private cLogo     := "http://terminaldeinformacao.com/wp-content/uploads/2012/08/ti_logo_fim.png"
	Private cDominio  := "@terminaldeinformacao.com"
	Private cLinkCont := "https://terminaldeinformacao.com/contato/"
	Private cWhats    := "(14) 9 9738-5495"
	Private cLinkWhat := "https://api.whatsapp.com/send?phone=5514997385495"
	
	//Se o último caracter do email que irá receber em cópia não for ;, adiciona
	If SubStr(cParaCC, Len(cParaCC) - 1, 1) != ';'
		cParaCC += ';'
	EndIf
	
	//Buscando os títulos que venceram, conforme o número de dias na variável nDias
	cQuery := " SELECT " + CRLF
	cQuery += " 	E1_CLIENTE + ' ' + E1_LOJA AS COD_CLI, " + CRLF
	cQuery += " 	A1_EMAIL, " + CRLF
	cQuery += " 	E1_NOMCLI, " + CRLF
	cQuery += " 	E1_FILIAL, " + CRLF
	cQuery += " 	E1_PREFIXO, " + CRLF
	cQuery += " 	E1_NUM, " + CRLF
	cQuery += " 	E1_PARCELA, " + CRLF
	cQuery += " 	E1_EMISSAO, " + CRLF
	cQuery += " 	E1_VENCTO, " + CRLF
	cQuery += " 	E1_SALDO, " + CRLF
	cQuery += " 	A1_COD " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += " 	" + RetSQLName("SE1") + " SE1 " + CRLF
	cQuery += " 	INNER JOIN " + RetSQLName("SA1") + " SA1 ON ( " + CRLF
	cQuery += " 		A1_COD = E1_CLIENTE " + CRLF
	cQuery += " 		AND A1_LOJA = E1_LOJA " + CRLF
	cQuery += " 		AND SA1.D_E_L_E_T_ = '' " + CRLF
	cQuery += " 	) " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " 	E1_SALDO > 0 " + CRLF
	cQuery += " 	AND E1_VENCTO = '" + dToS(DaySub(dDataBase, nDias)) + "' " + CRLF
	cQuery += " 	AND SE1.D_E_L_E_T_ = '' " + CRLF
	cQuery += " 	AND E1_TIPO IN ('NF') " + CRLF
	cQuery += " ORDER BY " + CRLF
	cQuery += " 	E1_CLIENTE " + CRLF
	TCQuery cQuery New Alias "QRY_SE1"

	//Define as colunas como tipo Data
	TCSetField('QRY_SE1', 'E1_EMISSAO', 'D')
	TCSetField('QRY_SE1', 'E1_VENCTO', 'D')
	
	//Define o tamanho da régua
	Count To nTotal
	ProcRegua(nTotal)
	QRY_SE1->(DbGoTop())
	
	//Percorrendo os registros
	While ! QRY_SE1->(EoF())

		//Incrementa a régua
		nAtual++
		IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		
		//Adiciona dados dos títulos
		aDados := {}
		aAdd(aDados, QRY_SE1->COD_CLI)
		aAdd(aDados, QRY_SE1->A1_EMAIL)
		aAdd(aDados, QRY_SE1->E1_NOMCLI)
		aAdd(aDados, QRY_SE1->E1_FILIAL)
		aAdd(aDados, QRY_SE1->E1_PREFIXO)
		aAdd(aDados, QRY_SE1->E1_NUM)
		aAdd(aDados, QRY_SE1->E1_PARCELA)
		aAdd(aDados, QRY_SE1->E1_EMISSAO)
		aAdd(aDados, QRY_SE1->E1_VENCTO)
		aAdd(aDados, QRY_SE1->E1_SALDO)

		//Dispara o e-Mail
		fDispEma()
		
		QRY_SE1->(DbSkip())
	EndDo
	QRY_SE1->(DbCloseArea())
Return

Static Function fDispEma()
	Local cNumTit   := aDados[6] + '/' + aDados[7]
	Local dDtEmiss  := aDados[8]
	Local dDtVenci  := aDados[9]
	Local cNomeCli  := Alltrim(aDados[3])
	Local cEmaClie  := aDados[2]
	Local cMensagem := ""

	//Monta a mensagem que será enviada
	cMensagem := ""
	cMensagem += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> ' + CRLF
	cMensagem += '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"> ' + CRLF
	cMensagem += '   <head> ' + CRLF
	cMensagem += '      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> ' + CRLF
	cMensagem += '      <meta name="viewport" content="width=device-width, initial-scale=1.0"> ' + CRLF
	cMensagem += '      <meta name="x-apple-disable-message-reformatting"> ' + CRLF
	cMensagem += '      <meta http-equiv="X-UA-Compatible" content="IE=edge"> ' + CRLF
	cMensagem += '      <title>Títulos Vencidos</title> ' + CRLF
	cMensagem += '      <style type="text/css"> ' + CRLF
	cMensagem += '         table, td { color: #000000; } a { color: #0000ee; text-decoration: underline; } @media (max-width: 480px) { #u_content_image_1 .v-src-width { width: 429px !important; } #u_content_image_1 .v-src-max-width { max-width: 37% !important; } #u_content_image_1 .v-text-align { text-align: left !important; } #u_content_text_1 .v-text-align { text-align: left !important; } #u_content_text_5 .v-text-align { text-align: left !important; } #u_content_text_5 .v-line-height { line-height: 170% !important; } #u_content_button_1 .v-container-padding-padding { padding: 10px 10px 30px 20px !important; } #u_content_button_1 .v-text-align { text-align: left !important; } } ' + CRLF
	cMensagem += '         @media only screen and (min-width: 570px) { ' + CRLF
	cMensagem += '         .u-row { ' + CRLF
	cMensagem += '         width: 550px !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-row .u-col { ' + CRLF
	cMensagem += '         vertical-align: top; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-row .u-col-50 { ' + CRLF
	cMensagem += '         width: 275px !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-row .u-col-100 { ' + CRLF
	cMensagem += '         width: 550px !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         @media (max-width: 570px) { ' + CRLF
	cMensagem += '         .u-row-container { ' + CRLF
	cMensagem += '         max-width: 100% !important; ' + CRLF
	cMensagem += '         padding-left: 0px !important; ' + CRLF
	cMensagem += '         padding-right: 0px !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-row .u-col { ' + CRLF
	cMensagem += '         min-width: 320px !important; ' + CRLF
	cMensagem += '         max-width: 100% !important; ' + CRLF
	cMensagem += '         display: block !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-row { ' + CRLF
	cMensagem += '         width: calc(100% - 40px) !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-col { ' + CRLF
	cMensagem += '         width: 100% !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .u-col > div { ' + CRLF
	cMensagem += '         margin: 0 auto; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         body { ' + CRLF
	cMensagem += '         margin: 0; ' + CRLF
	cMensagem += '         padding: 0; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         table, ' + CRLF
	cMensagem += '         tr, ' + CRLF
	cMensagem += '         td { ' + CRLF
	cMensagem += '         vertical-align: top; ' + CRLF
	cMensagem += '         border-collapse: collapse; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         p { ' + CRLF
	cMensagem += '         margin: 0; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         .ie-container table, ' + CRLF
	cMensagem += '         .mso-container table { ' + CRLF
	cMensagem += '         table-layout: fixed; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         * { ' + CRLF
	cMensagem += '         line-height: inherit; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '         a[x-apple-data-detectors=true] { ' + CRLF
	cMensagem += '         color: inherit !important; ' + CRLF
	cMensagem += '         text-decoration: none !important; ' + CRLF
	cMensagem += '         } ' + CRLF
	cMensagem += '      </style> ' + CRLF
	cMensagem += '      <link href="https://fonts.googleapis.com/css?family=Raleway:400,700&display=swap" rel="stylesheet" type="text/css"> ' + CRLF
	cMensagem += '      <link href="https://fonts.googleapis.com/css?family=Rubik:400,700&display=swap" rel="stylesheet" type="text/css"> ' + CRLF
	cMensagem += '   </head> ' + CRLF
	cMensagem += '   <body class="clean-body" style="margin: 0;padding: 0;-webkit-text-size-adjust: 100%;background-color: #b8cce2;color: #000000"> ' + CRLF
	cMensagem += '      <table style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;min-width: 320px;Margin: 0 auto;background-color: #b8cce2;width:100%" cellpadding="0" cellspacing="0"> ' + CRLF
	cMensagem += '         <tbody> ' + CRLF
	cMensagem += '            <tr style="vertical-align: top"> ' + CRLF
	cMensagem += '               <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top"> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:5px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <table height="0px" align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 0px solid #BBBBBB;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                   <tbody> ' + CRLF
	cMensagem += '                                                      <tr style="vertical-align: top"> ' + CRLF
	cMensagem += '                                                         <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                            <span>&#160;</span> ' + CRLF
	cMensagem += '                                                         </td> ' + CRLF
	cMensagem += '                                                      </tr> ' + CRLF
	cMensagem += '                                                   </tbody> ' + CRLF
	cMensagem += '                                                </table> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: #44b587;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table id="u_content_image_1" style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:20px 10px 20px 20px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <table width="100%" cellpadding="0" cellspacing="0" border="0"> ' + CRLF
	cMensagem += '                                                   <tr> ' + CRLF
	cMensagem += '                                                      <td class="v-text-align" style="padding-right: 0px;padding-left: 0px;" align="left"> ' + CRLF
	cMensagem += '                                                         <img align="left" border="0" src="' + cLogo + '" alt="Image" title="Image" style="outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: inline-block !important;border: none;height: auto;float: none;width: 10%;"  class="v-src-width v-src-max-width"/> ' + CRLF
	cMensagem += '                                                      </td> ' + CRLF
	cMensagem += '                                                   </tr> ' + CRLF
	cMensagem += '                                                </table> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: #ffffff;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:0px 0px 30px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <table height="0px" align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 4px solid #f1c40f;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                   <tbody> ' + CRLF
	cMensagem += '                                                      <tr style="vertical-align: top"> ' + CRLF
	cMensagem += '                                                         <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                            <span>&#160;</span> ' + CRLF
	cMensagem += '                                                         </td> ' + CRLF
	cMensagem += '                                                      </tr> ' + CRLF
	cMensagem += '                                                   </tbody> ' + CRLF
	cMensagem += '                                                </table> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                    <table id="u_content_text_1" style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:10px 20px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #132f40; line-height: 140%; text-align: left; word-wrap: break-word;"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 140%;"><span style="font-family: Rubik, sans-serif; font-size: 16px; line-height: 22.4px;">Olá <strong>' + cNomeCli + '</strong>, </p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:10px 20px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word;"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px;">Este é um lembrete eletrônico automático.</span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word; margin-top: 5px"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px;">A data de vencimento do boleto <b>' + cNumTit + '</b> referente à compra do dia <b>' + dToC(dDtEmiss) + '</b> venceu em <b>' + dToC(dDtVenci) + '</b>.</span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word; margin-top: 5px"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px;">Caso já tenha realizado o pagamento, ou saldado o compromisso de qualquer outra forma, por favor, desconsidere este lembrete!</span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word; margin-top: 5px"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px; color: red;"><b>ATENÇÃO:</b></span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word; margin-top: 5px"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px;">Somente enviamos o boleto por e-Mail quando solicitado pelo cliente - Domínio correto: <font color="red">' + cDominio + '</font></span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word; margin-top: 5px"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px;">A ' + cNomeEmpr + ', não se responsabiliza por eventuais prejuízos gerados por pagamentos de boletos <font color="red">FRAUDADOS</font>.</span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #333333; line-height: 180%; text-align: left; word-wrap: break-word; margin-top: 5px"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 180%;"><span style="font-family: Raleway, sans-serif; font-size: 14px; line-height: 25.2px;">Em casos de dúvidas ou alguma cobrança que sugira a possibilidade de fraude, nos contate imediatamente clicando no botão abaixo.</span></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: #d5f7e6;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent; margin-top: 20px"> ' + CRLF
	cMensagem += '                                    <table id="u_content_button_1" style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:10px 10px 30px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <div class="v-text-align" align="center"> ' + CRLF
	cMensagem += '                                                   <a href="' + cLinkCont + '" target="_blank" style="box-sizing: border-box;display: inline-block;font-family:Raleway,sans-serif;text-decoration: none;-webkit-text-size-adjust: none;text-align: center;color: #FFFFFF; background-color: #2dc26b; border-radius: 20px; -webkit-border-radius: 20px; -moz-border-radius: 20px; width:auto; max-width:100%; overflow-wrap: break-word; word-break: break-word; word-wrap:break-word; mso-border-alt: none;border-top-color: #f1c40f; border-top-style: solid; border-top-width: 2px; border-left-color: #f1c40f; border-left-style: solid; border-left-width: 2px; border-right-color: #f1c40f; border-right-style: solid; border-right-width: 2px; border-bottom-color: #f1c40f; border-bottom-style: solid; border-bottom-width: 2px;"> ' + CRLF
	cMensagem += '                                                   <span class="v-line-height" style="display:block;padding:10px 25px;line-height:120%;"><span style="font-size: 14px; line-height: 16.8px;">Clique aqui para entrar em contato</span></span> ' + CRLF
	cMensagem += '                                                   </a> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: #132f40;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:5px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <table height="0px" align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 0px solid #BBBBBB;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                   <tbody> ' + CRLF
	cMensagem += '                                                      <tr style="vertical-align: top"> ' + CRLF
	cMensagem += '                                                         <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                            <span>&#160;</span> ' + CRLF
	cMensagem += '                                                         </td> ' + CRLF
	cMensagem += '                                                      </tr> ' + CRLF
	cMensagem += '                                                   </tbody> ' + CRLF
	cMensagem += '                                                </table> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: #132f40;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-50" style="max-width: 320px;min-width: 275px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:10px 20px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <div class="v-text-align v-line-height" style="color: #ffffff; line-height: 150%; text-align: left; word-wrap: break-word;"> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 150%;"><strong>' + cNomeEmpr + '</strong></p> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 150%;">' + cEndEmpr + '</p> ' + CRLF
	cMensagem += '                                                   <p style="font-size: 14px; line-height: 150%;">WhatsApp: <a href="' + cLinkWhat + '" title="WhatsApp" target="_blank" style="color: white;"> ' + cWhats + '</a></p> ' + CRLF
	cMensagem += '                                                </div> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: #132f40;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:5px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <table height="0px" align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 0px solid #BBBBBB;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                   <tbody> ' + CRLF
	cMensagem += '                                                      <tr style="vertical-align: top"> ' + CRLF
	cMensagem += '                                                         <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                            <span>&#160;</span> ' + CRLF
	cMensagem += '                                                         </td> ' + CRLF
	cMensagem += '                                                      </tr> ' + CRLF
	cMensagem += '                                                   </tbody> ' + CRLF
	cMensagem += '                                                </table> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '                  <div class="u-row-container" style="padding: 0px;background-color: transparent"> ' + CRLF
	cMensagem += '                     <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 550px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;"> ' + CRLF
	cMensagem += '                        <div style="border-collapse: collapse;display: table;width: 100%;background-color: transparent;"> ' + CRLF
	cMensagem += '                           <div class="u-col u-col-100" style="max-width: 320px;min-width: 550px;display: table-cell;vertical-align: top;"> ' + CRLF
	cMensagem += '                              <div style="width: 100% !important;"> ' + CRLF
	cMensagem += '                                 <div style="padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"> ' + CRLF
	cMensagem += '                                    <table style="font-family:Raleway,sans-serif;" role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0"> ' + CRLF
	cMensagem += '                                       <tbody> ' + CRLF
	cMensagem += '                                          <tr> ' + CRLF
	cMensagem += '                                             <td class="v-container-padding-padding" style="overflow-wrap:break-word;word-break:break-word;padding:5px;font-family:Raleway,sans-serif;" align="left"> ' + CRLF
	cMensagem += '                                                <table height="0px" align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 0px solid #BBBBBB;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                   <tbody> ' + CRLF
	cMensagem += '                                                      <tr style="vertical-align: top"> ' + CRLF
	cMensagem += '                                                         <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%"> ' + CRLF
	cMensagem += '                                                            <span>&#160;</span> ' + CRLF
	cMensagem += '                                                         </td> ' + CRLF
	cMensagem += '                                                      </tr> ' + CRLF
	cMensagem += '                                                   </tbody> ' + CRLF
	cMensagem += '                                                </table> ' + CRLF
	cMensagem += '                                             </td> ' + CRLF
	cMensagem += '                                          </tr> ' + CRLF
	cMensagem += '                                       </tbody> ' + CRLF
	cMensagem += '                                    </table> ' + CRLF
	cMensagem += '                                 </div> ' + CRLF
	cMensagem += '                              </div> ' + CRLF
	cMensagem += '                           </div> ' + CRLF
	cMensagem += '                        </div> ' + CRLF
	cMensagem += '                     </div> ' + CRLF
	cMensagem += '                  </div> ' + CRLF
	cMensagem += '               </td> ' + CRLF
	cMensagem += '            </tr> ' + CRLF
	cMensagem += '         </tbody> ' + CRLF
	cMensagem += '      </table> ' + CRLF
	cMensagem += '   </body> ' + CRLF
	cMensagem += '</html> ' + CRLF

	//Dispara o e-Mail
	u_zEnvMail(cParaCC + cEmaClie, "Títulos Vencidos", cMensagem)
Return

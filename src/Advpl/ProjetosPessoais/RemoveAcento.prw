#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

User Function Acento()

//Variavel com os caracter acentuados 
	Local cTexto := 'Até / Olá / É / ó / Ó / Vô / ão / ç '

//Mensagem com caracter acentuados 
	MsgInfo( 'Valor: ' + cTexto + CRLF + ' Retorno: ' +

//função para tirar os acento dos caracater
	FwNoAccent(cTexto), 'totversadvpl' )

Return


#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

User Function Acento()

//Variavel com os caracter acentuados 
	Local cTexto := 'At� / Ol� / � / � / � / V� / �o / � '

//Mensagem com caracter acentuados 
	MsgInfo( 'Valor: ' + cTexto + CRLF + ' Retorno: ' +

//fun��o para tirar os acento dos caracater
	FwNoAccent(cTexto), 'totversadvpl' )

Return


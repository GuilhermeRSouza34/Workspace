#Include "totvs.ch"

/*/{Protheus.doc} zConOut
Aciona a função para escrever o log no console. 
Todos os logs devem chamar essa função, pois se a Totvs descontinuar novamente alguma função de log
basta atualizar somente aqui.
@author Sulivan Simoes (sulivan@atiliosistemas.com)
@since 01/03/2021
@version 1.0
@type function
    @param cLog, log que será escrito no console.    
/*/
User Function zConOut(cLog)
	
	Default cLog := "Log empty"
		
	QQout("u_zConOut - " + cValToChar(cLog))
Return

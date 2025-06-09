//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function MT010INC
Após inclusão do produto
@author Atilio
@since 14/09/2024
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6087685
/*/

User Function MT010INC()
	Local aArea   := FWGetArea()
	Local cMsgLog := ""
	
    //Aciona o sincronismo para criar a SBZ
    cMsgLog += u_APCPM03b(SB1->B1_COD, SB1->B1_LOCPAD)

    //Se o usuário confirmar a pergunta, mostra o log
    //If ! IsBlind() .And. FWAlertYesNo("Deseja ver o log do sincronismo com a SBZ?", "Confirma?")
    //    ShowLog(cMsgLog)
    //EndIf
	
	FWRestArea(aArea)
Return

#include "protheus.ch"

/*/{Protheus.doc} MT270TDK
    
    MT270TDK - Validação da Exclusão do Registro de Inventário
    Descrição: Localização: Está localizado na função A270TDOK . 
    Finalidade: Este Ponto de Entrada permite  validar ou não a exclusão do Registro de Inventário. 

    Programa Fonte
    MATA270.PRX
    Sintaxe
        MT270TDK - Validação da Exclusão do Registro de Inventário ( ) --> lRet

    Retorno
        lRet(logico)
        .T. - Para efetuar a exclusão do registro. .F. - Não efetua a exclusão do registro.

    @type  Function
    @author Súlivan Simoes (sulivansimoes@gmail.com)
    @since 18/12/2021
    @version 1.0
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6087984
    @example
        u_MT270TDK()    
/*/
User Function MT270TDK()

    Local aArea := GetArea()
    Local lRet  := .T.

    If FWIsInCallStack('U_zInvMod2')

        fVldExclui()
    EndIf

    RestArea(aArea)
Return lRet

//-------------------------------------
/*/{Protheus.doc} fVldExclui 
Se o inventario ja estiver processado, o sistema não
exclui o registro e mostra o Help indicando que 
o inventario ja foi processado e a pergunta se pode exculir, como
a pergunta não é exposta para o usuário responder, o sistema entra no estado de erro
e não pertite a exclusao
Essa função realiza o tratamento para esse cenário.
@author  	Súlivan
@return 	nil
/*/
//-------------------------------------
Static Function fVldExclui()

    Local lLocaliDt	:= .F.
    Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
    Local lDeleta   := .F.

    dbSelectArea("SB2")
    dbSetOrder(1)

    If !lWmsNew
		If Localiza(SB7->B7_COD)
			SBF->(dbSetOrder(1)) 
			If SBF->(MsSeek(FWxFilial("SBF")+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_COD+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE)).And. (SBF->BF_DINVENT == SB7->B7_DATA)
				lLocaliDt := .T.
			EndIf
		Else
			If MsSeek(FWxFilial("SB2")+SB7->B7_COD+SB7->B7_LOCAL) .And. (SB2->B2_DINVENT == SB7->B7_DATA)
				lLocaliDt := .T.
			EndIf
		EndIf

		If lLocaliDt
          lDeleta:=  MsgYesNo("Ja foi processado inventario para este produto: "+Alltrim(SB7->B7_COD)+" neste armazem e data , confirma a exclusao ?", "Atenção [ MT270TDK ]")
		EndIf
	EndIf

    //Edito o status do campo do registro informando que ele não foi processado.
    //Trativa para burlar a validação da rotina padrão.
    If lDeleta
        If RecLock("SB7",.F.)
            SB7->B7_DATA := DaySum(SB7->B7_DATA,1) //Não processado.
            MsUnLock()
        EndIf
    EndIf

Return

#include "protheus.ch"

/*/{Protheus.doc} MT270TDK
    
    MT270TDK - Valida��o da Exclus�o do Registro de Invent�rio
    Descri��o: Localiza��o: Est� localizado na fun��o A270TDOK . 
    Finalidade: Este Ponto de Entrada permite  validar ou n�o a exclus�o do Registro de Invent�rio. 

    Programa Fonte
    MATA270.PRX
    Sintaxe
        MT270TDK - Valida��o da Exclus�o do Registro de Invent�rio ( ) --> lRet

    Retorno
        lRet(logico)
        .T. - Para efetuar a exclus�o do registro. .F. - N�o efetua a exclus�o do registro.

    @type  Function
    @author S�livan Simoes (sulivansimoes@gmail.com)
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
Se o inventario ja estiver processado, o sistema n�o
exclui o registro e mostra o Help indicando que 
o inventario ja foi processado e a pergunta se pode exculir, como
a pergunta n�o � exposta para o usu�rio responder, o sistema entra no estado de erro
e n�o pertite a exclusao
Essa fun��o realiza o tratamento para esse cen�rio.
@author  	S�livan
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
          lDeleta:=  MsgYesNo("Ja foi processado inventario para este produto: "+Alltrim(SB7->B7_COD)+" neste armazem e data , confirma a exclusao ?", "Aten��o [ MT270TDK ]")
		EndIf
	EndIf

    //Edito o status do campo do registro informando que ele n�o foi processado.
    //Trativa para burlar a valida��o da rotina padr�o.
    If lDeleta
        If RecLock("SB7",.F.)
            SB7->B7_DATA := DaySum(SB7->B7_DATA,1) //N�o processado.
            MsUnLock()
        EndIf
    EndIf

Return

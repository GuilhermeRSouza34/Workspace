//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function MTA260MNU
Ponto de entrada para inserir opção no menu na tela de Transferência Modelo 1
@type  Function
@since 09/04/2021
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6087760
@obs A variável aRotina é uma variável Private criada dentro da MATA260
/*/

User Function MTA260MNU()
    Local aArea := GetArea()
	aAdd(aRotina, {"* Impressao Conferencia", "u_zRTransf", 0, 2, 0, Nil })
    RestArea(aArea)
Return

//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function MTA261MNU
Ponto de entrada para inserir op��o no menu na tela de Transfer�ncia Modelo 2
@type  Function
@since 09/04/2021
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6089473
@obs A vari�vel aRotina � uma vari�vel Private criada dentro da MATA261
/*/

User Function MTA261MNU()
    Local aArea := GetArea()
    aAdd(aRotina, {"* Impressao Conferencia", 'u_zRTransf', 0, 2, 0, Nil})
    RestArea(aArea)
Return

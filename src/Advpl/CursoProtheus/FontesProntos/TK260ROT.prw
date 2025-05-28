//Bibliotecas
#Include "TOTVS.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function TK260ROT
Adiciona outras ações na tela de Prospect
@type  Function
@author Atilio
@since 12/05/2021
@version version
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6787728
/*/

User Function TK260ROT()
    Local aArea    := GetArea()
    Local aRotAdic := {}

    //Adiciona a função que faz a transformação de SUS para SA1
    ADD OPTION aRotAdic TITLE "* Transformar em Cliente" ACTION "u_zSUSxSA1" OPERATION 4 ACCESS 0

    RestArea(aArea)
Return aRotAdic

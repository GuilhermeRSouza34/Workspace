//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function M020ALT
Ponto de Entrada na Altera��o do Fornecedor
@type  Function
@author Atilio
@since 28/07/2022
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6087545
/*/

User Function M020ALT()
    Local aArea   := FWGetArea()

    //Aciona a atualiza��o dos t�tulos a pagar
    u_AEXCL004()

    FWRestArea(aArea)
Return

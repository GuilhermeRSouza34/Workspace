//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function M261BCHOI
Ponto de Entrada no Outras Ações dentro da tela de Transferência Múltipla
@type  Function
@author Atilio
@since 16/01/2024
@see https://tdn.totvs.com/pages/releaseview.action?pageId=236601700
/*/

User Function M261BCHOI()
    Local aArea := FWGetArea()
    Local aButtons := {}

    //Adicionando as opções no Outras Ações, somente se estiver em uma inclusão
    If INCLUI
        aAdd(aButtons, {'BITMAP',{ || U_AEXCL002() }, "* Importar CSV"})
    EndIf

    FWRestArea(aArea)
Return aButtons

//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function M261BCHOI
Ponto de Entrada no Outras A��es dentro da tela de Transfer�ncia M�ltipla
@type  Function
@author Atilio
@since 16/01/2024
@see https://tdn.totvs.com/pages/releaseview.action?pageId=236601700
/*/

User Function M261BCHOI()
    Local aArea := FWGetArea()
    Local aButtons := {}

    //Adicionando as op��es no Outras A��es, somente se estiver em uma inclus�o
    If INCLUI
        aAdd(aButtons, {'BITMAP',{ || U_AEXCL002() }, "* Importar CSV"})
    EndIf

    FWRestArea(aArea)
Return aButtons

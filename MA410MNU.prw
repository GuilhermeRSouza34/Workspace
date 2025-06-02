//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function MA410MNU
Ponto de Entrada para adicionar Outras Ações na tela do Pedido de Venda
@type  Function
@author Atilio
@since 03/09/2021
@version version
/*/

User Function MA410MNU()
    Local aArea := GetArea()

    //Adiciona na variável do Menu
	aAdd(aRotina, {"* Transferir Filial", "u_zTransPed()", 0, 4, 0, Nil})
	
	RestArea(aArea)
Return

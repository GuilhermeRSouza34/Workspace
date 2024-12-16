#include "protheus.ch"

User Function ZPROD_CAD()
    //Exemplo de Cadastro de produto no Protheus via VS Code

    // Declara��o de vari�veis
    Local aProducts := {}               // Array para armazenar os produtos
    Local cCode     := ""               // C�digo do produto
    Local cName     := ""               // Nome do produto
    Local cDesc     := ""               // Descri��o
    Local cCat      := ""               // Categoria
    Local nPrice    := 0.00             // Pre�o
    Local nStockMin := 0                // Estoque m�nimo
    Local nStockAct := 0                // Estoque atual
    Local lActive   := .T.              // Produto ativo/inativo

Return ZPROD_CAD

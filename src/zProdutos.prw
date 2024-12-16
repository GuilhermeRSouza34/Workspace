#include "protheus.ch"

User Function ZPROD_CAD()
    //Exemplo de Cadastro de produto no Protheus via VS Code

    // Declaração de variáveis
    Local aProducts := {}               // Array para armazenar os produtos
    Local cCode     := ""               // Código do produto
    Local cName     := ""               // Nome do produto
    Local cDesc     := ""               // Descrição
    Local cCat      := ""               // Categoria
    Local nPrice    := 0.00             // Preço
    Local nStockMin := 0                // Estoque mínimo
    Local nStockAct := 0                // Estoque atual
    Local lActive   := .T.              // Produto ativo/inativo

    //Entrada de dados do Usúario
    cCode := Alltrim(InputBox("Código do Produto", "Digite o código único do produto: ", ""))
    If cCode == ""
        MsgStop("Código do Produto é obrigatorio!")
        Return
    Endif
    
Return ZPROD_CAD

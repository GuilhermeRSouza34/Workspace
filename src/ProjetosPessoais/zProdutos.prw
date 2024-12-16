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

    cName := Alltrim(InputBox("Nome do Produto", "Digite o nome do produto: ", ""))
    If cName == ""
        MsgStop("Nome do Produto é obrigatório!")
        Return
    Endif

    cDesc     := Alltrim(InputBox("Descrição do Produto", "Adicione uma descrição breve:", ""))
    cCat      := Alltrim(InputBox("Categoria", "Digite a categoria do produto:", ""))
    nPrice    := StrToNum(InputBox("Preço do Produto", "Digite o preço (ex: 10.50):", "0.00"))
    nStockMin := Val(InputBox("Estoque Mínimo", "Digite a quantidade mínima em estoque:", "0"))
    nStockAct := Val(InputBox("Estoque Atual", "Digite a quantidade atual em estoque:", "0"))
    lActive   := MsgYesNo("Produto ativo?", "Deseja marcar este produto como ativo?")

    // Adiciona o produto ao array
    aAdd(aProducts, {cCode, cName, cDesc, cCat, nPrice, nStockMin, nStockAct, lActive})

    // Confirmação
    MsgInfo("Produto cadastrado com sucesso!")

    // Exibe os produtos cadastrados
    If !Empty(aProducts)
        Alert("Produtos cadastrados: " + aLineBreak() + aArrayToStr(aProducts))
    EndIf

    Return
EndFunc

Return ZPROD_CAD

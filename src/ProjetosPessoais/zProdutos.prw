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

    //Entrada de dados do Us�ario
    cCode := Alltrim(InputBox("C�digo do Produto", "Digite o c�digo �nico do produto: ", ""))
    If cCode == ""
        MsgStop("C�digo do Produto � obrigatorio!")
        Return
    Endif

    cName := Alltrim(InputBox("Nome do Produto", "Digite o nome do produto: ", ""))
    If cName == ""
        MsgStop("Nome do Produto � obrigat�rio!")
        Return
    Endif

    cDesc     := Alltrim(InputBox("Descri��o do Produto", "Adicione uma descri��o breve:", ""))
    cCat      := Alltrim(InputBox("Categoria", "Digite a categoria do produto:", ""))
    nPrice    := StrToNum(InputBox("Pre�o do Produto", "Digite o pre�o (ex: 10.50):", "0.00"))
    nStockMin := Val(InputBox("Estoque M�nimo", "Digite a quantidade m�nima em estoque:", "0"))
    nStockAct := Val(InputBox("Estoque Atual", "Digite a quantidade atual em estoque:", "0"))
    lActive   := MsgYesNo("Produto ativo?", "Deseja marcar este produto como ativo?")

    // Adiciona o produto ao array
    aAdd(aProducts, {cCode, cName, cDesc, cCat, nPrice, nStockMin, nStockAct, lActive})

    // Confirma��o
    MsgInfo("Produto cadastrado com sucesso!")

    // Exibe os produtos cadastrados
    If !Empty(aProducts)
        Alert("Produtos cadastrados: " + aLineBreak() + aArrayToStr(aProducts))
    EndIf

    Return
EndFunc

Return ZPROD_CAD

#Include "TOTVS.ch"

User Function GestaoVendas()
    Local aMenu := {}
    Local nOpcao := 0

    While nOpcao != 4
        aMenu := {
            {"1 - Cadastrar Cliente", {|| CadastrarCliente()}},
            {"2 - Registrar Venda", {|| RegistrarVenda()}},
            {"3 - Gerar Relat�rio", {|| GerarRelatorioVendas()}},
            {"4 - Sair", {|| MsgInfo("Saindo do sistema...")}}
        }

        nOpcao := FWMenu("Gest�o de Vendas", aMenu)
    EndDo

    Return
EndFunc

Static Function CadastrarCliente()

Local cNome := ""
Local cEndereco := ""
Local cTelefone := ""

cNome := FWInput("Informe o nome do cliente:")
cEndereco := FWInput("Informe o endere�o do cliente:")
cTelefone := FWInput("Informe o telefone do cliente:")

// Aqui voc� pode adicionar o c�digo para salvar os dados do cliente em um banco de dados ou arquivo

MsgInfo("Cliente cadastrado com sucesso!")
Return

Static Function RegistrarVenda()

Local cProduto := ""
Local nQuantidade := 0
Local nPreco := 0.0
Local nTotal := 0.0

cProduto := FWInput("Informe o nome do produto:")
nQuantidade := Val(FWInput("Informe a quantidade:"))
nPreco := Val(FWInput("Informe o pre�o unit�rio:"))

nTotal := nQuantidade * nPreco

// Aqui voc� pode adicionar o c�digo para salvar os dados da venda em um banco de dados ou arquivo

MsgInfo("Venda registrada com sucesso! Total: " + Transform(nTotal, "@E 999,999.99"))
Return

Static Function GerarRelatorioVendas()
    // Implementar gera��o de relat�rio de vendas
Return
Local aVendas := {}
Local cRelatorio := ""
Local i := 0

// Aqui voc� pode adicionar o c�digo para carregar os dados das vendas de um banco de dados ou arquivo
// Exemplo de dados fict�cios
aAdd(aVendas, {"Produto A", 10, 5.0})
aAdd(aVendas, {"Produto B", 2, 15.0})
aAdd(aVendas, {"Produto C", 1, 50.0})

cRelatorio := "Relat�rio de Vendas" + CRLF + CRLF
cRelatorio += "Produto     Quantidade     Pre�o Unit�rio     Total" + CRLF
cRelatorio += Replicate("-", 50) + CRLF

For i := 1 To Len(aVendas)
    Local cProduto := aVendas[i][1]
    Local nQuantidade := aVendas[i][2]
    Local nPreco := aVendas[i][3]
    Local nTotal := nQuantidade * nPreco

    cRelatorio += PadR(cProduto, 12) + ;
                    PadR(Str(nQuantidade), 12) + ;
                    PadR(Transform(nPreco, "@E 999,999.99"), 16) + ;
                    Transform(nTotal, "@E 999,999.99") + CRLF
Next

MsgInfo(cRelatorio)
Return

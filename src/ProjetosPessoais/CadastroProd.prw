#Include "TOTVS.ch"

User Function ControleEstoque()
    Local aMenu := {}
    Local nOpcao := 0

    While nOpcao != 4
        aMenu := {
            {"1 - Cadastrar Produto", {|| CadastrarProduto()}},
            {"2 - Registrar Entrada/Sa�da", {|| RegistrarMovimentacao()}},
            {"3 - Gerar Relat�rio", {|| GerarRelatorio()}},
            {"4 - Sair", {|| MsgInfo("Saindo do sistema...")}}
        }

        nOpcao := FWMenu("Controle de Estoque", aMenu)
    EndDo

    Return
EndFunc

Static Function CadastrarProduto()

Local cCodigo := Space(10)
Local cDescricao := Space(50)
Local nPreco := 0.0
Local nEstoque := 0

cCodigo := FWInput("C�digo do Produto:", cCodigo)
cDescricao := FWInput("Descri��o do Produto:", cDescricao)
nPreco := Val(FWInput("Pre�o do Produto:", Str(nPreco, 10, 2)))
nEstoque := Val(FWInput("Quantidade em Estoque:", Str(nEstoque, 10)))

DbUseArea(.T., "TOPCONN", "SB1", "SB1", .T., .T.)
DbAppend()
FIELD->B1_COD := cCodigo
FIELD->B1_DESC := cDescricao
FIELD->B1_PRV1 := nPreco
FIELD->B1_ESTQ := nEstoque
DbCommit()
DbCloseArea()

MsgInfo("Produto cadastrado com sucesso!")
Return

Static Function RegistrarMovimentacao()
    // Implementar registro de entrada/sa�da de produtos
Return

Static Function GerarRelatorio()
    // Implementar gera��o de relat�rio de movimenta��o
Return

#Include "TOTVS.ch"

User Function ControleEstoque()
    Local aMenu := {}
    Local nOpcao := 0

    While nOpcao != 4
        aMenu := {
            {"1 - Cadastrar Produto", {|| CadastrarProduto()}},
            {"2 - Registrar Entrada/Saída", {|| RegistrarMovimentacao()}},
            {"3 - Gerar Relatório", {|| GerarRelatorio()}},
            {"4 - Sair", {|| MsgInfo("Saindo do sistema...")}}
        }

        nOpcao := FWMenu("Controle de Estoque", aMenu)
    EndDo

    Return
EndFunc

Static Function CadastrarProduto()
    // Implementar cadastro de produto
Return

Static Function RegistrarMovimentacao()
    // Implementar registro de entrada/saída de produtos
Return

Static Function GerarRelatorio()
    // Implementar geração de relatório de movimentação
Return

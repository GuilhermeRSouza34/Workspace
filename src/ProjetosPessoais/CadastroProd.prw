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
    // Implementar cadastro de produto
Return

Static Function RegistrarMovimentacao()
    // Implementar registro de entrada/sa�da de produtos
Return

Static Function GerarRelatorio()
    // Implementar gera��o de relat�rio de movimenta��o
Return

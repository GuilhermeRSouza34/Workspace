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
    // Implementar cadastro de cliente
Return

Static Function RegistrarVenda()
    // Implementar registro de venda
Return

Static Function GerarRelatorioVendas()
    // Implementar gera��o de relat�rio de vendas
Return

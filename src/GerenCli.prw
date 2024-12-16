#INCLUDE "protheus.ch"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "SQL.CH"

// Função principal
User Function SistemaClientes()
    Local aMenu  := {}                  // Array para o menu de opções
    Local nOpcao := 0                   // Variável para armazenar a opção escolhida pelo usuário
    
    // Loop principal do sistema
    While nOpcao != 4
        // Define o menu do sistema
        aMenu := {
            {"1 - Listar Clientes",     {|| ListarClientes()}},
            {"2 - Buscar Cliente",      {|| BuscarCliente()}},
            {"3 - Atualizar Endereço",  {|| AtualizarEndereco()}},
            {"4 - Sair",                {|| MsgInfo("Saindo do sistema...")}}
        }
        
        // Exibe o menu e captura a opção escolhida
        nOpcao := FWMenu("Gerenciamento de Clientes", aMenu)
    EndDo

    Return
EndFunc

// Função para listar todos os clientes
Static Function ListarClientes()
    Local cQuery := "SELECT C1_CODIGO, C1_NOME, C1_END FROM SA101"
    Local aDados := {}
    Local oSql := SQLCreate()

    If oSql:Open(cQuery)
        While !oSql:Eof()
            // Adiciona os dados no array
            AAdd(aDados, {oSql:FieldGet("C1_CODIGO"), oSql:FieldGet("C1_NOME"), oSql:FieldGet("C1_END")})
            oSql:Skip()
        EndDo
        oSql:Close()
    Else
        MsgStop("Erro ao executar consulta SQL.", "Erro")
        Return
    EndIf

    // Exibe os dados em forma de matriz
    If !Empty(aDados)
        FWBrowse(aDados, {"Código", "Nome", "Endereço"})
    Else
        MsgInfo("Nenhum cliente encontrado.", "Aviso")
    EndIf

    Return
EndFunc

// Função para buscar um cliente pelo código
Static Function BuscarCliente()
    Local cCodigo := ""                // Variável para armazenar o código informado pelo usuário
    Local cQuery  := ""
    Local oSql    := SQLCreate()

    // Captura o código do cliente
    cCodigo := InputBox("Informe o código do cliente:")
    If Empty(cCodigo)
        MsgStop("Código não pode ser vazio.", "Erro")
        Return
    EndIf

    // Define a query para buscar o cliente
    cQuery := "SELECT C1_NOME, C1_END FROM SA101 WHERE C1_CODIGO = '" + cCodigo + "'"

    If oSql:Open(cQuery)
        If !oSql:Eof()
            MsgInfo("Nome: " + oSql:FieldGet("C1_NOME") + CRLF + "Endereço: " + oSql:FieldGet("C1_END"), "Cliente encontrado")
        Else
            MsgStop("Cliente não encontrado.", "Erro")
        EndIf
        oSql:Close()
    Else
        MsgStop("Erro ao executar consulta SQL.", "Erro")
    EndIf

    Return
EndFunc

// Função para atualizar o endereço de um cliente
Static Function AtualizarEndereco()
    Local cCodigo := ""
    Local cNovoEndereco := ""
    Local oSql := SQLCreate()

    // Captura o código do cliente
    cCodigo := InputBox("Informe o código do cliente para atualizar o endereço:")
    If Empty(cCodigo)
        MsgStop("Código não pode ser vazio.", "Erro")
        Return
    EndIf

    // Captura o novo endereço
    cNovoEndereco := InputBox("Informe o novo endereço:")
    If Empty(cNovoEndereco)
        MsgStop("Endereço não pode ser vazio.", "Erro")
        Return
    EndIf

    // Atualiza o endereço no banco
    If oSql:Exec("UPDATE SA101 SET C1_END = '" + cNovoEndereco + "' WHERE C1_CODIGO = '" + cCodigo + "'")
        MsgInfo("Endereço atualizado com sucesso.", "Sucesso")
    Else
        MsgStop("Erro ao atualizar o endereço.", "Erro")
    EndIf

    Return
EndFunc

#INCLUDE "protheus.ch"
#INCLUDE "PRTOPDEF.CH"

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

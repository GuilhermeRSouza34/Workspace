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

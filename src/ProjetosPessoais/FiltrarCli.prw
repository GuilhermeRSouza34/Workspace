#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function FiltrarClientes()
    Local cTabela   := "Clientes"   // Nome da tabela
    Local nSaldoMin := 1000         // Saldo min que o cliente tem que ter para o filtro

    // Fun��o para abrir a tela
    DbUseArea(.T., "DBFCDX", cTabela, "CLIENTES", .T.)
    DbSetOrder(1)  // Certifique que a tabela tem um indice configurado
    DbGoTop()      // Ir para o primeiro registro

    // Verifica se a tabela foi aberta corretamente
    If !DbUsed()
        MsgStop("N�o foi possivel abrir a tabela: " + cTabela, "Erro")
    Endif

    // Percorrer os registros e filtrar clientes
    While !Eof()
    If DbDbl("Saldo") >= nSaldoMin Then
        if FIELD -> Saldo > nSaldoMin]
            // Exibe os dados do cliente]
            MsgInfo("Cliente: " + FIELD -> Nome + CLLF + ;
                    "Saldo: " + Str(FIELD -> Saldo, 10, 2), "Cliente Selecionado")
        EndIf
        DbSkip()  // Avan�a para o proximo registro
    End

    // para fechar a tabela
    DbCloseArea()
    Msg("Filtro concluido!", "Informa��o")

Return

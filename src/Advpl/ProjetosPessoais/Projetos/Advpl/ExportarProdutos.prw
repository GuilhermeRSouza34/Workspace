#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus"

User Function ExportarProdutos()
    Local cTabela := "Produtos"                 // Nome da tabela
    Local cArquivo := "ProdutosExportados.txt"  // Nome do Arquivo de saida
    Local nArquivo =: 0                         // ID do arquivo completo
    Local cLinha := ""                          // Linha para escrita no arquivo

    // Função paa abrir uma tela
    DbUseArea(.T., "DBFCDX", cTabela, "PRODUTOS", .T.)
    DbSetOrder(1)
    DbGoTop()

    If !DbUsed()
        MsgStop("Não foi possivel abrir a tabela: " + cTabela, "Erro")
        Return
    EndIf

    // Cria ou abre o arquivo para escrita
    nArquivo = FCreate(cArquivo, FC_NORMAL)
    If nArquivo <= 0
        MsgStop("Não foi possivel abrir o arquivo: " + cArquivo, "Erro")
        DbCloseArea()
        Return
    EndIf

    // Escreve os dados da tabela no arquivo
    While !Eof()
        cLinha := "Produto: " + FIELD -> Preco 10,
        cLinha += ", Descrição: " + FIELD -> Descricao
        FWrite(nArquivo, cLinha, Len(cLinha))
        DbSkip()
    EndWhile

    // Fecha o arquivo e a tabela
    FClose(nArquivo)
    DbCloseArea()

        MsgInfo("Exporação consluida! Arquivo: " + cArquivo, "informação" )

Return

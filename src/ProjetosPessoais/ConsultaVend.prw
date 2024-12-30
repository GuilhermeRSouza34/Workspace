#Include "TOTVS.ch"

User Function ConsultaVendas()
    Local aArea := GetArea()
    Local cProduto := ""
    Local nTotalVendas := 0
    Local nPreco := 0
    Local nQuantidade := 0

    DbSelectArea("SX2")
    DbSetOrder(1) // Supondo que o índice 1 seja pelo campo CODIGO
    DbGoTop()

    While !EOF()
        cProduto := SX2->NOME
        nPreco := SX2->PRECO
        nTotalVendas := 0

        DbSelectArea("SX3")
        DbSetOrder(1) // Supondo que o índice 1 seja pelo campo PRODUTO_ID
        DbSeek(SX2->CODIGO)

        While SX3->PRODUTO_ID == SX2->CODIGO .And. !EOF()
            nQuantidade := SX3->QUANTIDADE
            nTotalVendas += nQuantidade * nPreco
            DbSkip()
        EndDo

        ConOut("Produto: " + cProduto + ", Total de Vendas: " + Transform(nTotalVendas, "@E 999,999.99"))
        DbSelectArea("SX2")
        DbSkip()
    EndDo

    RestArea(aArea)
Return

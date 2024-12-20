#Include "TOTVS.ch"

User Function RelatorioProdutos()
    Local aArea := FWGetArea()
    Local cArqRel := "RelatorioProdutos.txt"
    Local nHandle := FCreate(cArqRel)
    Local cLinha := ""
    
    If nHandle < 0
        MsgStop("Erro ao criar o arquivo de relatório.", "Erro")
        Return
    EndIf

    DbSelectArea("SB1")
    DbSetOrder(1) // Supondo que o índice 1 seja o código do produto
    DbGoTop()

    cLinha := PadR("Código", 10) + PadR("Descrição", 40) + PadR("Preço", 15)
    FWrite(nHandle, cLinha + CRLF)

    While !EOF()
        cLinha := PadR(SB1->B1_COD, 10) + PadR(SB1->B1_DESC, 40) + PadL(Transform(SB1->B1_PRECO, "@E 999,999,999.99"), 15)
        FWrite(nHandle, cLinha + CRLF)
        DbSkip()
    EndDo

    FClose(nHandle)
    FWRestArea(aArea)

    MsgInfo("Relatório gerado com sucesso: " + cArqRel, "Informação")
Return

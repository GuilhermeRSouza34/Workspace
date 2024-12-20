#Include "TOTVS.ch"

User Function RelatorioClientes()
    Local aArea := FWGetArea()
    Local cArqRel := "RelatorioClientes.txt"
    Local nHandle := FCreate(cArqRel)
    Local cLinha := ""
    
    If nHandle < 0
        MsgStop("Erro ao criar o arquivo de relatório.", "Erro")
        Return
    EndIf

    DbSelectArea("SA1")
    DbSetOrder(1) // Supondo que o índice 1 seja o código do cliente
    DbGoTop()

    cLinha := PadR("Código", 10) + PadR("Nome", 40) + PadR("Saldo", 15)
    FWrite(nHandle, cLinha + CRLF)

    While !EOF()
        cLinha := PadR(SA1->A1_COD, 10) + PadR(SA1->A1_NOME, 40) + PadL(Transform(SA1->A1_SALDO, "@E 999,999,999.99"), 15)
        FWrite(nHandle, cLinha + CRLF)
        DbSkip()
    EndDo

    FClose(nHandle)
    FWRestArea(aArea)

    MsgInfo("Relatório gerado com sucesso: " + cArqRel, "Informação")
Return

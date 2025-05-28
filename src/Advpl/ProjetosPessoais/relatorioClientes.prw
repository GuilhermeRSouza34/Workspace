#Include "TOTVS.ch"

User Function RelatorioClientes()
    Local aArea := FWGetArea()
    Local cArqRel := "RelatorioClientes.txt"
    Local nHandle := FCreate(cArqRel)
    Local cLinha := ""
    
    If nHandle < 0
        MsgStop("Erro ao criar o arquivo de relat�rio.", "Erro")
        Return
    EndIf

    DbSelectArea("SA1")
    DbSetOrder(1) // Supondo que o �ndice 1 seja o c�digo do cliente
    DbGoTop()

    cLinha := PadR("C�digo", 10) + PadR("Nome", 40) + PadR("Saldo", 15)
    FWrite(nHandle, cLinha + CRLF)

    While !EOF()
        cLinha := PadR(SA1->A1_COD, 10) + PadR(SA1->A1_NOME, 40) + PadL(Transform(SA1->A1_SALDO, "@E 999,999,999.99"), 15)
        FWrite(nHandle, cLinha + CRLF)
        DbSkip()
    EndDo

    FClose(nHandle)
    FWRestArea(aArea)

    MsgInfo("Relat�rio gerado com sucesso: " + cArqRel, "Informa��o")
Return

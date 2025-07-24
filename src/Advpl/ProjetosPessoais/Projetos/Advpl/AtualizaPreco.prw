#Include "TOTVS.ch"

User Function AtualizarPrecos()
    Local aArea := FWGetArea()
    
    DbSelectArea("SB1")
    DbSetOrder(1) // Supondo que o �ndice 1 seja o c�digo do produto
    DbGoTop()

    While !EOF()
        SB1->(DbEdit())
        SB1->B1_PRECO := SB1->B1_PRECO * 1.10
        SB1->(DbCommit())
        DbSkip()
    EndDo

    FWRestArea(aArea)

    MsgInfo("Pre�os atualizados com sucesso.", "Informa��o")
Return

#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function AttPrecoCat()
    Local aArea := GetArea()    // Salva a area de trabalho atual
    Local cCategoria := ""      // Categoria de trabalho atual
    Local nPercentual := 0.0    // Percentual de aumento
    Local nQtdAtualizados := 0  // Contador de registros atualizados

    // Solicita os dados ao usuario
    @ 01, 01 SAY "Informe a categoria: " GET cCategoria
    @ 02, 01 SAY "Percentual de aumento (%): " GET nPercentual PICTURE "999.99"
    READ

    // Valida os dados
    If Empty(cCategoria) .or. nPercentual <= 0
        MsgStop("Dados invalidos. Tente novamente.", "Erro")
        Return
    EndIf
    
    // Selciona a tabela de produtos (SB1)
    DBSelectArea("SB1")
    DBSetOrder(1) // Define o indice por codigo ou categoria, dependendo do sistema 
    DBGoTop()

    while !Eof()
        If AllTrim(B1_CATEG) == cCategoria
            // Função para calcular o novo preço
            B1_PRV1 := B1_PRV1 * (1 + (nPercentual / 100))
            DBCommit() // Salva a alteração
            nQtdAtualizados++
        EndIf
        DBSkip() // Para ir avançando para o proximo registro
    EndDo

    MsgInfo(AllTrim(Str(nQtdAtualizados)) + " produtos atualizados.", "Concluido")
    RestArea(aArea) // Restaura a área de trabalho
Return

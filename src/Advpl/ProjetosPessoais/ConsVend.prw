#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function ConsolidarVendas()
    Local aArea := GetArea()    // Salva a área de trabalho atual
    Local cTabela := "ZZVENDAS" // Nome da tabela temporaria
    Local aFiliais := {}        // Array de filiais consolidadas

    // função para criar a tabela temporaria
    DBCreate(cTabela, {{"FILIAL", "C", 4, 0}, {"TOTAL_VENDAS", "N", 15, 2}})
    DBUseArea(.T., , cTabela)
    DBGoTop()

    // Seleciona a tabela de vendas (SC5)
    DBSelectArea("SC5")
    DBSetOrder(1) //Indice por filial
    DBGoTop()

    while !Eof()
        Local cFilial := C5_FILIAL
        Local nTotalVendas := 0

        // Soma o total de vendas por filial
        while !Eof() .and. C5_FILIAL == cFilial
            nTotalVendas += C5_TOTAL
            DBSkip()
        EndDo

        //Armazena na tabela temporaria
        DBAppend()
        FIELD -> FILIAL := cFilial
        FIELD -> TOTAL_VENDAS := nTotalVendas
    EndDo

    MsgInfo("Concolidação concluida", "Sucessp")
    RestArea(aArea)  // Restaura área de trabalho

Return

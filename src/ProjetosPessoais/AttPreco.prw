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

    
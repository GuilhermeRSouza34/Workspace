#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function ContarVogais()
    Local cTexto    := ""       // Texto fonecido pelo usuario
    Local nContador := 0        // Contador de vogais
    Local vVogais   := "AEIOU"  // Lista de vogais maiusculas
    Local cChar     := ""       // Caractere atual do texto em analise

    // Obtem o texto fornecido pelo usuario
    cTexto := Upper(InputBox("Digite um texto para contar as vogais:", "Entrada de Dados"))

    // Percorrer cada caractere do texto
    For n := 1 To Len(cTexto)
        cChar := SubStr(cTexto, n, 1)
        if At(cChar, cVogais) > 0
            nContador++
        EndIf
    Next

    // Exibir o resultado
    MsgInfo("O texto possui " + Str(nContador) + " vogais.", "Resultado")
        
Return

#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function VerificaParOuImpar()
    Local nNumero := 0  // variavel para armazenar o numero informado pelo usuario

    // Solicita o usuario um numero
    nNumero := Val(InputBox("Digite um numero: ", "Entrada de dados"))

    //Verifica se é par ou impar
    if Mod(nNumero, 2) == 0
        // Numero é par
        MsgBox("O numero " + Str(nNumero) + " é par.", "Resultado")
    else
        // Numero é impar
        MsgBox("O numero " + Str(nNumero) + " é impar.", "Resultado")
    EndIf

Return

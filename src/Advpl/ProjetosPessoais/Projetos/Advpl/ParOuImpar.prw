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

    //Verifica se � par ou impar
    if Mod(nNumero, 2) == 0
        // Numero � par
        MsgBox("O numero " + Str(nNumero) + " � par.", "Resultado")
    else
        // Numero � impar
        MsgBox("O numero " + Str(nNumero) + " � impar.", "Resultado")
    EndIf

Return

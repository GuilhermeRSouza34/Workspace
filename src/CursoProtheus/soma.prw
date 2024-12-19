#INCLUDE "PRTOPDEF.CH"
#INCLUDE "protheus.ch"

User Function soma()
local nNum1 := 20
local nNum2 := 10
soma := (nNum1 + nNum2)
Alert(soma)
nNum1 := "TESTE"
Alert(nNum1)
soma := (nNum1 + nNum2)
Alert(soma)
Return return_var

#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

// Fun��o Principal
User Function ZCONTA()
    Local aContas := {} // Array para armazenar os lan�amentos
    Local cOpcao  := "" // Op��o do menu principal

    while .T.
        //Exibe o menu Principal
cOpcao := Menu("Sistema de Contas a Pagar", ;
                        {"Incluir Lan�amento", ;
                        "Listar Lan�amentos", ;
                        "Calcular Total a Pagar", ;
                        "Sair"})
        Do Case
        Case cOpcao == "1" // Incluir lan�amento
            ZCONTA_Incluir(@aContas)
        Case cOpcao == "2" // Listar lan�amentos
            ZCONTA_Listar(aContas)
        Case cOpcao == "3" // Calcular total
            ZCONTA_Total(aContas)
        Case cOpcao == "4" // Sair
            MsgInfo("Sistema encerrado. At� logo!")
            Exit
        EndCase
    EndWhile
Return


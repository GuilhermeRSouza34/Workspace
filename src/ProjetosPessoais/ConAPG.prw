#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

// Função Principal
User Function ZCONTA()
    Local aContas := {} // Array para armazenar os lançamentos
    Local cOpcao  := "" // Opção do menu principal

    while .T.
        //Exibe o menu Principal
cOpcao := Menu("Sistema de Contas a Pagar", ;
                        {"Incluir Lançamento", ;
                        "Listar Lançamentos", ;
                        "Calcular Total a Pagar", ;
                        "Sair"})
        Do Case
        Case cOpcao == "1" // Incluir lançamento
            ZCONTA_Incluir(@aContas)
        Case cOpcao == "2" // Listar lançamentos
            ZCONTA_Listar(aContas)
        Case cOpcao == "3" // Calcular total
            ZCONTA_Total(aContas)
        Case cOpcao == "4" // Sair
            MsgInfo("Sistema encerrado. Até logo!")
            Exit
        EndCase
    EndWhile
Return


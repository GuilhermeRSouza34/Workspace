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

// Fun��o para incluir um novo lan�amento
Static Function ZCONTA_Incluir(aContas)
    Local cFornecedor := ""       // Nome do Fornecedor
    Local dVencimento := CTOD("") // Data de vencimento
    LOcal nValor      := 0.00     // Valor da conta

    // Solicita os Dados do Lan�amento
    cFornecedor := InputBox("Informe o nome do fornecedor:", "Incluir Lan�amento", "Fornecedor", "")
    If Empty(cFornecedor)
        MsgStop("O nome do fornecedor � obrigatorio!")
        Return
    EndIf

    dVencimento := InputBoxDate("Informe a data de vencimento:", "Data de Vencimento")
    If Empty(dVencimento)
        MsgStop("A data de vencimento � obrigat�ria!")
        Return
    EndIf

    nValor := Val(InputBox("Informe o valor da conta:", "Valor"))
    If nValor <= 0
        MsgStop("O valor da conta deve ser maior que zero!")
        Return
    EndIf

    // Verifica duplicidade
    If aScan(aContas, {|x| x[1] == cFornecedor .and. x[2] == dVencimento}) > 0
        MsgStop("J� existe um lan�amento para este fornecedor e data!")
        Return
    EndIf

    // Adiciona o lan�amento no array
    aAdd(aContas, {cFornecedor, dVencimento, nValor})
    MsgInfo("Lan�amento inclu�do com sucesso!")

Return



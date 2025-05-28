#INCLUDE "PRTOPDEF.CH"
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

// Função para incluir um novo lançamento
Static Function ZCONTA_Incluir(aContas)
    Local cFornecedor := ""       // Nome do Fornecedor
    Local dVencimento := CTOD("") // Data de vencimento
    LOcal nValor      := 0.00     // Valor da conta

    // Solicita os Dados do Lançamento
    cFornecedor := InputBox("Informe o nome do fornecedor:", "Incluir Lançamento", "Fornecedor", "")
    If Empty(cFornecedor)
        MsgStop("O nome do fornecedor é obrigatorio!")
        Return
    EndIf

    dVencimento := InputBoxDate("Informe a data de vencimento:", "Data de Vencimento")
    If Empty(dVencimento)
        MsgStop("A data de vencimento é obrigatória!")
        Return
    EndIf

    nValor := Val(InputBox("Informe o valor da conta:", "Valor"))
    If nValor <= 0
        MsgStop("O valor da conta deve ser maior que zero!")
        Return
    EndIf

    // Verifica duplicidade
    If aScan(aContas, {|x| x[1] == cFornecedor .and. x[2] == dVencimento}) > 0
        MsgStop("Já existe um lançamento para este fornecedor e data!")
        Return
    EndIf

    // Adiciona o lançamento no array
    aAdd(aContas, {cFornecedor, dVencimento, nValor})
    MsgInfo("Lançamento incluído com sucesso!")

Return

// Função para listar os lançamentos
Static Function ZCONTA_Listar(aContas)
    Local cRelatorio := ""
    Local nLinha     := 1

    // Verifica se há lançamentos
    If Empty(aContas)
        MsgInfo("Não há lançamentos cadastrados.")
        Return
    EndIf

    // Monta o relatório
    cRelatorio += "Lançamentos de Contas a Pagar" + CRLF + StrRepeat("-", 40) + CRLF
    cRelatorio += PadR("Fornecedor", 20) + PadR("Vencimento", 12) + "Valor" + CRLF
    cRelatorio += StrRepeat("-", 40) + CRLF

    For Each aConta In aContas
        cRelatorio += PadR(aConta[1], 20) + DTOC(aConta[2]) + "  " + Transform(aConta[3], "@E 999,999.99") + CRLF
    Next

    // Exibe o relatório
    MsgInfo(cRelatorio)

Return

// Função para calcular o total das contas a pagar
Static Function ZCONTA_Total(aContas)
    Local nTotal := 0.00

    // Soma o valor de todas as contas
    For Each aConta In aContas
        nTotal += aConta[3]
    Next

    MsgInfo("Total das contas a pagar: " + Transform(nTotal, "@E 999,999.99"))

Return

#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function CaixaEletronico()
    Local nValor := 0                           // Valor Solicitado pelo Usuario
    Local aNotas := {100, 50, 20, 10, 5, 2}     // Tipos de notas disponiveis
    Local aResultado := {}                      // Array para armazenar a quantidade de cada nota
    Local nNota := 0                            // Nota atual em análise

    // Solicitar o valor Desejado
    nValor := InputBox("Digite o valor desejado em reais:", "Caixa Eletronico", "0")

    // Verificar se o valor é um número positivo
    If nValor <= 0
        MsgBox("Valor inválido. Por favor, digite um valor positivo.", "Caixa Eletronico")
        Return
    EndIf

    For Each nNota In aNotas
        AAdd(aResultado, Int(nValor / nNota))  // Adicionar a quantidade de notas ao array
        nValor := Mod(nValor, nNota)           // Atualizar o valor do restante
    Next

    MsgInfo("Notas Nescessarias para o Saque: \n" + ;
        "R$100: " + Str(aResultado[1]) + CRLF + ;
        "R$50:  " + Str(aResultado[2]) + CRLF + ;
        "R$20:  " + Str(aResultado[3]) + CRLF + ;
        "R$10:  " + Str(aResultado[4]) + CRLF + ;
        "R$5:   " + Str(aResultado[5]) + CRLF + ;
        "R$2:   " + Str(aResultado[6]), "Resultado")

Return

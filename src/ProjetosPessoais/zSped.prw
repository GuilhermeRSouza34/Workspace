#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "Protheus.CH"

User Function ZSPED()

    // Função principal do SPED Fiscal Customizado

    Local dStartDate := CTOD("")        // Data inicial
    Local dEndDate   := CTOD("")        // Data final
    Local aFields    := {}              // Campos extras para o SPED
    Local cFileName  := ""              // Nome do arquivo gerado
    Local lValid     := .F.             // Resultado da validação

    // Solicita o periodo para o SPED
    dStartDate := InputBoxDate("Data Inicial", "Informe a data inicial do período:")
    dEndDate   := InputBoxDate("Data Final", "Informe a data final do período:")

    If Empty(dStartDate) .or. Empty(dEndDate)
        MsgStop("É necessário informar um período válido!")
        Return
    EndIf

    // Configura os campos adicionais
    aFields := ZSPED_GetExtraFields()

    // Valida os dados
    lValid := ZSPED_Validate(dStartDate, dEndDate, aFields)

    If !lValid
        MsgStop("Os dados do período informados não são válidos!")
        Return
    EndIf

    // Gera o arquivo SPED
    cFileName := ZSPED_GenerateFile(dStartDate, dEndDate, aFields)
    If !Empty(cFileName)
        MsgInfo("Arquivo gerado com sucesso: " + cFileName)
    EndIf

    Return
EndFunc

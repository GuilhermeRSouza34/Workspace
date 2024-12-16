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

    // 

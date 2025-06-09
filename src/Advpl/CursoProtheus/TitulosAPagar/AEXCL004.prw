//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function AEXCL004
Atualiza os títulos a pagar em aberto, conforme alteração no cadastro de fornecedor
@type  Function
@author Atilio
@since 27/02/2024
/*/

User Function AEXCL004()
    Local aArea     := FWGetArea()

    //Aciona a rotina de atualização
    Processa({|| fAtualiza()}, 'Processando...')

    FWRestArea(aArea)
Return

/*/{Protheus.doc} fAtualiza
Rotina de processamento para atualizar os títulos a pagar
@author Atilio
@since 27/02/2024
@version 1.0
@type function
/*/

Static Function fAtualiza()
    Local aArea     := FWGetArea()
    Local aAreaSE2  := SE2->(FWGetArea())
    Local cAtuBanco := M->A2_BANCO
    Local cAtuAgenc := M->A2_AGENCIA
    Local cAtuConta := M->A2_NUMCON
    Local cAtuDigit := M->A2_DVCTA
    Local cQryUpd   := ""
    Local cFornCod  := M->A2_COD
    Local cFornLoj  := M->A2_LOJA
    Local cQrySE2   := ""
    Local nTotal    := 0
    Local nAtual    := 0

    //Se tiver banco
    If ! Empty(cAtuBanco)

        //Se a função zExecQry estiver compilada, usa ela para fazer a atualização
        //   disponível para download em https://terminaldeinformacao.com/2021/04/21/como-fazer-um-update-via-advpl/
        If ExistBlock("zExecQry")

            //Monta a atualização e executa
            cQryUpd := " UPDATE "  + CRLF
            cQryUpd += "    " + RetSQLName("SE2") + " " + CRLF
            cQryUpd += " SET " + CRLF
            cQryUpd += "    E2_FORBCO = '" + cAtuBanco + "', " + CRLF
            cQryUpd += "    E2_FORAGE = '" + cAtuAgenc + "', " + CRLF
            cQryUpd += "    E2_FORCTA = '" + cAtuConta + "', " + CRLF
            cQryUpd += "    E2_FCTADV = '" + cAtuDigit + "' " + CRLF
            cQryUpd += " WHERE "  + CRLF
            cQryUpd += "    D_E_L_E_T_ = '' " + CRLF
            cQryUpd += "    AND E2_FORNECE = '"+ cFornCod+"' " + CRLF
            cQryUpd += "    AND E2_LOJA = '"+ cFornLoj +"' " + CRLF
            cQryUpd += "    AND E2_SALDO > 0 " + CRLF
            u_zExecQry(cQryUpd, .T.)

        //Senão, terá de ser feito manualmente
        Else
            DbSelectArea("SE2")
            SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA

            //Busca todos os títulos em aberto
            cQrySE2 := " SELECT "  + CRLF
            cQrySE2 += "    SE2.R_E_C_N_O_ AS SE2REC " + CRLF
            cQrySE2 += " FROM " + CRLF
            cQrySE2 += "    " + RetSQLName("SE2") + " SE2 " + CRLF
            cQrySE2 += " WHERE "  + CRLF
            cQrySE2 += "    SE2.D_E_L_E_T_ = '' " + CRLF
            cQrySE2 += "    AND E2_FORNECE = '"+ cFornCod+"' " + CRLF
            cQrySE2 += "    AND E2_LOJA = '"+ cFornLoj +"' " + CRLF
            cQrySE2 += "    AND E2_SALDO > 0 " + CRLF
            PLSQuery(cQrySE2, "QRY_SE2")

            //Se houver dados
            If ! QRY_SE2->(EoF())
                //Define o tamanho da régua
                DbSelectArea("QRY_SE2")
                Count To nTotal
                ProcRegua(nTotal)
                QRY_SE2->(DbGoTop())

                //Percorre os registros
                While ! QRY_SE2->(EoF())
                    //Incrementa a régua
                    nAtual++
                    IncProc("Atualizando título " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

                    //Posiciona no título
                    SE2->(DbGoTo(QRY_SE2->SE2REC))

                    //Atualiza o registro
                    RecLock("SE2", .F.)
                        SE2->E2_FORBCO := cAtuBanco
                        SE2->E2_FORAGE := cAtuAgenc
                        SE2->E2_FORCTA := cAtuConta
                        SE2->E2_FCTADV := cAtuDigit
                    SE2->(MsUnlock())

                    QRY_SE2->(DbSkip())
                EndDo
            EndIf
            QRY_SE2->(DbCloseArea())
        EndIf
    EndIf

    FWRestArea(aAreaSE2)
    FWRestArea(aArea)
Return

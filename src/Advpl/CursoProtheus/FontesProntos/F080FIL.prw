//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function F080FIL
Filtro na tela de baixa por lote
@type  Function
@since 23/01/2021
@version version
@return cRetorno, character, Expressão de retorno
@see https://tdn.totvs.com/display/public/mp/F080FIL+-+Antes+da+IndRegua+na+baixa+por+lote+CP+--+11661
/*/

User Function F080FIL()
    Local aArea := GetArea()
    Local cRetorno := ""

    SetKey(K_CTRL_O, { || u_zOrdPag() }) 

    RestArea(aArea)
Return cRetorno

/*/{Protheus.doc} User Function zOrdPag
Função que ordena a tabela do contas a pagar
@type  Function
@author Atilio
@since 23/01/2021
@version version
/*/

User Function zOrdPag()
    Local aPergs   := {}
    Local nOrder   := 1

    //Se estiver na tela de lote
    If FWIsInCallStack("FA080Lot")
        aAdd(aPergs, {2, "Ordenador por", nOrder, {"1=Número do Título",  "2=Natureza",  "3=Vencimento Real",  "4=Fornecedor"},     100, ".T.", .T.})
        
        //Se a pergunta for confirmada, faz a ordenação com DbSetOrder
        If ParamBox(aPergs, "zOrdPag - Informe os parâmetros", , , , , , , , , .F., .F.)
            MV_PAR01 := Val(cValToChar(MV_PAR01))
            DbSelectArea('SE2')

            If MV_PAR01 == 1
                SE2->(DbSetOrder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

            ElseIf MV_PAR01 == 2
                SE2->(DbSetOrder(2)) // E2_FILIAL+E2_NATUREZ+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE

            ElseIf MV_PAR01 == 3
                SE2->(DbSetOrder(3)) // E2_FILIAL+DTOS(E2_VENCREA)+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FILORIG

            ElseIf MV_PAR01 == 4
                SE2->(DbSetOrder(6)) // E2_FILIAL+E2_PORTADO+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE
            EndIf
            SE2->(DbGoTop())

            //Se existir o objeto de marcação, dá um refresh nele
            If Type("oMark") == "O"
                oMark:oBrowse:Refresh()
            EndIf
        EndIf

        //Volta a pergunta que estava antes
        Pergunte("FIN080", .F.)
    EndIf
Return

//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function zCargaLoc
Função responsável por dar a carga de dados inicial em uma base de dados local
@type  Function
@version version
@example u_zCargaLoc()
/*/

User Function zCargaLoc()
    Local cMensagem := ""

    //Monta a mensagem que será exibida
    cMensagem := "Atenção!" + CRLF
    cMensagem += "Esse programa realiza a carga de dados em algumas tabelas do sistema, abaixo a listagem de tabelas, se continuar os registros serão criados." + CRLF + CRLF
    cMensagem += "+ 1x Armazém " + CRLF
    cMensagem += "+ 1x Condição de Pagamento " + CRLF
    cMensagem += "+ 3x Grupos de Produto " + CRLF
    cMensagem += "+ 13x Produtos " + CRLF
    cMensagem += "+ 2x Naturezas Financeiras " + CRLF
    cMensagem += "+ 3x Clientes " + CRLF
    cMensagem += "+ 3x Fornecedores " + CRLF
    cMensagem += "+ 2x Vendedores " + CRLF
    cMensagem += "+ 1x Transportadoras " + CRLF
    cMensagem += "+ 1x Banco " + CRLF
    cMensagem += "+ 2x Estruturas de Produto " + CRLF
    cMensagem += "+ 3x Tipos de Movimentação " + CRLF
    cMensagem += "+ 2x TES " + CRLF
    cMensagem += "+ 1x Centro de Custo " + CRLF
    cMensagem += "+ 13x Saldos Iniciais " + CRLF
    cMensagem += "+ 5x Movimentações Internas " + CRLF
    cMensagem += "+ 2x Ordens de Produção " + CRLF
    cMensagem += "+ 1x Apontamento de Produção " + CRLF
    cMensagem += "+ 2x Pedidos de Compra " + CRLF
    cMensagem += "+ 1x Documento de Entrada " + CRLF
    cMensagem += "+ 2x Pedidos de Venda " + CRLF
    cMensagem += "+ 1x Liberação de Pedidos de Venda " + CRLF
    cMensagem += "+ 1x Documento de Saída " + CRLF
    cMensagem += "+ 3x Títulos a Receber " + CRLF
    cMensagem += "+ 3x Títulos a Pagar " + CRLF
    cMensagem += "+ 1x Baixa a Receber " + CRLF
    cMensagem += "+ 1x Baixa a Pagar " + CRLF

    //Se a pergunta for confirmada
    If Aviso("Confirmação?", cMensagem, {"Sim", "Nao"}) == 1
        Processa({|| fCarga()}, "Processando...")
    EndIf
Return

Static Function fCarga()
    Local aComponentes := {}
    Local dDataRef := Date()
    Local aProdutos := {}
    Local cInicio := Time()
    Local cTermino := ""
    Local cDiferenca := ""
    Private lAbortar := .F.

    ProcRegua(20)

    //1x Armazém
    IncProc("Parte 1 de 27 - Armazém")
    fLocEstoq("01", "Armazém Padrão")

    //1x Condição de Pagamento
    IncProc("Parte 2 de 27 - Condição Pagamento")
    fCondPag("C01", "1", "0", "A VISTA")

    //3x Grupos de Produto
    IncProc("Parte 3 de 27 - Grupos de Produto")
    fGrupo("G001", "Frutas e Legumes")
    fGrupo("G002", "Escritório")
    fGrupo("G003", "Produção")

    //13x Produtos
    IncProc("Parte 4 de 27 - Produtos")
    fProduto("E0001", "Caneta Azul",       "PA", "UN", "01", "G002")
    fProduto("E0002", "Caneta Vermelha",   "PA", "UN", "01", "G002")
    fProduto("I0001", "Tampa",             "PI", "UN", "01", "G003")
    fProduto("I0002", "Tubo Transparente", "PI", "UN", "01", "G003")
    fProduto("I0003", "Suporte Traseiro",  "PI", "UN", "01", "G003")
    fProduto("M0001", "Tinta Azul",        "MP", "ML", "01", "G003")
    fProduto("M0002", "Tinta Vermelha",    "MP", "ML", "01", "G003")
    fProduto("F0001", "Maçã",              "PA", "KG", "01", "G001")
    fProduto("F0002", "Banana",            "PA", "KG", "01", "G001")
    fProduto("F0003", "Kiwi",              "PA", "KG", "01", "G001")
    fProduto("F0004", "Laranja",           "PA", "KG", "01", "G001")
    fProduto("L0001", "Batata",            "PA", "KG", "01", "G001")
    fProduto("L0002", "Brócolis",          "PA", "KG", "01", "G001")

    //2x Naturezas Financeiras
    IncProc("Parte 5 de 27 - Naturezas Financeiras")
    fNatureza("NATREC0001", "Natureza de Receita (Default)", "R")
    fNatureza("NATDES0001", "Natureza de Despesa (Default)", "D")

    //3x Clientes
    IncProc("Parte 6 de 27 - Clientes")
    fCliente("C00001", "01", "João",   "Jão", "F", "Rua Iluminada 7-11",  "SP", "06003", "terminaldeinformacao.com", "NATREC0001", "A")
    fCliente("C00002", "01", "José",   "Zé",  "F", "Rua Asfaltada 23-10", "SP", "06003", "terminaldeinformacao.com", "NATREC0001", "A")
    fCliente("C00003", "01", "Daniel", "Dan", "F", "Rua Sem Saida 1-21",  "SP", "06003", "terminaldeinformacao.com", "NATREC0001", "A")

    //3x Fornecedores
    IncProc("Parte 7 de 27 - Fornecedores")
    fFornecedor("F00001", "01", "Quitanda do José",         "Zé's Quitanda", "F", "Rua da Feira 23-7",    "SP", "06003", "terminaldeinformacao.com", "NATDES0001")
    fFornecedor("F00002", "01", "Matéria Prima do Bruno",   "MPB",           "F", "Rua da Música 21-10",  "SP", "06003", "terminaldeinformacao.com", "NATDES0001")
    fFornecedor("F00003", "01", "Papelaria do João",        "PapelJão",      "F", "Rua do Comércio 7-24", "SP", "06003", "terminaldeinformacao.com", "NATDES0001")

    //2x Vendedores
    IncProc("Parte 8 de 27 - Vendedores")
    fVendedor("V00001", "Maria")
    fVendedor("V00002", "Joaquina")

    //1x Transportadoras
    IncProc("Parte 9 de 27 - Transportadoras")
    fTransportadora("T00001", "Transportadora - Já Chegou")

    //1x Banco
    IncProc("Parte 10 de 27 - Bancos")
    fBanco("B00", "A0000", "C000000000", "Banco de Testes")

    //2x Estruturas de Produto
    IncProc("Parte 11 de 27 - Estruturas de Produto")
    aComponentes := {}
    aAdd(aComponentes, {"I0001", 1})
    aAdd(aComponentes, {"I0002", 1})
    aAdd(aComponentes, {"I0003", 1})
    aAdd(aComponentes, {"M0001", 0.2})
    fEstrutura("E0001", aComponentes)

    aComponentes := {}
    aAdd(aComponentes, {"I0001", 1})
    aAdd(aComponentes, {"I0002", 1})
    aAdd(aComponentes, {"I0003", 1})
    aAdd(aComponentes, {"M0002", 0.2})
    fEstrutura("E0002", aComponentes)

    // 3x Tipos de Movimentação
    IncProc("Parte 12 de 27 - Tipos de Movimentação (Estoque)")
    fTipoMov("010", "P", "Produção",            "N", "S", "N", "N")
    fTipoMov("009", "D", "Acerto Residual (E)", "S", "S", "N", "N")
    fTipoMov("509", "R", "Acerto Residual (S)", "S", "S", "N", "N")

    //2x TES
    IncProc("Parte 13 de 27 - TES")
    fTpEntSai("001", "E", "N", "N", "S", "S", "N", "N", "N", "000", "Entrada Padrão", "N", "N", "N", "N", "N")
    fTpEntSai("501", "S", "N", "N", "S", "S", "N", "N", "N", "000", "Saída Padrão",   "N", "N", "N", "N", "N")

    //1x Centro de Custo
    IncProc("Parte 14 de 27 - Centros de Custo")
    fCentCust("PRO000001", "2", "Produtos")

    //13x Saldos Iniciais
    IncProc("Parte 15 de 27 - Saldos Iniciais")
    fSaldoIni("E0001", "01", dDataRef, 200)
    fSaldoIni("E0002", "01", dDataRef, 200)
    fSaldoIni("I0001", "01", dDataRef, 1000)
    fSaldoIni("I0002", "01", dDataRef, 1000)
    fSaldoIni("I0003", "01", dDataRef, 1000)
    fSaldoIni("M0001", "01", dDataRef, 500)
    fSaldoIni("M0002", "01", dDataRef, 500)
    fSaldoIni("F0001", "01", dDataRef, 50)
    fSaldoIni("F0002", "01", dDataRef, 50)
    fSaldoIni("F0003", "01", dDataRef, 30)
    fSaldoIni("F0004", "01", dDataRef, 100)
    fSaldoIni("L0001", "01", dDataRef, 100)
    fSaldoIni("L0002", "01", dDataRef, 50)

    //5x Movimentações Internas
    IncProc("Parte 16 de 27 - Movimentações Internas")
    aProdutos := {}
    aAdd(aProdutos, {"E0001", "01", 20})
    aAdd(aProdutos, {"F0001", "01", 5})
    aAdd(aProdutos, {"F0003", "01", 2})
    aAdd(aProdutos, {"F0004", "01", 2})
    aAdd(aProdutos, {"L0001", "01", 8})
    fMovInt("509", "PRO000001", dDataRef, aProdutos)

    //2x Ordens de Produção
	PutMV("MV_APTEMP", .T.) //Por causa do Empenho 12.1.2410
    IncProc("Parte 17 de 27 - Ordens de Produção")
    fOrdProd("E0001", 50, dDataRef, MonthSum(dDataRef, 3))

    //1x Apontamento de Produção
    IncProc("Parte 18 de 27 - Apontamento de Produção")
    fApontProd("E0001", "010", 25)

    //2x Pedidos de Compra
    IncProc("Parte 19 de 27 - Pedidos de Compra")
    aProdutos := {}
    aAdd(aProdutos, {"F0001", 5, 1.99})
    aAdd(aProdutos, {"F0003", 2, 5.99})
    aAdd(aProdutos, {"L0002", 3, 3.99})
    fPedCompr("F00001", "01", "C01", dDataRef, aProdutos)

    aProdutos := {}
    aAdd(aProdutos, {"E0001", 20, 0.80})
    aAdd(aProdutos, {"E0002", 20, 0.80})
    fPedCompr("F00003", "01", "C01", dDataRef, aProdutos)

    //1x Documento de Entrada
    IncProc("Parte 20 de 27 - Documento de Entrada")
    aProdutos := {}
    aAdd(aProdutos, {"F0001", 5, 1.99, "001", "000001", "0001"})
    aAdd(aProdutos, {"F0003", 2, 5.99, "001", "000001", "0002"})
    aAdd(aProdutos, {"L0002", 3, 3.99, "001", "000001", "0003"})
    fDocEntr("999999999", "TST", "F00003", "01", "NFE", "C01", aProdutos, dDataRef)

    //2x Pedidos de Venda
    IncProc("Parte 21 de 27 - Pedidos de Venda")
    aProdutos := {}
    aAdd(aProdutos, {"F0001", 1, 5.99, "501"})
    aAdd(aProdutos, {"F0004", 1, 2.99, "501"})
    fPedVen("C00002", "01", "V00001", dDataRef, "T00001", "C01", aProdutos)

    aAdd(aProdutos, {"F0002", 1, 3.99, "501"})
    aAdd(aProdutos, {"F0003", 1, 6.99, "501"})
    fPedVen("C00003", "01", "V00001", dDataRef, "T00001", "C01", aProdutos)

    //1x Liberação de Pedidos de Venda
    IncProc("Parte 22 de 27 - Liberação de Pedidos de Venda")
    fLiberPed("C00002", "01")

    //1x Documento de Saída
    IncProc("Parte 23 de 27 - Documento de Saída")
    fDocSaida("C00002", "01")

    //3x Títulos a Receber
    IncProc("Parte 24 de 27 - Títulos a Receber")
    fTitReceb("TST", "REC000001", "BOL", "C00001", "01", dDataRef, DaySum(dDataRef, 3), 150, "Boleto de teste a receber", "NATREC0001")
    fTitReceb("TST", "REC000002", "BOL", "C00002", "01", dDataRef, DaySum(dDataRef, 3), 250, "Boleto de teste a receber", "NATREC0001")
    fTitReceb("TST", "REC000003", "BOL", "C00003", "01", dDataRef, DaySum(dDataRef, 3), 350, "Boleto de teste a receber", "NATREC0001")

    //3x Títulos a Pagar
    IncProc("Parte 25 de 27 - Títulos a Pagar")
    fTitPagar("TST", "PAG000001", "BOL", "F00001", "01", dDataRef, DaySum(dDataRef, 3), 100, "Boleto de teste a pagar", "NATDES0001")
    fTitPagar("TST", "PAG000002", "BOL", "F00002", "01", dDataRef, DaySum(dDataRef, 3), 200, "Boleto de teste a pagar", "NATDES0001")
    fTitPagar("TST", "PAG000003", "BOL", "F00003", "01", dDataRef, DaySum(dDataRef, 3), 300, "Boleto de teste a pagar", "NATDES0001")

    //1x Baixa a Receber
    IncProc("Parte 26 de 27 - Baixa a Receber")
    fBxReceber("TST", "REC000001", "BOL", "C00001", "01", dDataRef)

    //1x Baixa a Pagar
    IncProc("Parte 27 de 27 - Baixa a Pagar")
    fBxPagar("TST", "PAG000001", "BOL", "F00001", "01", dDataRef, "B00", "A0000", "C000000000")
    
    //Finaliza a rotina e mostra o tempo total
    cTermino := Time()
    cDiferenca := ElapTime(cInicio, cTermino)
    ShowLog("zCargaLoc finalizado!" + CRLF + "Início: " + cInicio + CRLF + "Término: " + cTermino + CRLF + CRLF + "Total: " + cDiferenca)
Return

Static Function fLocEstoq(cCodigo, cDescricao)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("NNR")
        NNR->(DbSetOrder(1)) // NNR_FILIAL + NNR_CODIGO

        //Somente se não encontrar o armazém
        If ! NNR->(MsSeek(FWxFilial("NNR") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"NNR_CODIGO", cCodigo,    Nil})
            aAdd(aDados, {"NNR_DESCRI", cDescricao, Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| AGRA045(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fCondPag(cCodigo, cTipo, cCondic, cDescricao)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SE4")
        SE4->(DbSetOrder(1)) // E4_FILIAL + E4_CODIGO

        //Somente se não encontrar o armazém
        If ! SE4->(MsSeek(FWxFilial("SE4") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"E4_CODIGO", cCodigo,    Nil})
            aAdd(aDados, {"E4_TIPO",   cTipo,      Nil})
            aAdd(aDados, {"E4_COND",   cCondic,    Nil})
            aAdd(aDados, {"E4_DESCRI", cDescricao, Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA360(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fGrupo(cCodigo, cDescricao)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SBM")
        SBM->(DbSetOrder(1)) // BM_FILIAL + BM_GRUPO

        //Somente se não encontrar o armazém
        If ! SBM->(MsSeek(FWxFilial("SBM") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"BM_GRUPO", cCodigo,    Nil})
            aAdd(aDados, {"BM_DESC", cDescricao, Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA035(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fProduto(cCodigo, cDescricao, cTipo, cUnidMed, cArmazem, cGrupo)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD

        //Somente se não encontrar o armazém
        If ! SB1->(MsSeek(FWxFilial("SB1") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"B1_COD",    cCodigo,    Nil})
            aAdd(aDados, {"B1_DESC",   cDescricao, Nil})
            aAdd(aDados, {"B1_TIPO",   cTipo,      Nil})
            aAdd(aDados, {"B1_UM",     cUnidMed,   Nil})
            aAdd(aDados, {"B1_LOCPAD", cArmazem,   Nil})
            aAdd(aDados, {"B1_GRUPO",  cGrupo,     Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA010(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fNatureza(cCodigo, cDescricao, cTipo)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SED")
        SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO

        //Somente se não encontrar o armazém
        If ! SED->(MsSeek(FWxFilial("SED") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"ED_CODIGO",    cCodigo,    Nil})
            aAdd(aDados, {"ED_DESCRIC",   cDescricao, Nil})
            aAdd(aDados, {"ED_COND",      cTipo,      Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| FINA010(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fCliente(cCodigo, cLoja, cNome, cNReduz, cTipo, cEndereco, cEstado, cCodMun, cSite, cNatureza, cRisco)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SA1")
        SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA

        //Somente se não encontrar o armazém
        If ! SA1->(MsSeek(FWxFilial("SA1") + cCodigo + cLoja))

            //Adiciona os campos
            aAdd(aDados, {"A1_COD",      cCodigo,   Nil})
            aAdd(aDados, {"A1_LOJA",     cLoja,     Nil})
            aAdd(aDados, {"A1_NOME",     cNome,     Nil})
            aAdd(aDados, {"A1_NREDUZ",   cNReduz,   Nil})
            aAdd(aDados, {"A1_TIPO",     cTipo,     Nil})
            aAdd(aDados, {"A1_END",      cEndereco, Nil})
            aAdd(aDados, {"A1_EST",      cEstado,   Nil})
            aAdd(aDados, {"A1_COD_MUN",  cCodMun,   Nil})
            aAdd(aDados, {"A1_HPAGE",    cSite,     Nil})
            aAdd(aDados, {"A1_NATUREZ",  cNatureza, Nil})
            aAdd(aDados, {"A1_RISCO",    cRisco,    Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| CRMA980(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fFornecedor(cCodigo, cLoja, cNome, cNReduz, cTipo, cEndereco, cEstado, cCodMun, cSite, cNatureza)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SA2")
        SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA

        //Somente se não encontrar o armazém
        If ! SA2->(MsSeek(FWxFilial("SA2") + cCodigo + cLoja))

            //Adiciona os campos
            aAdd(aDados, {"A2_COD",      cCodigo,   Nil})
            aAdd(aDados, {"A2_LOJA",     cLoja,     Nil})
            aAdd(aDados, {"A2_NOME",     cNome,     Nil})
            aAdd(aDados, {"A2_NREDUZ",   cNReduz,   Nil})
            aAdd(aDados, {"A2_TIPO",     cTipo,     Nil})
            aAdd(aDados, {"A2_END",      cEndereco, Nil})
            aAdd(aDados, {"A2_EST",      cEstado,   Nil})
            aAdd(aDados, {"A2_COD_MUN",  cCodMun,   Nil})
            aAdd(aDados, {"A2_HPAGE",    cSite,     Nil})
            aAdd(aDados, {"A2_NATUREZ",  cNatureza, Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA020(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fVendedor(cCodigo, cNome)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SA3")
        SA3->(DbSetOrder(1)) // A3_FILIAL + A3_COD

        //Somente se não encontrar o armazém
        If ! SA3->(MsSeek(FWxFilial("SA3") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"A3_COD",      cCodigo,   Nil})
            aAdd(aDados, {"A3_NOME",     cNome,     Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA040(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return


Static Function fTransportadora(cCodigo, cNome)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SA4")
        SA4->(DbSetOrder(1)) // A4_FILIAL + A4_COD

        //Somente se não encontrar o armazém
        If ! SA4->(MsSeek(FWxFilial("SA4") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"A4_COD",      cCodigo,   Nil})
            aAdd(aDados, {"A4_NOME",     cNome,     Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA050(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fBanco(cBanco, cAgencia, cConta, cNome)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SA6")
        SA6->(DbSetOrder(1)) // A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON

        //Somente se não encontrar o armazém
        If ! SA6->(MsSeek(FWxFilial("SA6") + cBanco + cAgencia + cConta))

            //Adiciona os campos
            aAdd(aDados, {"A6_COD",      cBanco,    Nil})
            aAdd(aDados, {"A6_AGENCIA",  cAgencia,  Nil})
            aAdd(aDados, {"A6_NUMCON",   cConta,    Nil})
            aAdd(aDados, {"A6_NOME",     cNome,     Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA070(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

//Exemplo em https://tdn.totvs.com/pages/releaseview.action?pageId=447092714
Static Function fEstrutura(cProduto, aComponentes)
    Local aCab   := {}
    Local aItens := {}
    Local nAtual := 0
    Local aLogErro := {}
    Local cTextoErro := ""
    Local nLinhaErro := 0
    Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SG1")
        SG1->(DbSetOrder(1)) // G1_FILIAL + G1_COD + G1_COMP + G1_TRT

        //Somente se não encontrar o armazém
        If ! SG1->(MsSeek(FWxFilial("SG1") + cProduto))

            aCab := {;
                {"G1_COD"   , cProduto , Nil},; //Código do produto PAI.
                {"G1_QUANT" , 1        , Nil},; //Quantidade base do produto PAI.
                {"ATUREVSB1", "N"      , Nil},; //A variável ATUREVSB1 é utilizada para gerar nova revisão quando MV_REVAUT=.F.
                {"NIVALT"   , "S"      , Nil};  //A variável NIVALT é utilizada para recalcular ou não 
            }

            //Adiciona os campos
            For nAtual := 1 To Len(aComponentes)
                aGets := {}
                aAdd(aGets, {"G1_COD"  , cProduto                              , Nil})
                aAdd(aGets, {"G1_COMP" , aComponentes[nAtual][1]               , Nil})
                aAdd(aGets, {"G1_TRT"  , Space(3)                              , Nil})
                aAdd(aGets, {"G1_QUANT", aComponentes[nAtual][2]               , Nil})
                aAdd(aGets, {"G1_INI"  , Date()                                , Nil})
                aAdd(aGets, {"G1_FIM"  , cToD("31/12/49")                      , Nil})
                aAdd(aGets, {"G1_PERDA", 0                                     , Nil})
                aAdd(aItens, aClone(aGets))
            Next

            //Chama a inclusão
            MsExecAuto({|x, y, z| PCPA200(x, y, z)}, aCab, aItens, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                //Pegando log do ExecAuto, percorrendo e incrementando o texto
                aLogErro := GetAutoGRLog()
                cTextoErro := ''
                For nLinhaErro := 1 To Len(aLogErro)
                    cTextoErro += aLogErro[nLinhaErro] + CRLF
                Next

                //Se não for o aviso sobre o novo gestor de procedures
                If ! "utilizar o novo modelo de gest" $ Lower(cTextoErro)
                    ShowLog(cTextoErro)
                    lAbortar := .T.
                EndIf
            EndIf
        EndIf
    EndIf
Return

Static Function fTipoMov(cCodigo, cTipo, cDescricao, cApropr, cAtuEmp, cValoriz, cTransMod)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SF5")
        SF5->(DbSetOrder(1)) // F5_FILIAL + F5_CODIGO

        //Somente se não encontrar o armazém
        If ! SF5->(MsSeek(FWxFilial("SF5") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"F5_CODIGO",   cCodigo,    Nil})
            aAdd(aDados, {"F5_TIPO",     cTipo,      Nil})
            aAdd(aDados, {"F5_TEXTO",    cDescricao, Nil})
            aAdd(aDados, {"F5_APROPR",   cApropr,    Nil})
            aAdd(aDados, {"F5_ATUEMP",   cAtuEmp,    Nil})
            aAdd(aDados, {"F5_VAL",      cValoriz,   Nil})
            aAdd(aDados, {"F5_TRANMOD",  cTransMod,  Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA230(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fTpEntSai(cCodigo, cTipo, cCredIcm, cCredIPI, cGeraDupl, cMovEstoq, cPoder3, cIcms, cIPI, cCodFis, cTexto, cLivroIcms, cLivroIPI, cDestaca, cIncide, cComplem)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SF4")
        SF4->(DbSetOrder(1)) // F4_FILIAL + F4_CODIGO

        //Somente se não encontrar o armazém
        If ! SF4->(MsSeek(FWxFilial("SF4") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"F4_CODIGO",  cCodigo,    Nil})
            aAdd(aDados, {"F4_TIPO",    cTipo,      Nil})
            aAdd(aDados, {"F4_CREDICM", cCredIcm,   Nil})
            aAdd(aDados, {"F4_CREDIPI", cCredIPI,   Nil})
            aAdd(aDados, {"F4_DUPLIC",  cGeraDupl,  Nil})
            aAdd(aDados, {"F4_ESTOQUE", cMovEstoq,  Nil})
            aAdd(aDados, {"F4_PODER3",  cPoder3,    Nil})
            aAdd(aDados, {"F4_ICM",     cIcms,      Nil})
            aAdd(aDados, {"F4_IPI",     cIPI,       Nil})
            aAdd(aDados, {"F4_CF",      cCodFis,    Nil})
            aAdd(aDados, {"F4_TEXTO",   cTexto,     Nil})
            aAdd(aDados, {"F4_LFICM",   cLivroIcms, Nil})
            aAdd(aDados, {"F4_LFIPI",   cLivroIPI,  Nil})
            aAdd(aDados, {"F4_DESTACA", cDestaca,   Nil})
            aAdd(aDados, {"F4_INCIDE",  cIncide,    Nil})
            aAdd(aDados, {"F4_COMPL",   cComplem,   Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA080(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fSaldoIni(cCodProd, cArmazem, dDataRef, nQuantIni)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SB9")
        SB9->(DbSetOrder(1)) // B9_FILIAL + B9_COD + B9_LOCAL + DTOS(B9_DATA)

        cCodProd := PadR(cCodProd, TamSX3("B9_COD")[1])

        //Somente se não encontrar o armazém
        If ! SB9->(MsSeek(FWxFilial("SB9") + cCodProd + cArmazem))

            //Adiciona os campos
            aAdd(aDados, {"B9_COD",   cCodProd,   Nil})
            aAdd(aDados, {"B9_LOCAL", cArmazem,   Nil})
            //aAdd(aDados, {"B9_DATA",  dDataRef,   Nil})
            aAdd(aDados, {"B9_QINI",  nQuantIni,  Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| MATA220(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fCentCust(cCodigo, cClasse, cDescricao)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("CTT")
        CTT->(DbSetOrder(1)) // CTT_FILIAL + CTT_CUSTO

        //Somente se não encontrar o armazém
        If ! CTT->(MsSeek(FWxFilial("CTT") + cCodigo))

            //Adiciona os campos
            aAdd(aDados, {"CTT_CUSTO",  cCodigo,    Nil})
            aAdd(aDados, {"CTT_CLASSE", cClasse,    Nil})
            aAdd(aDados, {"CTT_DESC01", cDescricao, Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| CTBA030(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fMovInt(cTipoMov, cCentCus, dData, aProds)
    Local aCab   := {}
    Local aItens := {}
    Local nAtual := 0
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SD3")
        SD3->(DbSetOrder(5)) // D3_FILIAL + D3_TM + D3_COD

        //Somente se não encontrar movimentação para o TM
        If ! SD3->(MsSeek(FWxFilial("SD3") + cTipoMov))
            cDocumento := NextNumero("SD3", 2, "D3_DOC", .T.)
            aCab := {;
                {"D3_DOC"      	, cDocumento	, Nil},;
                {"D3_TM"    	, cTipoMov      , Nil},;
                {"D3_CC"    	, cCentCus      , Nil},;
                {"D3_EMISSAO"	, dData         , Nil};
            }

            //Adiciona os campos
            For nAtual := 1 To Len(aProds)
                aGets := {}
                aAdd(aGets, {"D3_COD"   , aProds[nAtual][1]               , Nil})
                aAdd(aGets, {"D3_LOCAL" , aProds[nAtual][2]               , Nil})
                aAdd(aGets, {"D3_QUANT" , aProds[nAtual][3]               , Nil})
                aAdd(aItens, aClone(aGets))
            Next

            //Chama a inclusão
            MsExecAuto({|x, y, z| MATA241(x, y, z)}, aCab, aItens, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fOrdProd(cCodProd, nQuant, dPrevIni, dPrevFim)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SC2")
        SC2->(DbSetOrder(2)) // C2_FILIAL + C2_PRODUTO + DTOS(C2_DATPRF)

        //Somente se não encontrar o armazém
        If ! SC2->(MsSeek(FWxFilial("SC2") + cCodProd))

            //Adiciona os campos
            aAdd(aDados, {"C2_PRODUTO",   cCodProd,   Nil})
            aAdd(aDados, {"AUTEXPLODE",   "S",        Nil})
            aAdd(aDados, {"C2_QUANT",     nQuant,     Nil})
            aAdd(aDados, {"C2_DATPRI",    dPrevIni,   Nil})
            aAdd(aDados, {"C2_DATPRF",    dPrevFim,   Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| Mata650(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fApontProd(cCodProd, cTipoMov, nQuant)
    Local aDados := {}
    Local cQryOP   := ""
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        //Busca o número da OP que foi criada
        cQryOP := " SELECT  " + CRLF
        cQryOP += " 	C2_NUM + C2_ITEM + C2_SEQUEN AS OP,  " + CRLF
        cQryOP += " 	C2_LOCAL " + CRLF
        cQryOP += " FROM  " + CRLF
        cQryOP += " 	" + RetSQLName("SC2") + " SC2 " + CRLF
        cQryOP += " WHERE " + CRLF
        cQryOP += " 	C2_FILIAL = '" + FWxFilial("SC2") + "' " + CRLF
        cQryOP += " 	AND	C2_PRODUTO = '" + cCodProd + "' " + CRLF
        cQryOP += " 	AND SC2.D_E_L_E_T_ = ' ' " + CRLF
        TCQuery cQryOP New Alias "QRY_OP"

        //Se houver OPs
        If ! QRY_OP->(EoF())

            DbSelectArea("SD3")
            SD3->(DbSetOrder(1)) // D3_FILIAL + D3_OP + D3_COD + D3_LOCAL

            //Somente se não encontrar o armazém
            If ! SD3->(MsSeek(FWxFilial("SD3") + QRY_OP->OP))

                //Adiciona os campos
                aAdd(aDados, {"D3_COD",    cCodProd,           Nil})
                aAdd(aDados, {"D3_TM",     cTipoMov,           Nil})
                aAdd(aDados, {"D3_QUANT",  nQuant,             Nil})
                aAdd(aDados, {"D3_OP",     QRY_OP->OP,         Nil})
                aAdd(aDados, {"D3_LOCAL",  QRY_OP->C2_LOCAL,   Nil})

                //Chama a inclusão
                MsExecAuto({|x, y| Mata250(x, y)}, aDados, 3)

                //Se houve erro, mostra a mensagem, e aborta o restante das operações
                If lMsErroAuto
                    MostraErro()
                    lAbortar := .T.
                EndIf
            EndIf
        EndIf
        QRY_OP->(DbCloseArea())
    EndIf
Return

Static Function fPedCompr(cCodForn, cLojForn, cCondPag, dData, aProdutos)
    Local aCabC7 := {}
    Local aItensC7 := {}
    Local nAtual
    Local cItem   := StrTran(Space(TamSX3('C7_ITEM')[01]), ' ', '0')
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SC7")
        SC7->(DbSetOrder(3)) // C7_FILIAL + C7_FORNECE + C7_LOJA + C7_NUM

        //Somente se não encontrar o armazém
        If ! SC7->(MsSeek(FWxFilial("SC7") + cCodForn + cLojForn))
            //Cabeçalho do pedido de compras
            aCabC7 := {;
                {"C7_FILIAL"  , cFilAnt	   , Nil},;
			    {"C7_FORNECE" , cCodForn   , Nil},;
			    {"C7_LOJA"    , cLojForn   , Nil},;
			    {"C7_COND"    , cCondPag   , Nil},;
	   		    {"C7_EMISSAO" , dData      , Nil},;
	   		    {'C7_MOEDA'	  , 1		   , Nil},;
	   		    {"C7_CONTATO" , ""         , Nil},;
	   		    {"C7_FILENT"  , cFilAnt	   , Nil},;
	  		    {"C7_TIPO"    , "1"        , Nil},;
	  		    {'C7_TXMOEDA' ,  0         , Nil};
            }
            
            //Percorre os produtos
            For nAtual := 1 To Len(aProdutos)
                cItem := Soma1(cItem)

                aGets := {}
                aAdd(aGets, {"C7_ITEM"    , cItem     		                            , Nil} )
				aAdd(aGets, {"C7_PRODUTO" , aProdutos[nAtual][1]                        , Nil} )
				aAdd(aGets, {"C7_QUANT"   , aProdutos[nAtual][2]                        , Nil} )
				aAdd(aGets, {"C7_PRECO"   , aProdutos[nAtual][3]                        , Nil} )
				aAdd(aGets, {"C7_TOTAL"   , aProdutos[nAtual][2] * aProdutos[nAtual][3] , Nil} )
                aAdd(aItensC7, aClone(aGets))
            Next

            //Chama a inclusão
            MSExecAuto({|v, w, x, y, z| Mata120(v, w, x, y, z) }, 1, aCabC7, aItensC7, 3, .F.)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf

Return

Static Function fDocEntr(cDocumen, cSerie, cCodForn, cLojForn, cEspecie, cCondPag, aProdutos, dDataRef)
    Local aCabec := {}
    Local aItens := {}
    Local nAtual
    Local cItem   := StrTran(Space(TamSX3('D1_ITEM')[01]), ' ', '0')
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SF1")
        SF1->(DbSetOrder(1)) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO

        //Somente se não encontrar o armazém
        If ! SF1->(MsSeek(FWxFilial("SF1") + cDocumen + cSerie + cCodForn + cLojForn + "N"))
            //Cabeçalho do doc de
            aCabec := {}
            aAdd(aCabec, {"F1_TIPO"    , "N"        , Nil})
            aAdd(aCabec, {"F1_FORMUL"  , "N"        , Nil})
            aAdd(aCabec, {"F1_DOC"     , cDocumen   , Nil})
            aAdd(aCabec, {"F1_SERIE"   , cSerie     , Nil})
            aAdd(aCabec, {"F1_EMISSAO" , dDataRef   , Nil})
			aAdd(aCabec, {"F1_FORNECE" , cCodForn   , Nil})
			aAdd(aCabec, {"F1_LOJA"    , cLojForn   , Nil})
            aAdd(aCabec, {"F1_ESPECIE" , cEspecie   , Nil})
			aAdd(aCabec, {"F1_COND"    , cCondPag   , Nil})

            //Percorre os produtos
            For nAtual := 1 To Len(aProdutos)
                cItem := Soma1(cItem)

                aGets := {}
                aAdd(aGets, {"D1_ITEM"    , cItem     		                            , Nil} )
				aAdd(aGets, {"D1_COD"     , aProdutos[nAtual][1]                        , Nil} )
				aAdd(aGets, {"D1_QUANT"   , aProdutos[nAtual][2]                        , Nil} )
				aAdd(aGets, {"D1_VUNIT"   , aProdutos[nAtual][3]                        , Nil} )
				aAdd(aGets, {"D1_TOTAL"   , aProdutos[nAtual][2] * aProdutos[nAtual][3] , Nil} )
                aAdd(aGets, {"D1_TES"     , aProdutos[nAtual][4]                        , Nil} )
                //aAdd(aGets, {"D1_PEDIDO"  , aProdutos[nAtual][5]                        , Nil} )
                //aAdd(aGets, {"D1_ITEMPC"  , aProdutos[nAtual][6]                        , Nil} )
                aAdd(aItens, aClone(aGets))
            Next

            //Chama a inclusão
            MSExecAuto({|x, y, z| Mata103(x, y, z) }, aCabec, aItens, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf

Return

Static Function fPedVen(cCodCli, cLojCli, cVended, dEmissao, cTransp, cCondPag, aProdutos)
    Local aCabec := {}
    Local aItens := {}
    Local nAtual
    Local cItem   := StrTran(Space(TamSX3('C6_ITEM')[01]), ' ', '0')
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SC5")
        SC5->(DbSetOrder(3)) // C5_FILIAL + C5_CLIENTE + C5_LOJACLI + C5_NUM

        //Somente se não encontrar o armazém
        If ! SC5->(MsSeek(FWxFilial("SC5") + cCodCli + cLojCli))
            //Cabeçalho do pedido de compras
            aCabec := {;
                {"C5_FILIAL"  , cFilAnt	   , Nil},;
                {"C5_TIPO"    , "N"   , Nil},;
                {"C5_CLIENTE" , cCodCli   , Nil},;
                {"C5_LOJACLI" , cLojCli     , Nil},;
                {"C5_VEND1"   , cVended        , Nil},;
			    {"C5_EMISSAO" , dEmissao   , Nil},;
			    {"C5_MOEDA"   , 1   , Nil},;
                {"C5_TXMOEDA" , 1   , Nil},;
                {"C5_TRANSP"  , cTransp   , Nil},;
			    {"C5_CONDPAG" , cCondPag   , Nil};
            }

            //Percorre os produtos
            For nAtual := 1 To Len(aProdutos)
                cItem := Soma1(cItem)

                aGets := {}
                aAdd(aGets, {"C6_ITEM"     , cItem     		                             , Nil} )
				aAdd(aGets, {"C6_PRODUTO"  , aProdutos[nAtual][1]                        , Nil} )
				aAdd(aGets, {"C6_QTDVEN"   , aProdutos[nAtual][2]                        , Nil} )
				aAdd(aGets, {"C6_PRCVEN"   , aProdutos[nAtual][3]                        , Nil} )
				aAdd(aGets, {"C6_VALOR "   , aProdutos[nAtual][2] * aProdutos[nAtual][3] , Nil} )
                aAdd(aGets, {"C6_TES"      , aProdutos[nAtual][4]                        , Nil} )
                aAdd(aItens, aClone(aGets))
            Next

            //Chama a inclusão
            MSExecAuto({|x, y, z| Mata410(x, y, z) }, aCabec, aItens, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf

Return

Static Function fLiberPed(cCodCli, cLojCli)

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SC5")
        SC5->(DbSetOrder(3)) // C5_FILIAL + C5_CLIENTE + C5_LOJACLI + C5_NUM

        //Somente se encontrar o pedido para aquele cliente
        If SC5->(MsSeek(FWxFilial("SC5") + cCodCli + cLojCli))

            DbSelectArea('SC6')
            SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
            SC6->(DbGoTop())
            SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

            //Estorna as liberações
            While ! SC6->(EoF()) .And. SC6->C6_FILIAL = SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
                //Posiciona na liberação do item do pedido e estorna a liberação
                SC9->(DbSeek(FWxFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM))
                While  ! SC9->(EoF()) .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == FWxFilial('SC9')+SC6->(C6_NUM+C6_ITEM)
                    SC9->(a460Estorna(.T.))
                    SC9->(DbSkip())
                EndDo
     
                SC6->(DbSkip())
            EndDo

            //Define que o pedido foi liberado
            RecLock("SC5", .F.)
                SC5->C5_LIBEROK := 'S'            
            SC5->(MsUnlock())

            SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
            While !SC6->(Eof()) .And. SC5->C5_NUM == SC6->C6_NUM

                MaLibDoFat(;
                    SC6->(RecNo()),; //nRegSC6
                    SC6->C6_QTDVEN,; //nQtdaLib
                    ,;               //lCredito
                    ,;               //lEstoque
                    .T.,;            //lAvCred
                    .T.,;            //lAvEst
                    .F.,;            //lLibPar
                    .F.;             //lTrfLocal
                )
                SC6->(DbSkip())   
            EndDo
        EndIf
    EndIf
Return

Static Function fDocSaida(cCodCli, cLojCli)
    Local aPvlDocS  := {}
    Local cDocument := ""
    Local cSerie    := "1"
    Local cFunBkp   := ""

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SC5")
        SC5->(DbSetOrder(3)) // C5_FILIAL + C5_CLIENTE + C5_LOJACLI + C5_NUM

        //Somente se encontrar o pedido para aquele cliente
        If SC5->(MsSeek(FWxFilial("SC5") + cCodCli + cLojCli))
            If Empty(SC5->C5_NOTA)

                DbSelectArea('SC6')
                SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
                SC6->(DbGoTop())
                SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

                //É necessário carregar a pergunta em memória
                Pergunte("MT460A", .F.)

                //Abre as tabelas que serão usadas
                DbSelectArea("SC9")
                SC9->(DbSetOrder(1)) //C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED
                DbSelectArea("SE4")
                SE4->(DbSetOrder(1)) //E4_FILIAL + E4_CODIGO
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
                DbSelectArea("SB2")
                SB2->(DbSetOrder(1)) //B2_FILIAL + B2_COD + B2_LOCAL
                DbSelectArea("SF4")
                SF4->(DbSetOrder(1)) //F4_FILIAL + F4_CODIGO

                //Percorre todos os itens do pedido para pode carregar o array que irá gerar a NF
                While ! SC6->(Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

                    //Posiciona nas tabelas
                    SC9->(MsSeek(FWxFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))
                    SE4->(MsSeek(FWxFilial("SE4")+SC5->C5_CONDPAG) )
                    SB1->(MsSeek(FWxFilial("SB1")+SC6->C6_PRODUTO))
                    SB2->(MsSeek(FWxFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))
                    SF4->(MsSeek(FWxFilial("SF4")+SC6->C6_TES))

                    //Se tiver liberado o BLEST e BLCRED
                    If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
                        aAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
                                        SC9->C9_ITEM,;
                                        SC9->C9_SEQUEN,;
                                        SC9->C9_QTDLIB,;
                                        SC9->C9_PRCVEN,;
                                        SC9->C9_PRODUTO,;
                                        .F.,;
                                        SC9->(RecNo()),;
                                        SC5->(RecNo()),;
                                        SC6->(RecNo()),;
                                        SE4->(RecNo()),;
                                        SB1->(RecNo()),;
                                        SB2->(RecNo()),;
                                        SF4->(RecNo())})
                    EndIf

                    SC6->(DbSkip())
                EndDo

                If Len(aPvlDocS) > 0
                    cFunBkp := FunName()
                    SetFunName("MATA461")
                    cDocument := MaPvlNfs(;
                        aPvlDocS,;  // 01 - aPvlNfs      - Array com os itens a serem gerados
                        cSerie,;    // 02 - cSerie_NFS   - Serie da Nota Fiscal
                        .F.,;       // 03 - lMostraCtb   - Mostra Lançamento Contábil
                        .F.,;       // 04 - lAglutCtb    - Aglutina Lançamento Contábil
                        .F.,;       // 05 - lCtbOnLine   - Contabiliza On-Line
                        .T.,;       // 06 - lCtbCusto    - Contabiliza Custo On-Line
                        .F.,;       // 07 - lReajuste    - Reajuste de preço na Nota Fiscal
                        0,;         // 08 - nCalAcrs     - Tipo de Acréscimo Financeiro
                        0,;         // 09 - nArredPrcLis - Tipo de Arredondamento
                        .T.,;       // 10 - lAtuSA7      - Atualiza Amarração Cliente x Produto
                        .F.,;       // 11 - lECF         - Cupom Fiscal
                        "",;        // 12 - cEmbExp      - Número do Embarque de Exportação
                        {||},;      // 13 - bAtuFin      - Bloco de Código para complemento de atualização dos títulos financeiros
                        {||},;      // 14 - bAtuPGerNF   - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
                        {||},;      // 15 - bAtuPvl      - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
                        {|| .T. },; // 16 - bFatSE1      - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
                        Date(),;    // 17 - dDataMoe     - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
                        .F.;        // 18 - lJunta       - Aglutina Pedido Iguais
                    )
                    SetFunName(cFunBkp)
                    
                    If Empty(cDocument)
                        lAbortar := .T.
                    EndIf
                Else
                    lAbortar := .T.
                EndIf
            EndIf
        EndIf

        If lAbortar
            MsgStop("Não foi possível gerar o Documento de Saída!", "Atenção")
        EndIf
    EndIf
Return

Static Function fTitReceb(cPrefixo, cNumero, cTipo, cCodCli, cLojCli, dEmissao, dVencto, nValor, cHist, cNatureza)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SE1")
        SE1->(DbSetOrder(2)) // E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

        //Somente se não encontrar o título
        If ! SE1->(MsSeek(FWxFilial("SE1") + cCodCli + cLojCli + cPrefixo + cNumero))

            //Adiciona os campos
            aAdd(aDados, {"E1_PREFIXO", cPrefixo,  Nil})
            aAdd(aDados, {"E1_NUM"    , cNumero,   Nil})
            aAdd(aDados, {"E1_TIPO"   , cTipo,     Nil})
            aAdd(aDados, {"E1_NATUREZ", cNatureza, Nil})
            aAdd(aDados, {"E1_CLIENTE", cCodCli,   Nil})
            aAdd(aDados, {"E1_LOJA"   , cLojCli,   Nil})
            aAdd(aDados, {"E1_EMISSAO", dEmissao,  Nil})
            aAdd(aDados, {"E1_VENCTO" , dVencto,   Nil})
            aAdd(aDados, {"E1_VALOR"  , nValor,    Nil})
            aAdd(aDados, {"E1_HIST"   , cHist,     Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| FINA040(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fTitPagar(cPrefixo, cNumero, cTipo, cCodFor, cLojFor, dEmissao, dVencto, nValor, cHist, cNatureza)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SE2")
        SE2->(DbSetOrder(6)) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM

        //Somente se não encontrar o título
        If ! SE2->(MsSeek(FWxFilial("SE2") + cCodFor + cLojFor + cPrefixo + cNumero))

            //Adiciona os campos
            aAdd(aDados, {"E2_PREFIXO", cPrefixo,  Nil})
            aAdd(aDados, {"E2_NUM"    , cNumero,   Nil})
            aAdd(aDados, {"E2_TIPO"   , cTipo,     Nil})
            aAdd(aDados, {"E2_NATUREZ", cNatureza, Nil})
            aAdd(aDados, {"E2_FORNECE", cCodFor,   Nil})
            aAdd(aDados, {"E2_LOJA"   , cLojFor,   Nil})
            aAdd(aDados, {"E2_EMISSAO", dEmissao,  Nil})
            aAdd(aDados, {"E2_VENCTO" , dVencto,   Nil})
            aAdd(aDados, {"E2_VALOR"  , nValor,    Nil})
            aAdd(aDados, {"E2_HIST"   , cHist,     Nil})

            //Chama a inclusão
            MsExecAuto({|x, y| FINA050(x, y)}, aDados, 3)

            //Se houve erro, mostra a mensagem, e aborta o restante das operações
            If lMsErroAuto
                MostraErro()
                lAbortar := .T.
            EndIf
        EndIf
    EndIf
Return

Static Function fBxReceber(cPrefixo, cNumero, cTipo, cCodCli, cLojCli, dDataRef)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SE1")
        SE1->(DbSetOrder(2)) // E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

        //Somente se encontrar o título
        If SE1->(MsSeek(FWxFilial("SE1") + cCodCli + cLojCli + cPrefixo + cNumero))
            If SE1->E1_SALDO != 0
                //Adiciona os campos
                aAdd(aDados, {"E1_FILIAL",    SE1->E1_FILIAL,      Nil})
                aAdd(aDados, {"E1_PREFIXO",   SE1->E1_PREFIXO,     Nil})
                aAdd(aDados, {"E1_NUM",       SE1->E1_NUM,         Nil})
                aAdd(aDados, {"E1_PARCELA",   SE1->E1_PARCELA,     Nil})
                aAdd(aDados, {"E1_TIPO",      SE1->E1_TIPO,        Nil})
                aAdd(aDados, {"E1_CLIENTE",   SE1->E1_CLIENTE,     Nil})
                aAdd(aDados, {"E1_LOJA",      SE1->E1_LOJA,        Nil})
                aAdd(aDados, {"AUTMOTBX",     "NOR",               Nil})
                aAdd(aDados, {"AUTDTBAIXA",   dDataRef,            Nil})
                aAdd(aDados, {"AUTDTCREDITO", dDataRef,            Nil})
                aAdd(aDados, {"AUTHIST",      "Baixa Automática",  Nil})
                aAdd(aDados, {"AUTVALREC",    SE1->E1_SALDO,       Nil})

                //Chama a inclusão
                MsExecAuto({|x, y| FINA070(x, y)}, aDados, 3)

                //Se houve erro, mostra a mensagem, e aborta o restante das operações
                If lMsErroAuto
                    MostraErro()
                    lAbortar := .T.
                EndIf
            EndIf
        EndIf
    EndIf
Return

Static Function fBxPagar(cPrefixo, cNumero, cTipo, cCodFor, cLojFor, dDataRef, cBanco, cAgencia, cConta)
    Local aDados := {}
    Private lMsErroAuto := .F.

    //Somente se não tiver sido abortado
    If ! lAbortar

        DbSelectArea("SE2")
        SE2->(DbSetOrder(6)) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM

        //Somente se encontrar o título
        If SE2->(MsSeek(FWxFilial("SE2") + cCodFor + cLojFor + cPrefixo + cNumero))
            If SE2->E2_SALDO != 0
                //Adiciona os campos
                aAdd(aDados, {"E2_FILIAL",    SE2->E2_FILIAL,      Nil})
                aAdd(aDados, {"E2_PREFIXO",   SE2->E2_PREFIXO,     Nil})
                aAdd(aDados, {"E2_NUM",       SE2->E2_NUM,         Nil})
                aAdd(aDados, {"E2_PARCELA",   SE2->E2_PARCELA,     Nil})
                aAdd(aDados, {"E2_TIPO",      SE2->E2_TIPO,        Nil})
                aAdd(aDados, {"E2_FORNECE",   SE2->E2_FORNECE,     Nil})
                aAdd(aDados, {"E2_LOJA",      SE2->E2_LOJA,        Nil})
                aAdd(aDados, {"AUTMOTBX",     "NOR",               Nil})
                aAdd(aDados, {"AUTBANCO",     cBanco,              Nil})
                aAdd(aDados, {"AUTAGENCIA",   cAgencia,            Nil})
                aAdd(aDados, {"AUTCONTA",     cConta,              Nil})
                aAdd(aDados, {"AUTDTBAIXA",   dDataRef,            Nil})
                aAdd(aDados, {"AUTDTCREDITO", dDataRef,            Nil})
                aAdd(aDados, {"AUTHIST",      "Baixa Automática",  Nil})
                aAdd(aDados, {"AUTVLRPG",     SE2->E2_SALDO,       Nil})

                //Chama a inclusão
                MsExecAuto({|x, y| FINA080(x, y)}, aDados, 3)

                //Se houve erro, mostra a mensagem, e aborta o restante das operações
                If lMsErroAuto
                    MostraErro()
                    lAbortar := .T.
                EndIf
            EndIf
        EndIf
    EndIf
Return

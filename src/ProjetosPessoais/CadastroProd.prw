#Include "TOTVS.ch"

User Function ControleEstoque()
	Local aMenu := {}
	Local nOpcao := 0

	While nOpcao != 4
		aMenu := {
		{"1 - Cadastrar Produto", {|| CadastrarProduto()}},
		{"2 - Registrar Entrada/Saída", {|| RegistrarMovimentacao()}},
		{"3 - Gerar Relatório", {|| GerarRelatorio()}},
		{"4 - Sair", {|| MsgInfo("Saindo do sistema...")}}
		}

		nOpcao := FWMenu("Controle de Estoque", aMenu)
	EndDo

Return
	EndFunc

Static Function CadastrarProduto()
	Local cCodigo := Space(10)
	Local cDescricao := Space(50)
	Local nPreco := 0.0
	Local nEstoque := 0

	cCodigo := FWInput("Código do Produto:", cCodigo)
	cDescricao := FWInput("Descrição do Produto:", cDescricao)
	nPreco := Val(FWInput("Preço do Produto:", Str(nPreco, 10, 2)))
	nEstoque := Val(FWInput("Quantidade em Estoque:", Str(nEstoque, 10)))

	DbUseArea(.T., "TOPCONN", "SB1", "SB1", .T., .T.)
	DbAppend()
	FIELD->B1_COD := cCodigo
	FIELD->B1_DESC := cDescricao
	FIELD->B1_PRV1 := nPreco
	FIELD->B1_ESTQ := nEstoque
	DbCommit()
	DbCloseArea()

	MsgInfo("Produto cadastrado com sucesso!")
Return

Static Function RegistrarMovimentacao()
	Local cCodigo := Space(10)
	Local nQuantidade := 0
	Local cTipoMov := Space(1)

	cCodigo := FWInput("Código do Produto:", cCodigo)
	nQuantidade := Val(FWInput("Quantidade:", Str(nQuantidade, 10)))
	cTipoMov := FWInput("Tipo de Movimentação (E - Entrada / S - Saída):", cTipoMov)

	DbUseArea(.T., "TOPCONN", "SB1", "SB1", .T., .T.)
	DbSeek(cCodigo)

	If Found()
		If Upper(cTipoMov) == "E"
			FIELD->B1_ESTQ += nQuantidade
		ElseIf Upper(cTipoMov) == "S"
			FIELD->B1_ESTQ -= nQuantidade
		Else
			MsgStop("Tipo de movimentação inválido!")
			DbCloseArea()
			Return
		EndIf

		DbCommit()
		MsgInfo("Movimentação registrada com sucesso!")
	Else
		MsgStop("Produto não encontrado!")
	EndIf

	DbCloseArea()
Return

Static Function GerarRelatorio()
    Local cRelatorio := ""
    Local nTotalProdutos := 0

    DbUseArea(.T., "TOPCONN", "SB1", "SB1", .T., .T.)
    DbGoTop()

    cRelatorio += "Código    Descrição                          Preço      Estoque" + CRLF
    cRelatorio += Replicate("-", 60) + CRLF

    While !Eof()
        cRelatorio += PadR(FIELD->B1_COD, 10) + " " + ;
                        adR(FIELD->B1_DESC, 30) + " " + ;
                        PadL(Str(FIELD->B1_PRV1, 10, 2), 10) + " " + ;
                        PadL(Str(FIELD->B1_ESTQ, 10), 10) + CRLF
        nTotalProdutos++
        DbSkip()
    EndDo

    DbCloseArea()

    cRelatorio += Replicate("-", 60) + CRLF
    cRelatorio += "Total de Produtos: " + Str(nTotalProdutos, 10) + CRLF

    MemoEdit(cRelatorio, "Relatório de Produtos")
Return

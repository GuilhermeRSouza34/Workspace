//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RwMake.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} zAltVen
Função para alterar os vendedores e comissões de pedidos (inclusive com notas geradas)
@author Atilio
@since 25/11/2018
@version 1.0
@type function
@obs Função altera apenas os pedidos já faturados
	Antes de rodar a rotina, valide em base de testes, e veja se a lógica de negócio se aplica a sua necessidade
/*/

User Function zAltVen()
	Local aArea     := GetArea()
	Local oBrowse
	Local cFunBkp   := FunName()
	Private aRotina := {}
	
	SetFunName("zAltVen")
	
	//Instanciando FWMBrowse apontando para a SC5
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SC5")
	oBrowse:SetDescription("Pedido de Venda - Troca de Vendedores e Comissões")
	oBrowse:AddLegend("! ( !Empty(C5_NOTA) .Or. C5_LIBEROK=='E' .And. Empty(C5_BLQ) )",  "WHITE", "Outros Status")
	oBrowse:AddLegend("( !Empty(C5_NOTA) .Or. C5_LIBEROK=='E' .And. Empty(C5_BLQ) )",    "RED",   "Pedido Encerrado")
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	aRotina := {}
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'u_zSC5Vend' OPERATION MODEL_OPERATION_UPDATE   ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda' ACTION 'u_zSC5Leg'  OPERATION MODEL_OPERATION_VIEW     ACCESS 0
Return aRotina

/*/{Protheus.doc} zSC5Leg
Função para mostrar a legenda do Browse
@author Atilio
@since 25/11/2018
@version 1.0
@type function
/*/

User Function zSC5Leg()
	Local aLegenda := {}
	
	//Monta as cores
	aAdd(aLegenda,{"BR_BRANCO",   "Outros Status"})
	aAdd(aLegenda,{"BR_VERMELHO", "Pedido Encerrado"})
	
	//Mostra a tela
	BrwLegenda("Pedidos de Venda", "Status", aLegenda)
Return

/*/{Protheus.doc} zSC5Vend
Função que monta a tela para alterar o código dos vendedores e comissões
@author Atilio
@since 25/11/2018
@version 1.0
@type function
/*/

User Function zSC5Vend()
	//Variáveis de Controle
	Local cMaskVend   := PesqPict('SA3', 'A3_COD')
	Local cMaskNome   := PesqPict('SA3', 'A3_NOME')
	Local cMaskComi   := PesqPict('SC5', 'C5_COMIS1')
	Local cConsF3     := 'SA3'
	Local nLinha      := 0
	Local nCol01      := 005
	Local nCol02      := 050
	Local nCol03      := 310
	Local nEspPula    := 020
	//Componentes da Tela
	Private oDlgPvt
	Private oBtnGera
	Private oBtnFech
	//Tamanho da Janela
	Private	nJanLarg   := 700
	Private	nJanAltu   := 300
	//Fontes
	Private	cFontUti   := "Tahoma"
	Private	oFontAno   := TFont():New(cFontUti,,-38)
	Private	oFontSub   := TFont():New(cFontUti,,-20)
	Private	oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
	Private	oFontBtn   := TFont():New(cFontUti,,-14)
	Private	oFontGet   := TFont():New(cFontUti,,-12)
	Private	oFontGetN  := TFont():New(cFontUti,,-12,,.T.)
	//Gets - Vendedor 1
	Private oGetVend1, cGetVend1 := SC5->C5_VEND1
	Private oGetNome1, cGetNome1 := fNomeVend(SC5->C5_VEND1)
	Private oGetComi1, nGetComi1 := SC5->C5_COMIS1
	//Gets - Vendedor 2
	Private oGetVend2, cGetVend2 := SC5->C5_VEND2
	Private oGetNome2, cGetNome2 := fNomeVend(SC5->C5_VEND2)
	Private oGetComi2, nGetComi2 := SC5->C5_COMIS2
	//Gets - Vendedor 3
	Private oGetVend3, cGetVend3 := SC5->C5_VEND3
	Private oGetNome3, cGetNome3 := fNomeVend(SC5->C5_VEND3)
	Private oGetComi3, nGetComi3 := SC5->C5_COMIS3
	//Gets - Vendedor 4
	Private oGetVend4, cGetVend4  := SC5->C5_VEND4
	Private oGetNome4, cGetNome4 := fNomeVend(SC5->C5_VEND4)
	Private oGetComi4, nGetComi4 := SC5->C5_COMIS4
	//Gets - Vendedor 5
	Private oGetVend5, cGetVend5 := SC5->C5_VEND5
	Private oGetNome5, cGetNome5 := fNomeVend(SC5->C5_VEND5)
	Private oGetComi5, nGetComi5 := SC5->C5_COMIS5
	
	//Criação da tela
	DEFINE MSDIALOG oDlgPvt TITLE "Alteração do Pedido " + SC5->C5_NUM FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		
		//Labels gerais
		@ 004, 003 SAY "FAT"                    SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149, 179, 215) PIXEL
		@ 004, 050 SAY "Alteração de"           SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031, 073, 125) PIXEL
		@ 014, 050 SAY "Comissões e Vendedores" SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031, 073, 125) PIXEL
		
		//Botões
		@ 006, (nJanLarg/2-001)-(0067*02) BUTTON oBtnGera  PROMPT "Confirmar"     SIZE 065, 018 OF oDlgPvt ACTION (Processa({|| fGravar()}, "Processando..."))  FONT oFontBtn PIXEL
		@ 006, (nJanLarg/2-001)-(0067*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 065, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
		
		//Títulos dos Gets
		nLinha := 034
		@ nLinha, nCol01 SAY "Vendedor" OF oDlgPvt FONT oFontGetN PIXEL
		@ nLinha, nCol02 SAY "Nome"     OF oDlgPvt FONT oFontGetN PIXEL 
		@ nLinha, nCol03 SAY "Comissão" OF oDlgPvt FONT oFontGetN PIXEL
		nLinha += nEspPula - 5
		
		//Primeiro Vendedor
		@ nLinha, nCol01 MSGET oGetVend1 VAR cGetVend1 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskVend          VALID (fVldVend(1, cGetVend1)) F3 cConsF3 PIXEL
		@ nLinha, nCol02 MSGET oGetNome1 VAR cGetNome1 SIZE 250, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskNome READONLY                                           PIXEL
		@ nLinha, nCol03 MSGET oGetComi1 VAR nGetComi1 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskComi          VALID (Positivo())                        PIXEL
		nLinha += nEspPula
		
		//Segundo Vendedor
		@ nLinha, nCol01 MSGET oGetVend2 VAR cGetVend2 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskVend          VALID (fVldVend(2, cGetVend2)) F3 cConsF3 PIXEL
		@ nLinha, nCol02 MSGET oGetNome2 VAR cGetNome2 SIZE 250, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskNome READONLY                                           PIXEL
		@ nLinha, nCol03 MSGET oGetComi2 VAR nGetComi2 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskComi          VALID (Positivo())                        PIXEL
		nLinha += nEspPula
		
		//Terceiro Vendedor
		@ nLinha, nCol01 MSGET oGetVend3 VAR cGetVend3 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskVend          VALID (fVldVend(3, cGetVend3)) F3 cConsF3 PIXEL
		@ nLinha, nCol02 MSGET oGetNome3 VAR cGetNome3 SIZE 250, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskNome READONLY                                           PIXEL
		@ nLinha, nCol03 MSGET oGetComi3 VAR nGetComi3 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskComi          VALID (Positivo())                        PIXEL
		nLinha += nEspPula
		
		//Quarto Vendedor
		@ nLinha, nCol01 MSGET oGetVend4 VAR cGetVend4 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskVend          VALID (fVldVend(4, cGetVend4)) F3 cConsF3 PIXEL
		@ nLinha, nCol02 MSGET oGetNome4 VAR cGetNome4 SIZE 250, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskNome READONLY                                           PIXEL
		@ nLinha, nCol03 MSGET oGetComi4 VAR nGetComi4 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskComi          VALID (Positivo())                        PIXEL
		nLinha += nEspPula
		
		//Quinto Vendedor
		@ nLinha, nCol01 MSGET oGetVend5 VAR cGetVend5 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskVend          VALID (fVldVend(5, cGetVend5)) F3 cConsF3 PIXEL
		@ nLinha, nCol02 MSGET oGetNome5 VAR cGetNome5 SIZE 250, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskNome READONLY                                           PIXEL
		@ nLinha, nCol03 MSGET oGetComi5 VAR nGetComi5 SIZE 035, 015  OF oDlgPvt FONT oFontGet PICTURE cMaskComi          VALID (Positivo())                        PIXEL
			
	ACTIVATE MSDIALOG oDlgPvt CENTERED
Return

/*---------------------------------------------------------------------*
 | Func:  fNomeVend                                                    |
 | Desc:  Função que retorna o nome do vendedor                        |
 *---------------------------------------------------------------------*/

Static Function fNomeVend(cCodVend)
	Local aArea      := GetArea()
	Local cNome      := ""
	Default cCodVend := ""
	
	//Somente se existir código de vendedor
	If ! Empty(cCodVend)
		DbSelectArea('SA3')
		SA3->(DbSetOrder(1)) //Filial + Código
		
		//Se conseguir posicionar no vendedor, seta o nome que será retornado
		If SA3->(DbSeek(FWxFilial('SA3') + cCodVend))
			cNome := SA3->A3_NOME
		EndIf
	EndIf
	
	RestArea(aArea)
Return cNome

/*---------------------------------------------------------------------*
 | Func:  fVldVend                                                     |
 | Desc:  Função que valida o vendedor digitado                        |
 *---------------------------------------------------------------------*/

Static Function fVldVend(nVendedor, cCodigo)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cNomeAux  := ""
	Default cCodigo := ""
	
	//Se tiver o código em branco, zera o nome
	If Empty(cCodigo)
		cNomeAux := ""
		
	Else
		DbSelectArea('SA3')
		SA3->(DbSetOrder(1)) //Filial + Código
		
		//Se conseguir posicionar no vendedor, seta o nome
		If SA3->(DbSeek(FWxFilial('SA3') + cCodigo))
			cNomeAux := SA3->A3_NOME
			
		//Senão, mostra mensagem que não encontrou
		Else
			MsgStop("Vendedor '" + cCodigo + "' não foi encontrado!", "Atenção")
			lRet := .F.
		EndIf
	EndIf
	
	//Atualiza o nome do vendedor
	&("cGetNome" + cValToChar(nVendedor)) := cNomeAux
	&("oGetNome" + cValToChar(nVendedor) + ":Refresh()")
	
	RestArea(aArea)
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fGravar                                                      |
 | Desc:  Função para gravação dos dados                               |
 *---------------------------------------------------------------------*/

Static Function fGravar()
	Local aArea      := GetArea()
	Local aAreaSC5   := SC5->(GetArea())
	Local aAreaSF2   := SF2->(GetArea())
	Local aAreaSE1   := SE1->(GetArea())
	Local aAreaSE3   := SE3->(GetArea())
	Local nBaseOrig  := 0
	Local nPercV     := 0
	Local nNovaBase  := 0
	Local nNovaComis := 0
	Local cVends     := ""
	Local nVendAtu   := 0
	Local nRegE3     := 0
	Local lContinua  := .T.
	Local nComiTotal := nGetComi1 + nGetComi2 + nGetComi3 + nGetComi4 + nGetComi5
	Local cQuery     := ""
	Local nAtual     := 0
	Local nTotal     := 0
	Local aSE3Del    := {}
	Local nTamVend   := TamSX3('A3_COD')[1]
	
	//Se as somas das comissões não for 100%, não prosseguirá
	If nComiTotal != 100 .And. nComiTotal != 0
		MsgStop("Soma das Comissões não bate 100%, o total está dando " + cValToChar(nComiTotal) + "%!", "Atenção")
		lContinua := .F.
	EndIf
	
	If lContinua
	
		//Percorre os 5 vendedores
		For nVendAtu := 1 To 5
			//Se existir código de vendedor, porém não existir comissão
			If ! Empty( &("cGetVend" + cValToChar(nVendAtu)) ) .And. &( "nGetComi"+Alltrim(Str(nVendAtu)) ) == 0
				MsgStop("Vendedor " + cValToChar(nVendAtu) + " preenchido, mas a comissão não! Código: " + &("cGetVend" + cValToChar(nVendAtu)), "Atenção")
				lContinua := .F.
			EndIf
		Next
		
		If lContinua
			//Consulta para buscar dados das notas faturadas
			cQuery := " SELECT "                                                            + CRLF
			cQuery += "    D2_CLIENTE, "                                                    + CRLF
			cQuery += "    D2_LOJA, "                                                       + CRLF
			cQuery += "    D2_DOC, "                                                        + CRLF
			cQuery += "    D2_SERIE, "                                                      + CRLF
			cQuery += "    SUM(D2_QUANT * D2_PRCVEN) AS BASE_COM, "                         + CRLF
			cQuery += "    SUM((D2_QUANT * D2_PRCVEN) * D2_COMIS1 / 100) AS VALOR_COM "     + CRLF
			cQuery += " FROM "                                                              + CRLF
			cQuery += "    " + RetSqlName("SD2")+" SD2 "                                    + CRLF
			cQuery += " WHERE "                                                             + CRLF
			cQuery += "    D2_FILIAL = '" + FWxFilial("SD2") + "' "                         + CRLF
			cQuery += "    AND D2_PEDIDO = '" + SC5->C5_NUM + "'"                           + CRLF
			cQuery += "    AND SD2.D_E_L_E_T_ = ' ' "                                       + CRLF
			cQuery += " GROUP BY "                                                          + CRLF
			cQuery += "    D2_CLIENTE, "                                                    + CRLF
			cQuery += "    D2_LOJA, "                                                       + CRLF
			cQuery += "    D2_DOC, "                                                        + CRLF
			cQuery += "    D2_SERIE "                                                       + CRLF
			TCQuery cQuery New Alias "QRY_SD2"
			
			//Define o tamanho da régua
			Count To nTotal
			ProcRegua(nTotal)
			QRY_SD2->(DbGoTop())
			
			//Se não tiver dados, não irá prosseguir
			If QRY_SD2->(eof())
				MsgStop("Não existem dados de notas emitidas para esse Pedido!", "Atenção")
				lContinua := .F.
			EndIf
			
			If lContinua
				//Atualiza o Pedido de Venda
				RecLock("SC5", .F.)
					SC5->C5_VEND1  := cGetVend1
					SC5->C5_VEND2  := cGetVend2
					SC5->C5_VEND3  := cGetVend3
					SC5->C5_VEND4  := cGetVend4
					SC5->C5_VEND5  := cGetVend5    
					SC5->C5_COMIS1 := nGetComi1
					SC5->C5_COMIS2 := nGetComi2
					SC5->C5_COMIS3 := nGetComi3
					SC5->C5_COMIS4 := nGetComi4
					SC5->C5_COMIS5 := nGetComi5
				SC5->(MsUnlock())
				
				//Armazena todos os vendedores
				cVends := Alltrim(SC5->C5_VEND1) + Alltrim(SC5->C5_VEND2) + Alltrim(SC5->C5_VEND3) + Alltrim(SC5->C5_VEND4) + Alltrim(SC5->C5_VEND5)
				
				//Enquanto houver notas
				While ! QRY_SD2->(EoF())
					
					//Incrementa a régua de processamento
					nAtual++
					IncProc("Atualizando notas (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
					
					//Atualiza o Documento de Saída
					DbSelectArea("SF2")
					SF2->(DbSetOrder(2)) // Filial + Cliente + Loja + Numero + Serie Docto.
					If SF2->(DbSeek(FWxFilial("SF2") + QRY_SD2->(D2_CLIENTE + D2_LOJA + D2_DOC + D2_SERIE)))
						RecLock("SF2", .F.)
							SF2->F2_VEND1 := cGetVend1
							SF2->F2_VEND2 := cGetVend2
							SF2->F2_VEND3 := cGetVend3
							SF2->F2_VEND4 := cGetVend4
							SF2->F2_VEND5 := cGetVend5
						SF2->(MsUnlock())
					EndIf
					
					//Atualiza Títulos a Receber
					DbSelectArea("SE1")
					DbSetOrder(2) // Filial + Cliente + Loja + Prefixo + No. Titulo + Parcela + Tipo
					If SE1->(DbSeek(FWxFilial("SE1") + QRY_SD2->(D2_CLIENTE + D2_LOJA + D2_SERIE + D2_DOC) ))
					
						//Enquanto houver títulos e a for a mesma chave, atualiza os dados
						While ! SE1->(EOF()) .And. SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM == FWxFilial("SE1") + QRY_SD2->(D2_CLIENTE + D2_LOJA + D2_SERIE + D2_DOC)
							Reclock("SE1", .F.)
								SE1->E1_VEND1 := cGetVend1
								SE1->E1_VEND2 := cGetVend2
								SE1->E1_VEND3 := cGetVend3
								SE1->E1_VEND4 := cGetVend4
								SE1->E1_VEND5 := cGetVend5
							SE1->(MsUnlock())
							
							SE1->(DbSkip())
						endDo
					EndIf
					
					//Agora irá separar as comissões que serão excluídas
					DbSelectArea("SE3")
					SE3->(DbSetOrder(1)) // Filial + Prefixo + No. Titulo + Parcela + Sequencia + Vendedor
					If SE3->(DbSeek(FWxFilial("SE3") + QRY_SD2->(D2_SERIE + D2_DOC)))
						aSE3Del := {}
						
						//Enquanto houver comissões e for a mesma chave, adiciona no Array
						While ! SE3->(EoF()) .And. SE3->(E3_PREFIXO + E3_NUM) == QRY_SD2->(D2_SERIE + D2_DOC)
							aAdd(aSE3Del, SE3->(RecNo()))
							
							SE3->(DbSkip())
						EndDo
						
						//Percorre todos os Recnos
						For nRegE3 := 1 To Len(aSE3Del)
							//Posiciona no registro
							SE3->(DbGoto(aSE3Del[nRegE3]))
							
							//Deleta o registro
							RecLock("SE3", .F.)
								DbDelete()
							SE3->(MsUnlock())
						Next
					EndIf
					
					//Percorre os 5 vendedores, para gerar a comissão
					For nVendAtu := 1 To 5
					
						//Se estiver preenchido o código do vendedor
						If ! Empty( &("SC5->C5_VEND" + cValToChar(nVendAtu)) )
						
							//Se houver comissão, ou for apenas 1 único vendedor
							If &("SC5->C5_COMIS" + cValToChar(nVendAtu)) > 0 .Or. Len(cVends) == nTamVend
								
								//Pega a base original, valor e a % de comissão
								nBaseOrig  := QRY_SD2->BASE_COM
								nComisOrig := QRY_SD2->VALOR_COM
								nPercV     := &("SC5->C5_COMIS" + cValToChar(nVendAtu))
								
								//Se for 0, será 100% (um vendedor apenas)
								If nPercV == 0
									nPercV := 100
								EndIf
								
								//Se existir mais vendedores, proporcionaliza o valor
								If Len(cVends) != 6
									nNovaBase  := ( nBaseOrig  / 100 ) * nPercV
									nNovaComis := ( nComisOrig / 100 ) * nPercV
									
								//Senão, se for um único vendedor, a base a comissão, serão iguais ao original
								Else
									nNovaBase  := nBaseOrig
									nNovaComis := nComisOrig
								EndIf
								
								//Cria a comissão
								RecLock("SE3", .T.)
									SE3->E3_FILIAL   := FWxFilial("SE3")
									SE3->E3_VEND     := &("SC5->C5_VEND" + cValToChar(nVendAtu))
									SE3->E3_SERIE    := QRY_SD2->D2_SERIE
									SE3->E3_NUM	     := QRY_SD2->D2_DOC
									SE3->E3_CODCLI   := QRY_SD2->D2_CLIENTE
									SE3->E3_LOJA     := QRY_SD2->D2_LOJA
									SE3->E3_PREFIXO  := QRY_SD2->D2_SERIE
									SE3->E3_TIPO     := "NF"
									SE3->E3_EMISSAO  := SC5->C5_EMISSAO
									SE3->E3_VENCTO   := SC5->C5_EMISSAO
									SE3->E3_BAIEMI   := "E"
									SE3->E3_PEDIDO   := SC5->C5_NUM
									SE3->E3_BASE     := nNovaBase
									SE3->E3_COMIS    := nNovaComis
									SE3->E3_PORC     := (nNovaComis / nNovaBase ) * 100
								SE3->(MsUnlock())
							EndIf
						EndIf
					Next
					
					QRY_SD2->(dbSkip())
				EndDo
				
				MsgInfo("Dados dos Vendedores alterados do Pedido!", "Atenção")
				oDlgPvt:End()
			EndIf
			QRY_SD2->(dbCloseArea())

		EndIf
	EndIf
	
	RestArea(aAreaSE3)
	RestArea(aAreaSE1)
	RestArea(aAreaSF2)
	RestArea(aAreaSC5)
	RestArea(aArea)
Return

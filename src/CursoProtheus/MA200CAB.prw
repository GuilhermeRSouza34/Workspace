//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function MA200CAB
Função para adicionar mais botões no cadastro de Estruturas
@type  Function
@author Atilio
@since 25/09/2013 
@version version
/*/

User Function MA200CAB()
    Local aArea := GetArea()
    //Painel e botões novos
	Local oPanNovo
    Local oBtnNovo1
    Local oBtnNovo2
    Local oBtnNovo3
    Local oBtnNovo4
	//Pegando os parametros
	Local oObj     := PARAMIXB[3]
	Local cProduto := PARAMIXB[1]
    //Ações dos botões
    Local aDados := {}
	
	//Descricoes e acoes dos botoes
	aAdd(aDados, {"Estoq. Item",  "u_zM200Est(.F., '')"})
	aAdd(aDados, {"Estoq. Pai",   "u_zM200Est(.T., cProduto)"})
	aAdd(aDados, {"Botão Tst 3", "Alert('Botão 3')"})
	aAdd(aDados, {"Botão Tst 4", "Alert('Botão 4')"})
	
	//Diminuindo a largura do cabecaho
	oObj:nWidth := oObj:nWidth - 200
	
	//Criando o painel
	@ 000, 000 MSPANEL oPanNovo SIZE 080, 040 OF oObj
	
	//Botao 1
	@ 005, 005 BUTTON oBtnNovo1 PROMPT aDados[1][1] SIZE 030, 012 ACTION(&(aDados[1][2])) OF oPanNovo PIXEL
	
	//Botao 2
	@ 005, 040 BUTTON oBtnNovo2 PROMPT aDados[2][1] SIZE 030, 012 ACTION(&(aDados[2][2])) OF oPanNovo PIXEL
	
	//Botao 3
	@ 020, 005 BUTTON oBtnNovo3 PROMPT aDados[3][1] SIZE 030, 012 ACTION(&(aDados[3][2])) OF oPanNovo PIXEL
	
	//Botao 4
	@ 020, 040 BUTTON oBtnNovo4 PROMPT aDados[4][1] SIZE 030, 012 ACTION(&(aDados[4][2])) OF oPanNovo PIXEL
	
	//Alinhando o painel a direita do cabecalho
	oPanNovo:Align := CONTROL_ALIGN_RIGHT

    RestArea(aArea)
Return

/*/{Protheus.doc} User Function zM200Est
Função para visualizar o estoque (similar ao F4 na tela de Produtos)
@type  Function
@author Atilio
@since 25/09/2013 
@version version
/*/

User Function zM200Est(lPai, cCodPai)
	Local aAreaSG1	:= SG1->(GetArea())
	Local nRec 		:= Val(SubStr(oTree:GetCargo(), Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
	Local cProd		:= ""
	Default lPai    := .F.
	
	//Se tiver codigo no cargo é o pai
	If lPai
		cProd := cCodPai
	Else
		//Posicionando no Recno
		DbSelectArea('SG1')
		SG1->(DbSetOrder(1))
		SG1->(DbGoto(Iif(nRec > 0, nRec, aAreaSG1[3])))
	
		//Pegando o codigo do produto
		cProd := SG1->G1_COMP
	EndIf
	
	//Posiciona agora no cadastro de produtos
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1)) // Filial + Código
	If SB1->(DbSeek(FWxFilial('SB1') + cProd))
		MaViewSB2(SB1->B1_COD)
	EndIf
	
	RestArea(aAreaSG1)
Return

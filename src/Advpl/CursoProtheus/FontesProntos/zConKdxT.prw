#Include "totvs.ch"
#Include "Topconn.ch"
#include "FWMBrowse.ch"
#Include "FWMVCDEF.CH"
#Include "msobject.ch"

#Define EM_TERCEIRO 1
#Define DE_TERCEIRO 2 
#Define AMBOS 3
#Define ENTROU_NO_ESTOQUE 'E'
#Define SAIU_DO_ESTOQUE 'S'

Static cFilSA1  := FWxFilial('SA1')
Static cFilSB1  := FWxFilial('SB1')
Static cFilSD1  := FWxFilial('SD1')
Static cFilSD2  := FWxFilial('SD2')
Static cFilSF4  := FWxFilial('SF4')
Static cNameSD1 := RetSqlName('SD1')
Static cNameSD2 := RetSqlName('SD2')
Static cNameSF4 := RetSqlName('SF4')
Static cNameSA1 := RetSqlName('SA1')

/*/{Protheus.doc} zConKdxT
    Monta as consultas necessárias e aciona o painel para exibição do Kardex.
    @type  User Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 12/02/2022
    @example
       U_zConKdxT()    
/*/
User Function zConKdxT()

    Local aArea      := GetArea()
    Local oBrowse    := zPainelKrdxT():New()
    Local oCabecalho := JsonObject():New()
    Local aMovimentos:= {}
    Local cAliasTmp  := ''    
    Local nSaldoIni  := 0
    Local nSaldoFinal:= 0

    Private cProduto_   := SB1->B1_COD
    //Parametros do Pergunte
    Private cDoArmazem_ := MV_PAR01
    Private cAtArmazem_ := MV_PAR02
    Private dDaData_    := MV_PAR03
    Private dAtData_    := MV_PAR04
    Private nTipoOp_    := MV_PAR05

    nSaldoIni:= fGetSaldoInicial()
    cAliasTMP:= fConsulta()

    fBuildMovimentos(cAliasTmp, nSaldoIni, @nSaldoFinal, @aMovimentos)
    fBuildCabecalho(@oCabecalho, nSaldoIni, nSaldoFinal)
    
    oBrowse:SetInformacoesGerais(@oCabecalho)
    oBrowse:SetMovimentos(@aMovimentos)
    oBrowse:OpenWindow()

    (cAliasTmp)->(DbCloseArea())
    FreeObj( oBrowse )
    RestArea(aArea)
Return

/*/{Protheus.doc} fConsulta
    Monta a consulta principal do Kardex com as movimentações, de acordo com as respostas do Pergunte
    @type  Static Function
    @return cAliasTMP, Character, nome do alias (ResultSet) da consulta
/*/
Static Function fConsulta()
    
    Local aArea    := GetArea()
    Local cQuery   := ""
    Local cAliasTMP:= 'zConKdxT_'+FwTimeStamp(1)
   
    If nTipoOp_ == EM_TERCEIRO .Or. nTipoOp_ == AMBOS

        cQuery += " SELECT 'EM TERCEIRO' AS TIPO,"
        cQuery += "        '[Envio] Produto em Terceiro' AS OPERACAO, "
        cQuery += "     	D2_DOC+' - '+D2_SERIE AS DOCUMENTO, "
        cQuery += "     	D2_CLIENTE+' - '+D2_LOJA+' - '+A1_NOME AS EMPRESA, "
        cQuery += "     	D2_COD AS PRODUTO, "
        cQuery += "     	D2_QUANT AS QUANTIDADE, "
        cQuery += "     	D2_NFORI +' - '+ D2_SERIORI AS ORIGEM, "
        cQuery += "     	D2_LOCAL AS ARMAZEM, "
        cQuery += "     	D2_EMISSAO AS DT_EMISSAO, "
        cQuery += "     	'S' AS MOVIMENTO "
        cQuery += " FROM "+cNameSD2+" AS SD2 "
        cQuery += " INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D2_TES "
        cQuery += " INNER JOIN "+cNameSA1+" AS SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA "
        cQuery += " WHERE D2_FILIAL = '"+cFilSD1+"' AND F4_FILIAL = '"+cFilSF4+"' AND A1_FILIAL = '"+cFilSA1+"' "
        cQuery += "       AND F4_PODER3  = 'R' " 
        cQuery += "       AND F4_ESTOQUE = 'S' " 
        cQuery += "       AND D2_EMISSAO BETWEEN '"+dTos(dDaData_)+"' AND '"+dTos(dAtData_)+"' "
        cQuery += "       AND D2_LOCAL   BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' " 
        cQuery += "       AND D2_COD = '"+cProduto_+"' " 
        cQuery += "       AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "
        cQuery += " UNION ALL "
        cQuery += " SELECT 'EM TERCEIRO' AS TIPO, "
        cQuery += "        '[Devolução] Produto em Terceiro' AS OPERACAO, "
        cQuery += "     	D1_DOC+' - '+D1_SERIE AS DOCUMENTO, "
        cQuery += "     	D1_FORNECE+' - '+D1_LOJA+' - '+A1_NOME AS EMPRESA, "
        cQuery += "     	D1_COD AS PRODUTO, "
        cQuery += "     	D1_QUANT AS QUANTIDADE, "
        cQuery += "     	D1_NFORI +' - '+ D1_SERIORI AS ORIGEM, "
        cQuery += "     	D1_LOCAL AS ARMAZEM, "
        cQuery += "     	D1_EMISSAO AS DT_EMISSAO, "
        cQuery += "     	'E' AS MOVIMENTO "
        cQuery += " FROM "+cNameSD1+" AS SD1 "
        cQuery += " INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D1_TES "
        cQuery += " INNER JOIN "+cNameSA1+" AS SA1 ON A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA "  
        cQuery += " WHERE D1_FILIAL = '"+cFilSD1+"' AND F4_FILIAL = '"+cFilSF4+"' AND A1_FILIAL = '"+cFilSA1+"' "
        cQuery += "       AND F4_PODER3  = 'D' "	
        cQuery += "       AND F4_ESTOQUE = 'S' "    
        cQuery += "       AND D1_COD     = '"+cProduto_+"' " 
        cQuery += "       AND D1_EMISSAO BETWEEN '"+dTos(dDaData_)+"' AND '"+dTos(dAtData_)+"' "
        cQuery += "       AND D1_LOCAL   BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' " 
        cQuery += "       AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "
    EndIf
    
    If nTipoOp_ == AMBOS
        cQuery += " UNION ALL "    
    EndIf

    If nTipoOp_ == DE_TERCEIRO .Or. nTipoOp_ == AMBOS

        cQuery += " SELECT 'DE TERCEIRO' AS TIPO, "
        cQuery += "        '[Devolução] Produto de Terceiro' AS OPERACAO, "
        cQuery += "     	D1_DOC+' - '+D1_SERIE AS DOCUMENTO, "
        cQuery += "     	D1_FORNECE+' - '+D1_LOJA+' - '+A1_NOME AS EMPRESA, "
        cQuery += "     	D1_COD AS PRODUTO, "
        cQuery += "     	D1_QUANT AS QUANTIDADE, "
        cQuery += "     	D1_NFORI +' - '+ D1_SERIORI AS ORIGEM, "
        cQuery += "     	D1_LOCAL AS ARMAZEM, "
        cQuery += "     	D1_EMISSAO AS DT_EMISSAO, "
        cQuery += "     	'E' AS MOVIMENTO "
        cQuery += " FROM "+cNameSD1+" AS SD1 "
        cQuery += " INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D1_TES "
        cQuery += " INNER JOIN "+cNameSA1+" AS SA1 ON A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA "  
        cQuery += " WHERE D1_FILIAL = '"+cFilSD1+"' AND F4_FILIAL = '"+cFilSF4+"' AND A1_FILIAL = '"+cFilSA1+"' "
        cQuery += "       AND F4_PODER3  = 'R' "	
        cQuery += "       AND F4_ESTOQUE = 'S' "    
        cQuery += "       AND D1_COD     = '"+cProduto_+"' " 
        cQuery += "       AND D1_EMISSAO BETWEEN '"+dTos(dDaData_)+"' AND '"+dTos(dAtData_)+"' "
        cQuery += "       AND D1_LOCAL   BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' " 
        cQuery += "       AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "
        cQuery += " UNION ALL "
        cQuery += " SELECT 'DE TERCEIRO' AS TIPO,"
        cQuery += "        '[Envio] Produto de Terceiro' AS OPERACAO, "
        cQuery += "     	D2_DOC+' - '+D2_SERIE AS DOCUMENTO, "
        cQuery += "     	D2_CLIENTE+' - '+D2_LOJA+' - '+A1_NOME AS EMPRESA, "
        cQuery += "     	D2_COD AS PRODUTO, "
        cQuery += "     	D2_QUANT AS QUANTIDADE, "
        cQuery += "     	D2_NFORI +' - '+ D2_SERIORI AS ORIGEM, "
        cQuery += "     	D2_LOCAL AS ARMAZEM, "
        cQuery += "     	D2_EMISSAO AS DT_EMISSAO, "
        cQuery += "     	'S' AS MOVIMENTO "
        cQuery += " FROM "+cNameSD2+" AS SD2 "
        cQuery += " INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D2_TES "
        cQuery += " INNER JOIN "+cNameSA1+" AS SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA  "
        cQuery += " WHERE D2_FILIAL = '"+cFilSD1+"' AND F4_FILIAL = '"+cFilSF4+"' AND A1_FILIAL = '"+cFilSA1+"' "
        cQuery += "       AND F4_PODER3  = 'D' " 
        cQuery += "       AND F4_ESTOQUE = 'S' " 
        cQuery += "       AND D2_EMISSAO BETWEEN '"+dTos(dDaData_)+"' AND '"+dTos(dAtData_)+"' "
        cQuery += "       AND D2_LOCAL   BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' " 
        cQuery += "       AND D2_COD = '"+cProduto_+"' " 
        cQuery += "       AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "
    EndIf
    cQuery += " ORDER BY DT_EMISSAO "

    cQuery:= ChangeQuery(cQuery)	
    VarInfo('[zConKdxT][fConsulta] QUERY -',cQuery)
    TcQuery cQuery New Alias (cAliasTMP)
    
    TcSetField( cAliasTMP, 'DT_EMISSAO', 'D' )

    RestArea(aArea)
Return cAliasTMP

/*/{Protheus.doc} fGetSaldoInicial
    Obtém o saldo inicial do dia atual.
    @type  Static Function
    @author Súlivan
    @since 13/02/2022
    
    @param param_name, param_type, param_descr
    @return nSaldo, Numeric, saldo inicial do produto    
/*/
Static Function fGetSaldoInicial()
    
    Local cQuery:= ""

    //Em Terceiro & De Terceiro (independente da operação o saldo é SD1 - SD2)  
    cQuery+=" SELECT ISNULL(( SELECT SUM(D1_QUANT)	FROM "+cNameSD1+" AS SD1"
    cQuery+="                        INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D1_TES "
    cQuery+="                        INNER JOIN "+cNameSA1+" AS SA1 ON A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA "
    cQuery+="                        WHERE D1_FILIAL  = '"+cFilSD1+"' AND F4_FILIAL = '"+cFilSF4+"' AND A1_FILIAL = '"+cFilSA1+"'"
    cQuery+="                          AND ( F4_PODER3 = 'D' OR F4_PODER3 = 'R' )"
    cQuery+="                          AND D1_COD     = '"+cProduto_+"' "
    cQuery+="                          AND D1_LOCAL   BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' " 		 
    cQuery+="                          AND D1_EMISSAO < '"+dToS(dDaData_)+"' "
    cQuery+="                          AND F4_ESTOQUE = 'S' "    
    cQuery+="                          AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' 
    cQuery+="                ) - ( SELECT SUM(D2_QUANT) FROM "+cNameSD2+" AS SD2"
    cQuery+="                      INNER JOIN "+cNameSF4+" AS SF4 ON F4_CODIGO = D2_TES "
    cQuery+="                      INNER JOIN "+cNameSA1+" AS SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA  "
    cQuery+="                      WHERE D2_FILIAL  = '"+cFilSD2+"' AND F4_FILIAL = '"+cFilSF4+"' AND A1_FILIAL = '"+cFilSA1+"'"
    cQuery+="                        AND ( F4_PODER3 = 'R' OR F4_PODER3  = 'D' )"
    cQuery+="                        AND D2_COD     = '"+cProduto_+"' " 
    cQuery+="                        AND D2_EMISSAO < '"+dToS(dDaData_)+"' "
    cQuery+="                        AND D2_LOCAL   BETWEEN '"+cDoArmazem_+"' AND '"+cAtArmazem_+"' " 
    cQuery+="                        AND F4_ESTOQUE = 'S' " 
    cQuery+="                        AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = ''),0) AS SALDO "

    VarInfo('[zConKdxT][fGetSaldoInicial] QUERY -',cQuery)

Return MpSysExecScalar(cQuery,"SALDO") 


/*/{Protheus.doc} fBuildMovimentos
    Monta o array aMovimentos com as movimentações do Kardex.
    Esturtura do array: 
    			aDados
					[01] - Data da movimentação
					[02] - Documento (NF-e + Série) do movimento
					[03] - Observação do movimento
					[04] - Quantiade movimentada
    @type  Static Function
    @author Súlivan
    @since 13/02/2022    
    @param cAliasTmp, Character, alias da consulta principal
    @param nSaldoIni, Numeric, saldo inicial do produto
    @param nSaldoFinal, Numeric, referencia do saldo final que será obtido aqui
    @param aMovimentos, Array, referencia do array que conterá os movimentos
/*/
Static Function fBuildMovimentos(cAliasTmp, nSaldoIni, nSaldoFinal, aMovimentos)
    
    Local cDiaAnt    := ''
    Local nSaldoDia  := nSaldoIni
    
    aAdd(aMovimentos,{ 'Saldo inicial', '', '', nSaldoIni })

    cDiaAnt:= (cAliasTmp)->DT_EMISSAO

    (cAliasTmp)->(DbGoTop())
    While !(cAliasTmp)->(Eof())

        //Saldo diario
        If cDiaAnt != (cAliasTmp)->DT_EMISSAO
            aAdd(aMovimentos, { 'Saldo', '', '', nSaldoDia})    
        Endif

        //Movimentações
        aAdd(aMovimentos, { (cAliasTmp)->DT_EMISSAO ,;
                            (cAliasTmp)->DOCUMENTO  ,;
                            Alltrim((cAliasTmp)->OPERACAO) + Iif(!Empty(Alltrim(StrTran((cAliasTmp)->ORIGEM,'-',''))), ' - (Documento origem: '+Alltrim((cAliasTmp)->ORIGEM)+') ','') ,;
                            (cAliasTmp)->QUANTIDADE })
        
        //Calcula os saldos
        If (cAliasTmp)->MOVIMENTO == ENTROU_NO_ESTOQUE
            nSaldoDia += (cAliasTmp)->QUANTIDADE
        Else
            nSaldoDia -= (cAliasTmp)->QUANTIDADE
        Endif

        (cAliasTmp)->(DbSkip())
    Enddo   
    nSaldoFinal :=  nSaldoDia   
    aAdd(aMovimentos, { 'Saldo final', '', '', nSaldoFinal })
Return

/*/{Protheus.doc} fBuildCabecalho
    Monta o objeto que  contém os dados que comporão 'Informações gerais'
    @type  Static Function
    @author Súlivan
    @since 20/02/2022    
    @param oCabecalho, Object, referencia do objeto que comporá as 'Informações gerais'
    @param nSaldoIni, Numeric, saldo inicial 
    @param nSaldoIni, Numeric, saldo final 
/*/
Static Function fBuildCabecalho(oCabecalho, nSaldoIni, nSaldoFinal)
    
    Local aTipos     := {"Em Terceiro",'De Terceiro','Ambos'}

    oCabecalho['PRODUTO']       := Alltrim(cProduto_) +' - '+ SB1->B1_DESC
    oCabecalho['UNIDADE_MEDIDA']:= SB1->B1_UM
    oCabecalho['SALDO_INICIAL'] := cValToChar(nSaldoIni)
    oCabecalho['SALDO_FINAL']   := cValToChar(nSaldoFinal)
    oCabecalho['ARMAZEM']       := cDoArmazem_ +' a '+cAtArmazem_
    oCabecalho['PERIODO']       := dToc(dDaData_) +' a '+ dToc(dAtData_)
    oCabecalho['TIPO_OPERACAO']  := aTipos[nTipoOp_]

Return

#Include "TOTVS.ch"
#Include "RESTFUL.ch"
#Include "JSON.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsultaEstoqueAPI
API REST para Consulta de Estoque
@author Guilherme Souza
@since 24/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------

WSRESTFUL ConsultaEstoque DESCRIPTION "API para Consulta de Estoque"

    WSDATA codigoProduto    AS STRING OPTIONAL
    WSDATA descricaoProduto AS STRING OPTIONAL
    WSDATA categoria        AS STRING OPTIONAL
    WSDATA local           AS STRING OPTIONAL
    WSDATA somenteComSaldo AS STRING OPTIONAL
    WSDATA codigo          AS STRING OPTIONAL

    WSMETHOD GET consulta-estoque;
        DESCRIPTION "Consulta produtos no estoque com filtros";
        WSSYNTAX "/rest/consulta-estoque" ;
        PATH "/rest/consulta-estoque"

    WSMETHOD GET locais-estoque;
        DESCRIPTION "Retorna lista de locais de estoque";
        WSSYNTAX "/rest/locais-estoque" ;
        PATH "/rest/locais-estoque"

    WSMETHOD GET categorias-estoque;
        DESCRIPTION "Retorna lista de categorias de produtos";
        WSSYNTAX "/rest/categorias-estoque" ;
        PATH "/rest/categorias-estoque"

    WSMETHOD GET produto-estoque;
        DESCRIPTION "Retorna produto específico por código";
        WSSYNTAX "/rest/produto-estoque/{codigo}" ;
        PATH "/rest/produto-estoque/{codigo}"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET consulta-estoque
Método para consultar produtos no estoque
@author Guilherme Souza
@since 24/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET consulta-estoque WSRECEIVE codigoProduto, descricaoProduto, categoria, local, somenteComSaldo WSREST ConsultaEstoque

    Local cQuery        := ""
    Local cAlias        := GetNextAlias()
    Local aRetorno      := {}
    Local oJson         := JsonObject():New()
    Local lSomenteComSaldo := .F.

    // Habilita CORS
    ::SetHeader("Access-Control-Allow-Origin", "*")
    ::SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    ::SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, Accept")

    // Converte parâmetro somenteComSaldo
    If !Empty(::somenteComSaldo)
        lSomenteComSaldo := (Upper(::somenteComSaldo) == "TRUE")
    EndIf

    // Monta query com JOIN entre SB1 (Produtos) e SB2 (Saldos)
    cQuery := "SELECT "
    cQuery += "    B1_COD AS CODIGO, "
    cQuery += "    B1_DESC AS DESCRICAO, "
    cQuery += "    B1_GRUPO AS CATEGORIA, "
    cQuery += "    B1_UM AS UNIDADE, "
    cQuery += "    B2_LOCAL AS LOCAL, "
    cQuery += "    COALESCE(B2_QATU, 0) AS SALDO_ATUAL, "
    cQuery += "    COALESCE(B2_QATU - B2_RESERVA, 0) AS SALDO_DISPONIVEL, "
    cQuery += "    COALESCE(B2_RESERVA, 0) AS SALDO_RESERVADO, "
    cQuery += "    COALESCE(B2_CM1, 0) AS CUSTO_MEDIO, "
    cQuery += "    COALESCE(B1_PRV1, 0) AS PRECO_VENDA, "
    cQuery += "    COALESCE(B2_DTULTIN, '') AS ULTIMA_MOVIMENTACAO, "
    cQuery += "    B1_MSBLQL AS BLOQUEADO "
    cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
    cQuery += "LEFT JOIN " + RetSqlName("SB2") + " SB2 ON "
    cQuery += "    B1_COD = B2_COD AND "
    cQuery += "    SB2.D_E_L_E_T_ = '' "
    cQuery += "WHERE SB1.D_E_L_E_T_ = '' "

    // Aplica filtros
    If !Empty(::codigoProduto)
        cQuery += " AND B1_COD LIKE '%" + Upper(AllTrim(::codigoProduto)) + "%' "
    EndIf

    If !Empty(::descricaoProduto)
        cQuery += " AND UPPER(B1_DESC) LIKE '%" + Upper(AllTrim(::descricaoProduto)) + "%' "
    EndIf

    If !Empty(::categoria)
        cQuery += " AND B1_GRUPO = '" + Upper(AllTrim(::categoria)) + "' "
    EndIf

    If !Empty(::local)
        cQuery += " AND B2_LOCAL = '" + Upper(AllTrim(::local)) + "' "
    EndIf

    If lSomenteComSaldo
        cQuery += " AND COALESCE(B2_QATU, 0) > 0 "
    EndIf

    cQuery += " ORDER BY B1_COD, B2_LOCAL "

    // Executa query
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    // Processa resultados
    While !(cAlias)->(EOF())
        aAdd(aRetorno, {;
            "codigo"              , AllTrim((cAlias)->CODIGO),;
            "descricao"           , AllTrim((cAlias)->DESCRICAO),;
            "categoria"           , AllTrim((cAlias)->CATEGORIA),;
            "unidade"             , AllTrim((cAlias)->UNIDADE),;
            "local"               , AllTrim((cAlias)->LOCAL),;
            "saldoAtual"          , (cAlias)->SALDO_ATUAL,;
            "saldoDisponivel"     , (cAlias)->SALDO_DISPONIVEL,;
            "saldoReservado"      , (cAlias)->SALDO_RESERVADO,;
            "custoMedio"          , (cAlias)->CUSTO_MEDIO,;
            "precoVenda"          , (cAlias)->PRECO_VENDA,;
            "ultimaMovimentacao"  , IIF(Empty((cAlias)->ULTIMA_MOVIMENTACAO), "", StoD((cAlias)->ULTIMA_MOVIMENTACAO)),;
            "ativo"               , (cAlias)->BLOQUEADO != "1";
        })
        (cAlias)->(dbSkip())
    End

    (cAlias)->(dbCloseArea())

    // Retorna JSON
    ::SetContentType("application/json")
    ::SetResponse(FWJsonSerialize(aRetorno, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET locais-estoque
Método para retornar locais de estoque
@author Guilherme Souza
@since 24/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET locais-estoque WSREST ConsultaEstoque

    Local cQuery    := ""
    Local cAlias    := GetNextAlias()
    Local aRetorno  := {}

    // Habilita CORS
    ::SetHeader("Access-Control-Allow-Origin", "*")
    ::SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    ::SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, Accept")

    // Busca locais únicos
    cQuery := "SELECT DISTINCT "
    cQuery += "    B2_LOCAL AS CODIGO, "
    cQuery += "    NNR_DESCRI AS DESCRICAO "
    cQuery += "FROM " + RetSqlName("SB2") + " SB2 "
    cQuery += "LEFT JOIN " + RetSqlName("NNR") + " NNR ON "
    cQuery += "    B2_LOCAL = NNR_CODIGO AND "
    cQuery += "    NNR.D_E_L_E_T_ = '' "
    cQuery += "WHERE SB2.D_E_L_E_T_ = '' "
    cQuery += " AND B2_LOCAL <> '' "
    cQuery += "ORDER BY B2_LOCAL "

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    While !(cAlias)->(EOF())
        aAdd(aRetorno, {;
            "codigo"   , AllTrim((cAlias)->CODIGO),;
            "descricao", IIF(Empty((cAlias)->DESCRICAO), AllTrim((cAlias)->CODIGO), AllTrim((cAlias)->DESCRICAO));
        })
        (cAlias)->(dbSkip())
    End

    (cAlias)->(dbCloseArea())

    ::SetContentType("application/json")
    ::SetResponse(FWJsonSerialize(aRetorno, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET categorias-estoque
Método para retornar categorias de produtos
@author Guilherme Souza
@since 24/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET categorias-estoque WSREST ConsultaEstoque

    Local cQuery    := ""
    Local cAlias    := GetNextAlias()
    Local aRetorno  := {}

    // Habilita CORS
    ::SetHeader("Access-Control-Allow-Origin", "*")
    ::SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    ::SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, Accept")

    // Busca grupos de produtos
    cQuery := "SELECT "
    cQuery += "    BM_GRUPO AS CODIGO, "
    cQuery += "    BM_DESC AS DESCRICAO "
    cQuery += "FROM " + RetSqlName("SBM") + " SBM "
    cQuery += "WHERE SBM.D_E_L_E_T_ = '' "
    cQuery += "ORDER BY BM_GRUPO "

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    While !(cAlias)->(EOF())
        aAdd(aRetorno, {;
            "codigo"   , AllTrim((cAlias)->CODIGO),;
            "descricao", AllTrim((cAlias)->DESCRICAO);
        })
        (cAlias)->(dbSkip())
    End

    (cAlias)->(dbCloseArea())

    ::SetContentType("application/json")
    ::SetResponse(FWJsonSerialize(aRetorno, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET produto-estoque
Método para retornar produto específico por código
@author Guilherme Souza
@since 24/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET produto-estoque WSRECEIVE codigo WSREST ConsultaEstoque

    Local cQuery    := ""
    Local cAlias    := GetNextAlias()
    Local aRetorno  := {}

    // Habilita CORS
    ::SetHeader("Access-Control-Allow-Origin", "*")
    ::SetHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    ::SetHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, Accept")

    If Empty(::aUrlParms) .Or. Len(::aUrlParms) == 0 .Or. Empty(::aUrlParms[1])
        ::SetResponse('{"erro": "Código do produto não informado"}')
        ::SetStatusCode(400)
        Return .F.
    EndIf

    // Busca produto específico
    cQuery := "SELECT "
    cQuery += "    B1_COD AS CODIGO, "
    cQuery += "    B1_DESC AS DESCRICAO, "
    cQuery += "    B1_GRUPO AS CATEGORIA, "
    cQuery += "    B1_UM AS UNIDADE, "
    cQuery += "    B2_LOCAL AS LOCAL, "
    cQuery += "    COALESCE(B2_QATU, 0) AS SALDO_ATUAL, "
    cQuery += "    COALESCE(B2_QATU - B2_RESERVA, 0) AS SALDO_DISPONIVEL, "
    cQuery += "    COALESCE(B2_RESERVA, 0) AS SALDO_RESERVADO, "
    cQuery += "    COALESCE(B2_CM1, 0) AS CUSTO_MEDIO, "
    cQuery += "    COALESCE(B1_PRV1, 0) AS PRECO_VENDA, "
    cQuery += "    COALESCE(B2_DTULTIN, '') AS ULTIMA_MOVIMENTACAO, "
    cQuery += "    B1_MSBLQL AS BLOQUEADO "
    cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
    cQuery += "LEFT JOIN " + RetSqlName("SB2") + " SB2 ON "
    cQuery += "    B1_COD = B2_COD AND "
    cQuery += "    SB2.D_E_L_E_T_ = '' "
    cQuery += "WHERE SB1.D_E_L_E_T_ = '' "
    cQuery += " AND B1_COD = '" + Upper(AllTrim(::aUrlParms[1])) + "' "
    cQuery += "ORDER BY B2_LOCAL "

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    If (cAlias)->(EOF())
        ::SetResponse('{"erro": "Produto não encontrado"}')
        ::SetStatusCode(404)
        (cAlias)->(dbCloseArea())
        Return .F.
    EndIf

    // Monta retorno do primeiro registro (dados do produto)
    aRetorno := {;
        "codigo"              , AllTrim((cAlias)->CODIGO),;
        "descricao"           , AllTrim((cAlias)->DESCRICAO),;
        "categoria"           , AllTrim((cAlias)->CATEGORIA),;
        "unidade"             , AllTrim((cAlias)->UNIDADE),;
        "local"               , AllTrim((cAlias)->LOCAL),;
        "saldoAtual"          , (cAlias)->SALDO_ATUAL,;
        "saldoDisponivel"     , (cAlias)->SALDO_DISPONIVEL,;
        "saldoReservado"      , (cAlias)->SALDO_RESERVADO,;
        "custoMedio"          , (cAlias)->CUSTO_MEDIO,;
        "precoVenda"          , (cAlias)->PRECO_VENDA,;
        "ultimaMovimentacao"  , IIF(Empty((cAlias)->ULTIMA_MOVIMENTACAO), "", StoD((cAlias)->ULTIMA_MOVIMENTACAO)),;
        "ativo"               , (cAlias)->BLOQUEADO != "1";
    }

    (cAlias)->(dbCloseArea())

    ::SetContentType("application/json")
    ::SetResponse(FWJsonSerialize(aRetorno, .F., .F., .T.))

Return .T.

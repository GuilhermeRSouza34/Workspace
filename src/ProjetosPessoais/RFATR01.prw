#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.ch"

#DEFINE ENTER CHR(13)+CHR(10)

User Function RFATR01()
    Local oExcel
    Local cArquivo  := GetTempPath() + "RFATR01.xml"
    Local aProdutos := {}
    Local Nx        := 0

    MontQry(@aProdutos, @aPedidos)

    oFWMsExcel := FWMsExcel():New()
    oFWMsExcel:AddWorkSheet("Produtos")
        oFWMsExcel:AddTable("Produtos","Produtos")
        oFWMsExcel:AddColumn("Produtos","Produtos","Codigo",1,1)
        oFWMsExcel:AddColumn("Produtos","Produtos","Descricao",1,1)
        oFWMsExcel:AddColumn("Produtos","Produtos","Armazem Principal",1,1)

        For nX := 1 To Len(aProdutos)
            oFWMsExcel():AddRow("Produtos","Produtos",{aProdutos[nX,1],aProdutos[nX,2],aProdutos[nX,3]})
        Next

    nX := 0
    oFWMsExcel():AddWorkSheet("ProdutosVSPedidosCompra")
        oFWMsExcel:AddTable("ProdutosVSPedidosCompra","Produtos")
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Codigo",1,1)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Descricao",1,1)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Armazem Principal",1,1)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Numero do pedido de compra",1,1)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Item do Pedido",1,1)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Data de Emissão",1,4)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Código do Fornecedor",1,1)
        oFWMsExcel:AddColumn("ProdutosVSPedidosCompra","Produtos","Razão social",1,1)

        for nX := 1 to Len(aPedidos)
            oFWMsExcel():AddRow("ProdutosVSPedidosCompra","Produtos",{aPedidos[nX,1],aPedidos[nX,2],aPedidos[nX,3],aPedidos[nX,4],aPedidos[nX,5],aPedidos[nX,6],aPedidos[nX,7],aPedidos[nX,8]})
        Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)

    oExcel := MsExcel():New()
    oExcel:Workbooks:Open(cArquivo)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

Return

Static Function MontaQry(aProdutos, aPedidos)
    Local cQuery := ""

    cQuery += "SELECT DISTINCT           " + ENTER
    cQuery += "B1_COD AS CODIGO,         " + ENTER
    cQuery += "B1_DESC AS DESCRICAO,     " + ENTER
    cQuery += "B1_LOCPAD AS LOCPAD      " + ENTER
    cQuery += "FROM " + retsqlname("SB1") + " B1(NOLOCK)    " + ENTER
    cQuery += "INNER JOIN " + retsqlname("SC7") + " C7(NOLOCK) ON B1_COD = C7_PRODUTO AND C7.D_E_L_E_T_ = '' " + ENTER
    cQuery += "INNER JOIN " + retsqlname("SA2") + " A2(NOLOCK) ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND A2.D_E_L_E_T_ = '' " + ENTER
    cQuery += "WHERE B1.D_E_L_E_T_ = '' "

    TCQuery cQuery New Alias "QRY1"

    While !(QRY->(Eof()))
        ADD(aProdutos, {QRY1->CODIGO, QRY1->DESCRICAO, QRY1->LOCPAD})
        QRY1->(DbSkip())
    EndDo

    cQuery += "SELECT DISTINCT           " + ENTER
    cQuery += "B1_COD AS CODIGO,         " + ENTER
    cQuery += "B1_DESC AS DESCRICAO,     " + ENTER
    cQuery += "B1_LOCPAD AS LOCPAD,      " + ENTER
    cQuery += "C7_NUM AS PEDIDO,         " + ENTER
    cQuery += "C7_ITEM AS ITEM,          " + ENTER
    cQuery += "C7_EMISSAO AS EMISSAO,    " + ENTER
    cQuery += "C7_FORNECE AS FORNECEDOR, " + ENTER
    cQuery += "A2_NOME AS NOME          " + ENTER
    cQuery += "FROM " + retsqlname("SB1") + " B1(NOLOCK)    " + ENTER
    cQuery += "INNER JOIN " + retsqlname("SC7") + " C7(NOLOCK) ON B1_COD = C7_PRODUTO AND C7.D_E_L_E_T_ = '' " + ENTER
    cQuery += "INNER JOIN " + retsqlname("SA2") + " A2(NOLOCK) ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND A2.D_E_L_E_T_ = '' " + ENTER
    cQuery += "WHERE B1.D_E_L_E_T_ = '' "

    TCQuery cQuery New Alias "QRY2"

    While!(QRY2->(Eof()))
        ADD(aPedidos, {QRY2->CODIGO, QRY2->DESCRICAO, QRY2->LOCPAD, QRY2->PEDIDO, QRY2->ITEM, QRY2->EMISSAO, QRY2->FORNECEDOR, QRY2->NOME})
        QRY2->(DbSkip())
    EndDo

Return

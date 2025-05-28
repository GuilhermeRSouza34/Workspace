#Include "TOTVS.ch"
#Include "Excel.ch"

User Function ExportarProdutosParaExcel()
    Local aArea := FWGetArea()
    Local oExcel := Nil
    Local oWorkbook := Nil
    Local oWorksheet := Nil
    Local nRow := 2 // Começa na linha 2 para deixar a linha 1 para os cabeçalhos

    // Inicializa o Excel
    oExcel := ExcelApplication():New()
    If oExcel:Create()
        oWorkbook := oExcel:Workbooks:Add()
        oWorksheet := oWorkbook:ActiveSheet

        // Define os cabeçalhos
        oWorksheet:Cells(1, 1):Value := "Código"
        oWorksheet:Cells(1, 2):Value := "Descrição"
        oWorksheet:Cells(1, 3):Value := "Preço"

        // Seleciona a tabela de produtos
        DbSelectArea("SB1")
        DbSetOrder(1) // Supondo que o índice 1 seja o código do produto
        DbGoTop()

        // Percorre os registros e escreve no Excel
        While !EOF()
            oWorksheet:Cells(nRow, 1):Value := SB1->B1_COD
            oWorksheet:Cells(nRow, 2):Value := SB1->B1_DESC
            oWorksheet:Cells(nRow, 3):Value := SB1->B1_PRECO
            nRow++
            DbSkip()
        EndDo

        // Salva o arquivo Excel
        oWorkbook:SaveAs("Produtos.xlsx")
        oExcel:Quit()

        MsgInfo("Dados exportados com sucesso para Produtos.xlsx", "Informação")
    Else
        MsgStop("Erro ao inicializar o Excel.", "Erro")
    EndIf

    FWRestArea(aArea)
Return

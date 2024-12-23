#Include "TOTVS.ch"
#Include "Excel.ch"

User Function ExportarClientesParaExcel()
    Local aArea := FWGetArea()
    Local oExcel := Nil
    Local oWorkbook := Nil
    Local oWorksheet := Nil
    Local nRow := 2 // Come�a na linha 2 para deixar a linha 1 para os cabe�alhos

    // Inicializa o Excel
    oExcel := ExcelApplication():New()
    If oExcel:Create()
        oWorkbook := oExcel:Workbooks:Add()
        oWorksheet := oWorkbook:ActiveSheet

        // Define os cabe�alhos
        oWorksheet:Cells(1, 1):Value := "C�digo"
        oWorksheet:Cells(1, 2):Value := "Nome"
        oWorksheet:Cells(1, 3):Value := "Saldo"

        // Seleciona a tabela de clientes
        DbSelectArea("SA1")
        DbSetOrder(1) // Supondo que o �ndice 1 seja o c�digo do cliente
        DbGoTop()

        // Percorre os registros e escreve no Excel
        While !EOF()
            oWorksheet:Cells(nRow, 1):Value := SA1->A1_COD
            oWorksheet:Cells(nRow, 2):Value := SA1->A1_NOME
            oWorksheet:Cells(nRow, 3):Value := SA1->A1_SALDO
            nRow++
            DbSkip()
        EndDo

        // Salva o arquivo Excel
        oWorkbook:SaveAs("Clientes.xlsx")
        oExcel:Quit()

        MsgInfo("Dados exportados com sucesso para Clientes.xlsx", "Informa��o")
    Else
        MsgStop("Erro ao inicializar o Excel.", "Erro")
    EndIf

    FWRestArea(aArea)
Return

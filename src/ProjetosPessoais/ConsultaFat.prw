#Include "TOTVS.ch"

Static Begin
    Local aFiltros := {}
    Local aDadosFaturamento := {}
    
    // Passo 1: Definir parâmetros para o filtro
    aFiltros := DefinirFiltros()
    
    // Passo 2: Coletar dados de faturamento
    aDadosFaturamento := ColetarDadosFaturamento(aFiltros)
    
    // Passo 3: Gerar Relatório
    GerarRelatorio(aDadosFaturamento)
    
End

// Função para definir filtros de consulta (exemplo: período de datas e cliente)
Function DefinirFiltros()
    Local aFiltros := {}
    
    aFiltros["inicio"] := "2024-01-01"
    aFiltros["fim"] := "2024-12-31"
    aFiltros["cliente"] := "Cliente A"
    
    Return aFiltros
End

// Função para coletar dados de faturamento
Function ColetarDadosFaturamento(aFiltros)
    Local aDados := {}
    Local cSQL := ""
    
    // Exemplo de consulta SQL para buscar os dados de faturamento
    cSQL := "SELECT VF.DT_EMISSAO, VF.VL_TOTAL, C.NOME_CLIENTE, P.NOME_PRODUTO " + ;
            "FROM VENDAS_FATURAMENTO VF " + ;
            "INNER JOIN CLIENTES C ON VF.CD_CLIENTE = C.CD_CLIENTE " + ;
            "INNER JOIN PRODUTOS P ON VF.CD_PRODUTO = P.CD_PRODUTO " + ;
            "WHERE VF.DT_EMISSAO BETWEEN '" + aFiltros["inicio"] + "' AND '" + aFiltros["fim"] + "'"
    
    // Caso tenha um filtro de cliente, adicione à consulta
    If aFiltros["cliente"] != ""
        cSQL := cSQL + " AND C.NOME_CLIENTE = '" + aFiltros["cliente"] + "'"
    EndIf
    
    // Executar consulta e armazenar resultado
    aDados := DbSelect(cSQL)
    
    Return aDados
End

// Função para gerar o relatório com base nos dados coletados
Function GerarRelatorio(aDadosFaturamento)
    Local i := 0
    
    // Exemplo de geração de relatório em formato simples
    For i := 1 To Len(aDadosFaturamento)
        // Aqui, você pode formatar os dados de forma tabular, adicionar totais, etc.
        MsgInfo("Data: " + aDadosFaturamento[i, 1] + ;
                " | Cliente: " + aDadosFaturamento[i, 3] + ;
                " | Produto: " + aDadosFaturamento[i, 4] + ;
                " | Valor Total: " + aDadosFaturamento[i, 2], "Relatório de Faturamento")
    Next
End

Function ExportarParaExcel(aDadosFaturamento)
    Local oExcel := ComObject("Excel.Application")
    Local oWorkbook := oExcel:Workbooks:Add()
    Local oSheet := oWorkbook:Sheets(1)

    // Preencher a planilha com os dados
    oSheet:Cells(1, 1):Value := "Data"
    oSheet:Cells(1, 2):Value := "Cliente"
    oSheet:Cells(1, 3):Value := "Produto"
    oSheet:Cells(1, 4):Value := "Valor Total"
    
    For i := 1 To Len(aDadosFaturamento)
        oSheet:Cells(i+1, 1):Value := aDadosFaturamento[i, 1]
        oSheet:Cells(i+1, 2):Value := aDadosFaturamento[i, 3]
        oSheet:Cells(i+1, 3):Value := aDadosFaturamento[i, 4]
        oSheet:Cells(i+1, 4):Value := aDadosFaturamento[i, 2]
    Next

    // Salvar o arquivo Excel
    oWorkbook:SaveAs("C:\\Relatorio_Faturamento.xlsx")
    oExcel:Quit()
End


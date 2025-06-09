// Bibliotecas
#include "Totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zANTRNOV
Rotina de análise (TurnOver) para o setor RH 
@type user function
@author Vinícius Reies 
@since 04/01/2025
/*/

User Function zANTRNOV()
    Local aArea   := GetArea()                                          // Abrindo área
    Local aPergs  := {}                                                 // (Parambox) Array de perguntas 
    Local cDateDe := FirstDate(Date())                                  // (Parambox) Data Referência De
    Local cDateAt := LastDate(Date())                                   // (Parambox) Data Referência Até
    Local cFuncDe := Space(TamSX3("RJ_FUNCAO")[1])                      // (Parambox) Função De
    Local cFuncAt := StrTran(Space(TamSX3("RJ_FUNCAO")[1]), " ", "Z")   // (Parambox) Função Até
    Local cCentDe := Space(TamSX3("CTT_CUSTO")[1])                      // (Parambox) Centro de Custo De
    Local cCentAt := StrTran(Space(TamSX3("CTT_CUSTO")[1]), " ", "Z")   // (Parambox) Centro de Custo Até

    // Adicionando parâmetros do parambox
    aAdd(aPergs, {1,"Data Referência De" ,  cDateDe, "", "",    "", ".T.", 60, .T.}) // MV_PAR01 
    aAdd(aPergs, {1,"Data Referência Até",  cDateAt, "", "",    "", ".T.", 60, .T.}) // MV_PAR02
    aAdd(aPergs, {1,"Função De" ,           cFuncDe, "", "", "SRJ", ".T.", 60, .F.}) // MV_PAR03 
    aAdd(aPergs, {1,"Função Até",           cFuncAt, "", "", "SRJ", ".T.", 60, .T.}) // MV_PAR04
    aAdd(aPergs, {1,"Centro de Custo De" ,  cCentDe, "", "", "CTT", ".T.", 60, .F.}) // MV_PAR05 
    aAdd(aPergs, {1,"Centro de Custo Até",  cCentAt, "", "", "CTT", ".T.", 60, .T.}) // MV_PAR06

    If Parambox(aPergs, "Informe os parâmetros")
        // Chamando função principal que faz a montagem da tela
        fMontaTela() 
    EndIf

    // Restaurando área
    RestArea(aArea)
Return 


/*---------------------------------------------------------------------*
| Func:  fMontaTela                                                   |
| Autor: Vinícius Reies                                               |
| Data:  18/01/2025                                                   |
| Desc:  Função que cria e renderiza a tela principal                 |
*---------------------------------------------------------------------*/
Static Function fMontaTela()
    Local   nLargBtn    := 50 // largura do botão (sair)
    Local   nLargBtn2   := 65 // largura do botão (Exportar para excel e Visualizar)
    Local   aRand       := {} // Array de cores
    Private nTotalFun   := 0  // Número total de funcionários
    Private nTotalDem   := 0  // Número total de funcionários demitidos
    Private aFunExcel   := {} // Array para armazenar registros dos funcionários

    // Ordenação da tela
    Private cUltOrdem := ""   // Armazena a ultima ordem para regra da ordenação
    Private lDescend  := .F.  // Controle para ordenação Crescente ou Decrescente
    Private nOrder    := 0    // Variável de ordenação de acordo com os tipos criado na tabela

    // Objetos e componentes
    Private oDialog
    Private oFwLayer
    Private oFWChart            
    Private oPanTitulo
    Private oPanAdmit
    Private oPanDemit

    // Cabeçalho - Título
    Private oSayTitulo, cSayTitulo := "Análise de"
    Private oSaySubTit, cSaySubTit := "TurnOver"

    // Cabeçalho - Título dos parâmetros 
    Private oSayPParam, cSayPParam := "Parâmetros: "
    Private oSayPDatDe, cSayPDatDe := "Data Refêrencia de:  " 
    Private oSayPDatAt, cSayPDatAt := "Data Referência até: " 
    Private oSayPFunDe, cSayPFunDe := "Função de:           " 
    Private oSayPfunAt, cSayPfunAt := "Função até:          " 
    Private oSayPCenDe, cSayPCenDe := "Centro de Custo de:  " 
    Private oSayPCenAt, cSayPCenAt := "Centro de Custo até: " 

    // Cabeçalho - Valor de cada parâmetro 
    Private oSayRDatDe, cSayRDatDe :=  DToC(MV_PAR01)
    Private oSayRDatAt, cSayRDatAt :=  DToC(MV_PAR02) 
    Private oSayRFunDe, cSayRFunDe :=  MV_PAR03       
    Private oSayRfunAt, cSayRfunAt :=  MV_PAR04       
    Private oSayRCenDe, cSayRCenDe :=  MV_PAR05       
    Private oSayRCenAt, cSayRCenAt :=  MV_PAR06       

    // Cabeçalho - informações sobre o gráfico
    Private oSayGrfAdm, cSayGrfAdm := "Admissões:     "  
    Private oSayGrfDem, cSayGrfDem := "Demissões:     "     
    Private oSayGrfTot, cSayGrfTot := "Total Período: "    

    // Sub-Título das duas tabelas (Grid de Admitidos e Demitidos) 
    Private oPansAdm,   cSayAdm    := "Admitidos"
    Private oPansDem,   cSayDem    := "Demitidos" 

    // Tamanho da janela
    Private aSize       := MsAdvSize(.F.)   // Pegando total do tamanho
    Private nJanLarg    := aSize[5]         // Pegado 5 do total do tamanho
    Private nJanAltu    := aSize[6]         // pegando 6 do total do tamanho

    // Fontes
    Private cFontUti    := "Tahoma"
    Private oFontMod    := TFont():New(cFontUti, , -38)
    Private oFontModN   := TFont():New(cFontUti, , -38, , .T.)
    Private oFontSub    := TFont():New(cFontUti, , -20)
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)
    Private oFontSay    := TFont():New(cFontUti, , -12)
   
    // Grid Admitidos 
    Private cAliasAdm   := GetNextAlias()   // Alias para usar na tabela temporária
    Private aColunasAdm := {}               // Coluna de admitidos
    Private aCamposAdm  := {}               // Campos de admitidos
    Private oTableAdm

    // Grid demitidos
    Private cAliasDem   := GetNextAlias()   // Alias para usar na tabela temporária
    Private aColunasDem := {}               // Coluna de Demitidos
    Private aCamposDem  := {}               // Campos de Admitidos
    Private oTableDem

    // Cria a tabela temporária de Admitidos
    Processa({|| fTabelaAdm()}, "Admitidos...")

    // Cria a tabela temporária de Demitidos
    Processa({|| fTabelaDem()}, "Demitidos...")

    // Popula ambas as tabelas temporárias
    Processa({|| fBuscaDados()}, "Processando...")
 
    // Cria a janela
    DEFINE MSDIALOG oDialog TITLE "Análise de TurnOver"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
 
        // Criando a camada
        oFwLayer := FwLayer():New()
        oFwLayer:init(oDialog,.F.)
 
        // Adicionando 4 linhas (Título, informações, Sub-título e tabela)
        oFWLayer:addLine("TIT", 006, .F.)                       // Título
        oFWLayer:addLine("INF", 025, .F.)                       // Linha de informações (Gráfico, informações do gráfico e parâmetros)
        oFWLayer:addLine("SBT", 005, .F.)                       // SubTítulo (Admissões, Demissões)
        oFWLayer:addLine("TAB", 064, .F.)                       // Tabelas de informações (2)
 
        // Adicionando as colunas das linhas
        oFWLayer:addCollumn("TITULO",        080, .T.,  "TIT")  // Títulos
        oFWLayer:addCollumn("BOTOES",        020, .T.,  "TIT")  // Botão sair

        oFWLayer:addCollumn("GRAFICO",       030, .T.,  "INF")  // Gráfico
        oFWLayer:addCollumn("INFOS",         020, .T.,  "INF")  // Informações
        oFWLayer:addCollumn("PARAMS",        050, .T.,  "INF")  // Parâmetros

        oFWLayer:addCollumn("SUBTITU1",      050, .T.,  "SBT")  // Título das tabelas Admitido
        oFWLayer:addCollumn("SUBTITU2",      050, .T.,  "SBT")  // Título das tabelas Demitido

        oFWLayer:addCollumn("ADMITIDOS",     050, .T.,  "TAB")  // Tabela de admitidos
        oFWLayer:addCollumn("DEMITIDOS",     050, .T.,  "TAB")  // Tabela de demitidos

        /*                  Criando os paineis
        **********************************************************/
        // Linha do título
        oPanTitle  := oFWLayer:GetColPanel("TITULO",     "TIT")  // Título vai ficar na linha título
        oPanSair   := oFWLayer:GetColPanel("BOTOES",     "TIT")  // Botão sair vai ficar na linha do título

        // Linha de informações
        oPansGra   := oFWLayer:GetColPanel("GRAFICO",    "INF")  // Grafico vai ficar na linha de baixo, de informações
        oPansInf   := oFWLayer:GetColPanel("INFOS",      "INF")  // Informações do gráfico vai ficar no final do na frente do gáfico
        oPansPar   := oFWLayer:GetColPanel("PARAMS",     "INF")  // Parâmetros vai ficar no final do gráfico

        // Linha do subtítulo das tabelas
        oPansDTab1   := oFWLayer:GetColPanel("SUBTITU1",  "SBT") // Grafico vai ficar na linha de baixo, de informações
        oPansDTab2   := oFWLayer:GetColPanel("SUBTITU2",  "SBT") // Grafico vai ficar na linha de baixo, de informações

        // Linha das tabelas
        oPanAdmit  := oFWLayer:GetColPanel("ADMITIDOS",   "TAB") // Grid de admitidos
        oPanDemit  := oFWLayer:GetColPanel("DEMITIDOS",   "TAB") // Grid de demitidos
        
        
        /*         Inserindo as informações em cada painel
        **********************************************************/
        //Títulos e SubTítulos
        oSayTitulo := TSay():New(004, 004, {|| cSayTitulo}, oPanTitle, "",  oFontMod, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
        oSaySubTit := TSay():New(004, 95,  {|| cSaySubTit}, oPanTitle, "",  oFontModN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

        // Descrição do gráfico
        oSayGrfAdm := TSay():New(015, 004, {|| cSayGrfAdm}, oPansInf,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , ) 
        oSayGrfDem := TSay():New(030, 004, {|| cSayGrfDem}, oPansInf,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , ) 
        oSayGrfTot := TSay():New(090, 004, {|| cSayGrfTot}, oPansInf,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , ) 

        // Parametros informados
        oSayPParam := TSay():New(000, 050, {|| cSayPParam}, oPansPar,  "",  oFontSubN, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        oSayPDatDe := TSay():New(015, 050, {|| cSayPDatDe}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayRDatDe := TSay():New(015, 165, {|| cSayRDatDe}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        oSayPDatAt := TSay():New(030, 050, {|| cSayPDatAt}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayRDatAt := TSay():New(030, 165, {|| cSayRDatAt}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        oSayPFunDe := TSay():New(045, 050, {|| cSayPFunDe}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayRFunDe := TSay():New(045, 165, {|| cSayRFunDe}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        oSayPfunAt := TSay():New(060, 050, {|| cSayPfunAt}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayRfunAt := TSay():New(060, 165, {|| cSayRfunAt}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        oSayPCenDe := TSay():New(075, 050, {|| cSayPCenDe}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayRCenDe := TSay():New(075, 165, {|| cSayRCenDe}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        oSayPCenAt := TSay():New(090, 050, {|| cSayPCenAt}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSayRCenAt := TSay():New(090, 165, {|| cSayRCenAt}, oPansPar,  "",  oFontSub, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )

        // título das tabelas
        oPansAdm  := TSay():New(010, 200,     {|| cSayAdm}, oPansDTab1, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oPansDem  := TSay():New(010, 200,     {|| cSayDem}, oPansDTab2, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , ) 

        //Criando os botões
        oBtnExcel := TButton():New(004, 030, "Exportar para" + CRLF + "Excel",  oPanSair,  {|| fGeraExcel(aFunExcel)}, nLargBtn2, 022, , oFontBtn, , .T., , , , , , ) 
        oBtnSair  := TButton():New(004, 110, "Fechar",                          oPanSair,  {|| oDialog:End()        }, nLargBtn,  022, , oFontBtn, , .T., , , , , , )


        /*         Gerando gráfico com as informações
        **********************************************************/
        //Instância a classe
        oFWChart := FWChartFactory():New()
        oFWChart := oFWChart:getInstance(BARCHART) //BARCOMPCHART ; LINECHART ; PIECHART
        
        //Inicializa pertencendo a janela
        oFWChart:Init(oPansGra, .F., .F. )
        
        //Seta o título do gráfico
        oFWChart:SetTitle("Gráfico Comparativo", CONTROL_ALIGN_CENTER)  
        
        //Adiciona as séries, com as descrições e valores
        oFWChart:addSerie("Admitidos no Período", nTotalFun)
        oFWChart:addSerie("Demitidos no Período", nTotalDem)
        
        //Define que a legenda será mostrada na esquerda
        oFWChart:setLegend( CONTROL_ALIGN_CENTER )
        
        //Seta a máscara mostrada na régua
        oFWChart:cPicture := "@E 999,999,999,999,999.99"
        
        //Define as cores que serão utilizadas no gráfico
        aAdd(aRand, {"084,120,164", "007,013,017"})
        aAdd(aRand, {"171,225,108", "017,019,010"})
        
        //Seta as cores utilizadas
        oFWChart:oFWChartColor:aRandom := aRand
        oFWChart:oFWChartColor:SetColor("Random")
        
        //Constrói o gráfico
        oFWChart:Build()
        
        
        /*                  Criação das grids 
        **********************************************************/
        // Grid de admitidos
        oGetGridAd := FWBrowse():New()
        oGetGridAd:SetDataTable()
        oGetGridAd:SetInsert(.F.)
        oGetGridAd:SetDelete(.F., { || .F. })
        oGetGridAd:SetAlias(cAliasAdm)
        oGetGridAd:DisableReport()
        oGetGridAd:DisableFilter()
        oGetGridAd:DisableConfig()
        oGetGridAd:DisableReport()
        oGetGridAd:DisableSeek()
        oGetGridAd:lHeaderClick := .T.
        oGetGridAd:SetItemHeaderClick({"MATRICULA", "NOME"})
        oGetGridAd:DisableSaveConfig()
        oGetGridAd:SetDoubleClick( {|| fFunView(cAliasAdm) } ) 
        oGetGridAd:SetFontBrowse(oFontSay)
        oGetGridAd:SetColumns(aColunasAdm)
        oGetGridAd:SetOwner(oPanAdmit)
        oGetGridAd:Activate()

        // Grid de Demitidos
        oGetGridDe := FWBrowse():New()
        oGetGridDe:SetDataTable()
        oGetGridDe:SetInsert(.F.)
        oGetGridDe:SetDelete(.F., { || .F. })
        oGetGridDe:SetAlias(cAliasDem)
        oGetGridDe:DisableReport()
        oGetGridDe:DisableFilter()
        oGetGridDe:DisableConfig()
        oGetGridDe:DisableReport()
        oGetGridDe:DisableSeek()
        oGetGridDe:lHeaderClick := .T.
        oGetGridDe:SetItemHeaderClick({"MATRICULA", "NOME"})
        oGetGridDe:DisableSaveConfig()
        oGetGridDe:SetDoubleClick( {|| fFunView(cAliasDem) } ) 
        oGetGridDe:SetFontBrowse(oFontSay)
        oGetGridDe:SetColumns(aColunasDem)
        oGetGridDe:SetOwner(oPanDemit)
        oGetGridDe:Activate()

    Activate MsDialog oDialog Centered

    /*              Encerrando as tabelas 
    **********************************************************/
    SRA_TMP->(DbCloseArea())
    oTableAdm:Delete()
    oTableDem:Delete()

Return
 

/*---------------------------------------------------------------------*
| Func:  fTabelaAdm                                                   |
| Autor: Vinícius Reies                                               |
| Data:  11/01/2025                                                   |
| Desc:  Função que cria a tabela tempórária de admitidos             |
*---------------------------------------------------------------------*/
Static Function fTabelaAdm()

    //Campos da Temporária (Admitidos)
    aAdd(aCamposAdm, { "MATRICULA" ,      "C", TamSX3("RA_MAT")[1],     0 })
    aAdd(aCamposAdm, { "NOME" ,           "C", TamSX3("RA_NOME")[1],    0 })
    aAdd(aCamposAdm, { "FUNCAO" ,         "C", TamSX3("RJ_DESC")[1],    0 })
    aAdd(aCamposAdm, { "CTCUSTO" ,        "C", TamSX3("CTT_DESC01")[1], 0 })
    aAdd(aCamposAdm, { "ADMISSAO" ,       "D", TamSX3("RA_ADMISSA")[1], 0 })
    aAdd(aCamposAdm, { "RECNO" ,          "N",                     16,  0 })

    //Cria a tabela temporária (Admitidos)
    oTableAdm:= FWTemporaryTable():New(cAliasAdm)
    oTableAdm:SetFields( aCamposAdm )
    oTableAdm:AddIndex("1", {"MATRICULA"} )
    oTableAdm:AddIndex("2", {"NOME"}      )
    oTableAdm:Create()

    //Busca as colunas do browse
    aColunasAdm := fColsAdm()

Return


/*---------------------------------------------------------------------*
| Func:  fTabelaDem                                                   |
| Autor: Vinícius Reies                                               |
| Data:  12/01/2025                                                   |
| Desc:  Função que cria a tabela tempórária de demitidos             |
*---------------------------------------------------------------------*/
Static Function fTabelaDem()

    // Campos da Temporária (Demitidos)
    aAdd(aCamposDem, { "MATRICULA" ,      "C", TamSX3("RA_MAT")[1],     0 })
    aAdd(aCamposDem, { "NOME" ,           "C", TamSX3("RA_NOME")[1],    0 })
    aAdd(aCamposDem, { "FUNCAO" ,         "C", TamSX3("RJ_DESC")[1],    0 })
    aAdd(aCamposDem, { "CTCUSTO" ,        "C", TamSX3("CTT_DESC01")[1], 0 })
    aAdd(aCamposDem, { "ADMISSAO" ,       "D", TamSX3("RA_ADMISSA")[1], 0 })
    aAdd(aCamposDem, { "DEMISSAO" ,       "D", TamSX3("RA_DEMISSA")[1], 0 })
    aAdd(aCamposDem, { "RECNO" ,          "N",                     16, 0 })

    // Cria a tabela temporária (Demitidos)
    oTableDem:= FWTemporaryTable():New(cAliasDem)
    oTableDem:SetFields( aCamposDem )
    oTableDem:AddIndex("1", {"MATRICULA"} )
    oTableDem:AddIndex("2", {"NOME"}      )
    oTableDem:Create()

    // Busca as colunas do browse
    aColunasDem := fColsDem()

Return 
 

/*---------------------------------------------------------------------*
| Func:  fColsAdm                                                     |
| Autor: Vinícius Reies                                               |
| Data:  14/01/2025                                                   |
| Desc:  Função que cria as colunas da tabela de admitidos            |
*---------------------------------------------------------------------*/
Static Function fColsAdm()
    Local nAtual        := 0 
    Local aEstrut       := {}
    Local oColumn
     
    // Adicionando campos que serão mostrados na tela
    aAdd(aEstrut, {"MATRICULA",    "Matrícula",           "C", TamSX3('RA_MAT')[01],     0, ""})
    aAdd(aEstrut, {"NOME",         "Nome",                "C", TamSX3('RA_NOME')[01],    0, ""})
    aAdd(aEstrut, {"FUNCAO",       "Função",              "C", TamSX3('RJ_DESC')[01],    0, ""})
    aAdd(aEstrut, {"CTCUSTO",      "Centro de Custo",     "C", TamSX3('CTT_DESC01')[01], 0, ""})
    aAdd(aEstrut, {"ADMISSAO",     "Admissão",            "D", TamSX3('RA_ADMISSA')[01], 0, ""})
  
    // Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        // Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (cAliasAdm)->" + aEstrut[nAtual][1] +"}"))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])

        // Se for o código ou descrição, adiciona a opção de clique no cabeçalho
        If Alltrim(aEstrut[nAtual][1]) $ "MATRICULA;NOME;"
            oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "', '" +cAliasAdm+ "') }")
        EndIf

        // Adiciona a coluna
        aAdd(aColunasAdm, oColumn)
    Next
Return aColunasAdm


/*---------------------------------------------------------------------*
| Func:  fColsDem                                                     |
| Autor: Vinícius Reies                                               |
| Data:  14/01/2025                                                   |
| Desc:  Função que cria as colunas da tabela de demitidos            |
*---------------------------------------------------------------------*/
Static Function fColsDem()
    Local nAtual        := 0 
    Local aEstrut       := {}
    Local oColumn

    // Adicionando campos que serão mostrados na tela
    aAdd(aEstrut, {"MATRICULA",     "Matrícula",        "C", TamSX3('RA_MAT')[01],     0, ""})
    aAdd(aEstrut, {"NOME",          "Nome",             "C", TamSX3('RA_NOME')[01],    0, ""})
    aAdd(aEstrut, {"FUNCAO",        "Função",           "C", TamSX3('RJ_DESC')[01],    0, ""})
    aAdd(aEstrut, {"CTCUSTO",       "Centro de Custo",  "C", TamSX3('CTT_DESC01')[01], 0, ""})
    aAdd(aEstrut, {"ADMISSAO",      "Admissão",         "D", TamSX3('RA_ADMISSA')[01], 0, ""})
    aAdd(aEstrut, {"DEMISSAO",      "Demissão",         "D", TamSX3('RA_DEMISSA')[01], 0, ""})

    // Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        // Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (cAliasDem)->" + aEstrut[nAtual][1] +"}"))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])

        // Se for o código ou descrição, adiciona a opção de clique no cabeçalho
        If Alltrim(aEstrut[nAtual][1]) $ "MATRICULA;NOME;"
            oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "', '" +cAliasDem+ "') }")
        EndIf

        // Adiciona a coluna
        aAdd(aColunasDem, oColumn)
    Next
Return aColunasDem

 
/*---------------------------------------------------------------------*
| Func:  fBuscaDados                                                  |
| Autor: Vinícius Reies                                               |
| Data:  12/01/2025                                                   |
| Desc:  Função que busca os dados dos func. e aplica nas tabelas     |
*---------------------------------------------------------------------*/
Static Function fBuscaDados()
    Local aArea        := FWGetArea()
    Local cQuery       := ""                        // Query para busca na SRA
    Local cDataDe      := FormataData(MV_PAR01, 5)  // Data De do parâmetro formatada para tipo D do SQL
    Local cDataAt      := FormataData(MV_PAR02, 5)  // Data Ate do parâmetro formatada para tipo D do SQL
    Local nAuxConta    := 0                         // Variável auxiliar de conta
    Private cAliasAux  := ""                        // Auxiliar do Alias. Para trabalhar coom gravação nas duas tabelas temporárias

    // Montagem da query para busca de informações
    cQuery := "SELECT"                                                                                                                                    + CRLF 
    cQuery += "      SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CODFUNC, RJ_DESC, SRA.RA_CC, CTT_DESC01, SRA.RA_ADMISSA, SRA.RA_DEMISSA, SRA.R_E_C_N_O_ AS SRAREC"   + CRLF 
    cQuery += "FROM " + RetSqlName("SRA") + " SRA "                                                                                                       + CRLF
    cQuery += "INNER JOIN " + RetSqlName("CTT") + " CTT ON"                                                                                               + CRLF
    cQuery += "         CTT.CTT_FILIAL = SRA.RA_FILIAL"                                                                                                   + CRLF
    cQuery += "         AND CTT.CTT_CUSTO = SRA.RA_CC"                                                                                                    + CRLF
    cQuery += "         AND CTT.D_E_L_E_T_ = ''"                                                                                                          + CRLF    
    cQuery += "INNER JOIN " + RetSqlName("SRJ") + " SRJ ON"                                                                                               + CRLF
    cQuery += "         SRJ.RJ_FUNCAO  = SRA.RA_CODFUNC"                                                                                                  + CRLF
    cQuery += "         AND SRJ.D_E_L_E_T_ = '' "                                                                                                         + CRLF
    cQuery += "WHERE"                                                                                                                                     + CRLF
    cQuery += "         SRA.RA_CODFUNC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND"                                                             + CRLF
    cQuery += "         SRA.RA_CC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND"                                                                  + CRLF
    cQuery += "         SRA.RA_FILIAL = '" + FWxFilial("SRA") + "' AND"                                                                                   + CRLF
    cQuery += "         ( "                                                                                                                               + CRLF
    cQuery += "             (SRA.RA_ADMISSA  BETWEEN '" + cDataDe + "' AND '" + cDataAt + "') OR "                                                        + CRLF
    cQuery += "             (SRA.RA_DEMISSA  BETWEEN '" + cDataDe + "' AND '" + cDataAt + "') "                                                           + CRLF
    cQuery += "         ) AND "                                                                                                                           + CRLF
    cQuery += "         SRA.D_E_L_E_T_ = ''"                                                                                                              + CRLF
    cQuery += "ORDER BY RA_MAT"

    // Instânciando a query
    TCQuery cQuery New Alias "SRA_TMP"

    // Definindo o formato dos valores do campo como data, após consulta
    TcSetField("SRA_TMP", "RA_ADMISSA", "D")
    TcSetField("SRA_TMP", "RA_DEMISSA", "D")

    // Caso a query tenha informações
    If ! SRA_TMP->(EoF())
        
        // Definindo ponteiro no topo
        SRA_TMP->(DBGoTop())

        While ! SRA_TMP->(Eof())
            
            // Se funcionário for demitido, o Alias apontará para demitidos
            cAliasAux := Iif(!Empty(SRA_TMP->RA_DEMISSA), cAliasDem, cAliasAdm )

            // incluindo valor na tabela temporária com os resultados da query
            RecLock(cAliasAux, .T.)
                (cAliasAux)->MATRICULA := SRA_TMP->RA_MAT
                (cAliasAux)->NOME      := SRA_TMP->RA_NOME
                (cAliasAux)->FUNCAO    := SRA_TMP->RJ_DESC
                (cAliasAux)->CTCUSTO   := SRA_TMP->CTT_DESC01
                (cAliasAux)->ADMISSAO  := SRA_TMP->RA_ADMISSA

                // Só vai gravar demissão na tabela de demitidos ( ou seja, quando houver data de demissão )
                if !Empty(SRA_TMP->RA_DEMISSA)
                    (cAliasAux)->DEMISSAO  := SRA_TMP->RA_DEMISSA
                    // Adicionando registro de demitidos
                    nTotalDem++ 
                EndIf

                // Aplicando recno na tabela
                (cAliasAux)->RECNO  := SRA_TMP->SRAREC


            (cAliasAux)->(MsUnlock())

            aAdd(aFunExcel, {Alltrim(SRA_TMP->RA_MAT),Alltrim(SRA_TMP->RA_NOME),Alltrim(SRA_TMP->RJ_DESC),Alltrim(SRA_TMP->CTT_DESC01), DToC(SRA_TMP->RA_ADMISSA), Iif(!Empty(SRA_TMP->RA_DEMISSA), DToC(SRA_TMP->RA_DEMISSA), "")})

            // Adicionando número de funcionários ao contador total
            nTotalFun++ 
            
            // Indo para próximo registro
            SRA_TMP->(DbSkip())
        EndDo       

        // Auxiliar da operação para atribuição de percentual
        nAuxConta := nTotalFun - nTotalDem

        // Aplicando valores para as informações do gráfico
        cSayGrfAdm += cValToChar(nAuxConta) + Iif( nAuxConta <= 0, ' (00,0%)', ' (' + Str((nAuxConta / nTotalFun) * 100, 5, 2) + "%)")
        cSayGrfDem += cValToChar(nTotalDem) + Iif( nTotalDem <= 0, ' (00,0%)', ' (' + Str((nTotalDem / nTotalFun) * 100, 5, 2) + "%)")
        cSayGrfTot += cValToChar(nTotalFun)
    Else
        FWAlertInfo("Sem resultados. Por favor, revise as datas inseridas e tente novamente!")
    EndIf

    RestArea(aArea)
Return 


/*---------------------------------------------------------------------*
| Func:  fFunView                                                     |
| Autor: Vinícius Reies                                               |
| Data:  28/01/2025                                                   |
| Desc:  Função para posicionar                                       |
*---------------------------------------------------------------------*/
Static Function fFunView(cAlias)
    Local aArea := FWGetArea()
    Local cFunc  := (cAlias)->MATRICULA + ' ' + Alltrim((cAlias)->NOME)
 
    // Se a pergunta for confirmada, abre a visualização do colaborador
    If FWAlertYesNo("Deseja visualizar " + cFunc + "'?", "Continua?")

        DbSelectArea("SRA")
        SRA->(DbGoTo((cAlias)->RECNO))
       
        // Posiciona no funcionário e abre a visualização
        Gpea010Vis("SRA", SRA->(RecNo()), 2)
    EndIf
 
    FWRestArea(aArea)
Return 


/*---------------------------------------------------------------------*
| Func:  fOrdena                                                       |
| Autor: Vinícius Reies                                                |
| Data:  28/01/2025                                                    |
| Desc:  Função para ordenar os campos por matricula ou descrição      |
*---------------------------------------------------------------------*/
Static Function fOrdena(cCampo, cAlias)
    Default cCampo := ""
  
    // Pegando o Índice conforme o campo
    cCampo := Alltrim(cCampo)

    If cCampo == "MATRICULA"
        nOrder := 1
    ElseIf cCampo == "NOME"
        nOrder := 2
    EndIf
  
    // Ordena pelo Índice
    (cAlias)->(DbSetOrder(nOrder))
  
    // Se o último campo clicado é o mesmo, irá mudar entre crescente / decrescente
    If cUltOrdem == cCampo
        // Se esta como decrescente, ordena crescente
        If lDescend
            OrdDescend(nOrder, cValToChar(nOrder), .F.)
            lDescend := .F.
  
        // Se esta como crescente, ordena como decrescente
        Else
            OrdDescend(nOrder, cValToChar(nOrder), .T.)
            lDescend := .T.
        EndIf
    Else
        lDescend := .F.
    EndIf
    cUltOrdem := cCampo
  
    fRefresh(cAlias)
Return


/*---------------------------------------------------------------------*
| Func:  fRefresh                                                      |
| Autor: Vinícius Reies                                                |
| Data:  28/01/2025                                                    |
| Desc:  Função para atualizar a ordenação                             |
*---------------------------------------------------------------------*/
Static Function fRefresh(cAlias)
    Local oObjecAux 

    // Se o alias posicionado for igual ao Alias de admitidos, ativa a primeira grid (Admitidos) (se não, demitidos)
    if cAlias == cAliasAdm
        oObjecAux := oGetGridAd
    Else
        oObjecAux := oGetGridDe
    EndIf

    (cAlias)->(DbGoTop())
    oObjecAux:GoBottom(.T.)
    oObjecAux:Refresh(.T.)
    oObjecAux:GoTop(.T.)
    oObjecAux:Refresh(.T.)
Return


/*---------------------------------------------------------------------*
| Func:  fGeraExcel                                                    |
| Autor: Vinícius Reies                                                |
| Data:  28/01/2025                                                    |
| Desc:  Função para gerar excel com todos colaboradores               |
*---------------------------------------------------------------------*/
Static Function fGeraExcel(aFunExcel)
	Local oFWMsExcel
    Local cArquivo    := GetTempPath() + "TurnOver_" + DToS(Date()) + cValToChar(Random(0, 50)) + cValToChar(Random(50, 99)) + ".xlsx" // Caminho para pasta temporária com nome do arquivo
	Local nLinha  	  := 0					                                                                             // Número da linha
	Local nLinhas 	  := Len(aFunExcel)                                                                                  // Número de linhas do array
	Local nColuna 	  := 0					                                                                             // Número da coluna
	Local nColunas 	  := Len(aFunExcel[1])                                                                               // Número de colunas (supondo que todas as linhas têm o mesmo número de colunas)
	Local aRow 		  := {}					                                                                             // Armazenando linhas 
    Local cWorksheet  := "TurnOver"                                                                                      // Nome da WorkSheet
    Local cTableExcel := "Análise de TurnOver referente a " + DToC(MV_PAR01) + " até " + DToC(MV_PAR02)

	// Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcelXLSX():New()
     
    // Aba 01 - Teste
    oFWMsExcel:AddworkSheet(cWorkSheet)

	// Criando a Tabela
	oFWMsExcel:AddTable(cWorkSheet,cTableExcel)
	
	// Criando Colunas
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Matricula", 			1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Nome", 				1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Função", 				1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Cent. Custo", 	    1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Admissão", 			1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Demissão", 			1,1)
    
	// Criando as Linhas
	For nLinha := 1 To nLinhas

		For nColuna := 1 To nColunas
            aAdd(aRow, aFunExcel[nLinha][nColuna])  // Adiciona o valor se não for vazio
		Next

		// Passando a linha no formato correto para o método AddRow
		oFWMsExcel:AddRow(cWorkSheet, cTableExcel, aRow)
		aRow := {}
	Next
     
    // Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    // Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           // Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     // Abre a planilha
    oExcel:SetVisible(.T.)              // Visualiza a planilha

Return


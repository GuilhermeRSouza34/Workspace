// Bibliotecas
#include "Totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zANTRNOV
Rotina de an�lise (TurnOver) para o setor RH 
@type user function
@author Vin�cius Reies 
@since 04/01/2025
/*/

User Function zANTRNOV()
    Local aArea   := GetArea()                                          // Abrindo �rea
    Local aPergs  := {}                                                 // (Parambox) Array de perguntas 
    Local cDateDe := FirstDate(Date())                                  // (Parambox) Data Refer�ncia De
    Local cDateAt := LastDate(Date())                                   // (Parambox) Data Refer�ncia At�
    Local cFuncDe := Space(TamSX3("RJ_FUNCAO")[1])                      // (Parambox) Fun��o De
    Local cFuncAt := StrTran(Space(TamSX3("RJ_FUNCAO")[1]), " ", "Z")   // (Parambox) Fun��o At�
    Local cCentDe := Space(TamSX3("CTT_CUSTO")[1])                      // (Parambox) Centro de Custo De
    Local cCentAt := StrTran(Space(TamSX3("CTT_CUSTO")[1]), " ", "Z")   // (Parambox) Centro de Custo At�

    // Adicionando par�metros do parambox
    aAdd(aPergs, {1,"Data Refer�ncia De" ,  cDateDe, "", "",    "", ".T.", 60, .T.}) // MV_PAR01 
    aAdd(aPergs, {1,"Data Refer�ncia At�",  cDateAt, "", "",    "", ".T.", 60, .T.}) // MV_PAR02
    aAdd(aPergs, {1,"Fun��o De" ,           cFuncDe, "", "", "SRJ", ".T.", 60, .F.}) // MV_PAR03 
    aAdd(aPergs, {1,"Fun��o At�",           cFuncAt, "", "", "SRJ", ".T.", 60, .T.}) // MV_PAR04
    aAdd(aPergs, {1,"Centro de Custo De" ,  cCentDe, "", "", "CTT", ".T.", 60, .F.}) // MV_PAR05 
    aAdd(aPergs, {1,"Centro de Custo At�",  cCentAt, "", "", "CTT", ".T.", 60, .T.}) // MV_PAR06

    If Parambox(aPergs, "Informe os par�metros")
        // Chamando fun��o principal que faz a montagem da tela
        fMontaTela() 
    EndIf

    // Restaurando �rea
    RestArea(aArea)
Return 


/*---------------------------------------------------------------------*
| Func:  fMontaTela                                                   |
| Autor: Vin�cius Reies                                               |
| Data:  18/01/2025                                                   |
| Desc:  Fun��o que cria e renderiza a tela principal                 |
*---------------------------------------------------------------------*/
Static Function fMontaTela()
    Local   nLargBtn    := 50 // largura do bot�o (sair)
    Local   nLargBtn2   := 65 // largura do bot�o (Exportar para excel e Visualizar)
    Local   aRand       := {} // Array de cores
    Private nTotalFun   := 0  // N�mero total de funcion�rios
    Private nTotalDem   := 0  // N�mero total de funcion�rios demitidos
    Private aFunExcel   := {} // Array para armazenar registros dos funcion�rios

    // Ordena��o da tela
    Private cUltOrdem := ""   // Armazena a ultima ordem para regra da ordena��o
    Private lDescend  := .F.  // Controle para ordena��o Crescente ou Decrescente
    Private nOrder    := 0    // Vari�vel de ordena��o de acordo com os tipos criado na tabela

    // Objetos e componentes
    Private oDialog
    Private oFwLayer
    Private oFWChart            
    Private oPanTitulo
    Private oPanAdmit
    Private oPanDemit

    // Cabe�alho - T�tulo
    Private oSayTitulo, cSayTitulo := "An�lise de"
    Private oSaySubTit, cSaySubTit := "TurnOver"

    // Cabe�alho - T�tulo dos par�metros 
    Private oSayPParam, cSayPParam := "Par�metros: "
    Private oSayPDatDe, cSayPDatDe := "Data Ref�rencia de:  " 
    Private oSayPDatAt, cSayPDatAt := "Data Refer�ncia at�: " 
    Private oSayPFunDe, cSayPFunDe := "Fun��o de:           " 
    Private oSayPfunAt, cSayPfunAt := "Fun��o at�:          " 
    Private oSayPCenDe, cSayPCenDe := "Centro de Custo de:  " 
    Private oSayPCenAt, cSayPCenAt := "Centro de Custo at�: " 

    // Cabe�alho - Valor de cada par�metro 
    Private oSayRDatDe, cSayRDatDe :=  DToC(MV_PAR01)
    Private oSayRDatAt, cSayRDatAt :=  DToC(MV_PAR02) 
    Private oSayRFunDe, cSayRFunDe :=  MV_PAR03       
    Private oSayRfunAt, cSayRfunAt :=  MV_PAR04       
    Private oSayRCenDe, cSayRCenDe :=  MV_PAR05       
    Private oSayRCenAt, cSayRCenAt :=  MV_PAR06       

    // Cabe�alho - informa��es sobre o gr�fico
    Private oSayGrfAdm, cSayGrfAdm := "Admiss�es:     "  
    Private oSayGrfDem, cSayGrfDem := "Demiss�es:     "     
    Private oSayGrfTot, cSayGrfTot := "Total Per�odo: "    

    // Sub-T�tulo das duas tabelas (Grid de Admitidos e Demitidos) 
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
    Private cAliasAdm   := GetNextAlias()   // Alias para usar na tabela tempor�ria
    Private aColunasAdm := {}               // Coluna de admitidos
    Private aCamposAdm  := {}               // Campos de admitidos
    Private oTableAdm

    // Grid demitidos
    Private cAliasDem   := GetNextAlias()   // Alias para usar na tabela tempor�ria
    Private aColunasDem := {}               // Coluna de Demitidos
    Private aCamposDem  := {}               // Campos de Admitidos
    Private oTableDem

    // Cria a tabela tempor�ria de Admitidos
    Processa({|| fTabelaAdm()}, "Admitidos...")

    // Cria a tabela tempor�ria de Demitidos
    Processa({|| fTabelaDem()}, "Demitidos...")

    // Popula ambas as tabelas tempor�rias
    Processa({|| fBuscaDados()}, "Processando...")
 
    // Cria a janela
    DEFINE MSDIALOG oDialog TITLE "An�lise de TurnOver"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
 
        // Criando a camada
        oFwLayer := FwLayer():New()
        oFwLayer:init(oDialog,.F.)
 
        // Adicionando 4 linhas (T�tulo, informa��es, Sub-t�tulo e tabela)
        oFWLayer:addLine("TIT", 006, .F.)                       // T�tulo
        oFWLayer:addLine("INF", 025, .F.)                       // Linha de informa��es (Gr�fico, informa��es do gr�fico e par�metros)
        oFWLayer:addLine("SBT", 005, .F.)                       // SubT�tulo (Admiss�es, Demiss�es)
        oFWLayer:addLine("TAB", 064, .F.)                       // Tabelas de informa��es (2)
 
        // Adicionando as colunas das linhas
        oFWLayer:addCollumn("TITULO",        080, .T.,  "TIT")  // T�tulos
        oFWLayer:addCollumn("BOTOES",        020, .T.,  "TIT")  // Bot�o sair

        oFWLayer:addCollumn("GRAFICO",       030, .T.,  "INF")  // Gr�fico
        oFWLayer:addCollumn("INFOS",         020, .T.,  "INF")  // Informa��es
        oFWLayer:addCollumn("PARAMS",        050, .T.,  "INF")  // Par�metros

        oFWLayer:addCollumn("SUBTITU1",      050, .T.,  "SBT")  // T�tulo das tabelas Admitido
        oFWLayer:addCollumn("SUBTITU2",      050, .T.,  "SBT")  // T�tulo das tabelas Demitido

        oFWLayer:addCollumn("ADMITIDOS",     050, .T.,  "TAB")  // Tabela de admitidos
        oFWLayer:addCollumn("DEMITIDOS",     050, .T.,  "TAB")  // Tabela de demitidos

        /*                  Criando os paineis
        **********************************************************/
        // Linha do t�tulo
        oPanTitle  := oFWLayer:GetColPanel("TITULO",     "TIT")  // T�tulo vai ficar na linha t�tulo
        oPanSair   := oFWLayer:GetColPanel("BOTOES",     "TIT")  // Bot�o sair vai ficar na linha do t�tulo

        // Linha de informa��es
        oPansGra   := oFWLayer:GetColPanel("GRAFICO",    "INF")  // Grafico vai ficar na linha de baixo, de informa��es
        oPansInf   := oFWLayer:GetColPanel("INFOS",      "INF")  // Informa��es do gr�fico vai ficar no final do na frente do g�fico
        oPansPar   := oFWLayer:GetColPanel("PARAMS",     "INF")  // Par�metros vai ficar no final do gr�fico

        // Linha do subt�tulo das tabelas
        oPansDTab1   := oFWLayer:GetColPanel("SUBTITU1",  "SBT") // Grafico vai ficar na linha de baixo, de informa��es
        oPansDTab2   := oFWLayer:GetColPanel("SUBTITU2",  "SBT") // Grafico vai ficar na linha de baixo, de informa��es

        // Linha das tabelas
        oPanAdmit  := oFWLayer:GetColPanel("ADMITIDOS",   "TAB") // Grid de admitidos
        oPanDemit  := oFWLayer:GetColPanel("DEMITIDOS",   "TAB") // Grid de demitidos
        
        
        /*         Inserindo as informa��es em cada painel
        **********************************************************/
        //T�tulos e SubT�tulos
        oSayTitulo := TSay():New(004, 004, {|| cSayTitulo}, oPanTitle, "",  oFontMod, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
        oSaySubTit := TSay():New(004, 95,  {|| cSaySubTit}, oPanTitle, "",  oFontModN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

        // Descri��o do gr�fico
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

        // t�tulo das tabelas
        oPansAdm  := TSay():New(010, 200,     {|| cSayAdm}, oPansDTab1, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oPansDem  := TSay():New(010, 200,     {|| cSayDem}, oPansDTab2, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , ) 

        //Criando os bot�es
        oBtnExcel := TButton():New(004, 030, "Exportar para" + CRLF + "Excel",  oPanSair,  {|| fGeraExcel(aFunExcel)}, nLargBtn2, 022, , oFontBtn, , .T., , , , , , ) 
        oBtnSair  := TButton():New(004, 110, "Fechar",                          oPanSair,  {|| oDialog:End()        }, nLargBtn,  022, , oFontBtn, , .T., , , , , , )


        /*         Gerando gr�fico com as informa��es
        **********************************************************/
        //Inst�ncia a classe
        oFWChart := FWChartFactory():New()
        oFWChart := oFWChart:getInstance(BARCHART) //BARCOMPCHART ; LINECHART ; PIECHART
        
        //Inicializa pertencendo a janela
        oFWChart:Init(oPansGra, .F., .F. )
        
        //Seta o t�tulo do gr�fico
        oFWChart:SetTitle("Gr�fico Comparativo", CONTROL_ALIGN_CENTER)  
        
        //Adiciona as s�ries, com as descri��es e valores
        oFWChart:addSerie("Admitidos no Per�odo", nTotalFun)
        oFWChart:addSerie("Demitidos no Per�odo", nTotalDem)
        
        //Define que a legenda ser� mostrada na esquerda
        oFWChart:setLegend( CONTROL_ALIGN_CENTER )
        
        //Seta a m�scara mostrada na r�gua
        oFWChart:cPicture := "@E 999,999,999,999,999.99"
        
        //Define as cores que ser�o utilizadas no gr�fico
        aAdd(aRand, {"084,120,164", "007,013,017"})
        aAdd(aRand, {"171,225,108", "017,019,010"})
        
        //Seta as cores utilizadas
        oFWChart:oFWChartColor:aRandom := aRand
        oFWChart:oFWChartColor:SetColor("Random")
        
        //Constr�i o gr�fico
        oFWChart:Build()
        
        
        /*                  Cria��o das grids 
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
| Autor: Vin�cius Reies                                               |
| Data:  11/01/2025                                                   |
| Desc:  Fun��o que cria a tabela temp�r�ria de admitidos             |
*---------------------------------------------------------------------*/
Static Function fTabelaAdm()

    //Campos da Tempor�ria (Admitidos)
    aAdd(aCamposAdm, { "MATRICULA" ,      "C", TamSX3("RA_MAT")[1],     0 })
    aAdd(aCamposAdm, { "NOME" ,           "C", TamSX3("RA_NOME")[1],    0 })
    aAdd(aCamposAdm, { "FUNCAO" ,         "C", TamSX3("RJ_DESC")[1],    0 })
    aAdd(aCamposAdm, { "CTCUSTO" ,        "C", TamSX3("CTT_DESC01")[1], 0 })
    aAdd(aCamposAdm, { "ADMISSAO" ,       "D", TamSX3("RA_ADMISSA")[1], 0 })
    aAdd(aCamposAdm, { "RECNO" ,          "N",                     16,  0 })

    //Cria a tabela tempor�ria (Admitidos)
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
| Autor: Vin�cius Reies                                               |
| Data:  12/01/2025                                                   |
| Desc:  Fun��o que cria a tabela temp�r�ria de demitidos             |
*---------------------------------------------------------------------*/
Static Function fTabelaDem()

    // Campos da Tempor�ria (Demitidos)
    aAdd(aCamposDem, { "MATRICULA" ,      "C", TamSX3("RA_MAT")[1],     0 })
    aAdd(aCamposDem, { "NOME" ,           "C", TamSX3("RA_NOME")[1],    0 })
    aAdd(aCamposDem, { "FUNCAO" ,         "C", TamSX3("RJ_DESC")[1],    0 })
    aAdd(aCamposDem, { "CTCUSTO" ,        "C", TamSX3("CTT_DESC01")[1], 0 })
    aAdd(aCamposDem, { "ADMISSAO" ,       "D", TamSX3("RA_ADMISSA")[1], 0 })
    aAdd(aCamposDem, { "DEMISSAO" ,       "D", TamSX3("RA_DEMISSA")[1], 0 })
    aAdd(aCamposDem, { "RECNO" ,          "N",                     16, 0 })

    // Cria a tabela tempor�ria (Demitidos)
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
| Autor: Vin�cius Reies                                               |
| Data:  14/01/2025                                                   |
| Desc:  Fun��o que cria as colunas da tabela de admitidos            |
*---------------------------------------------------------------------*/
Static Function fColsAdm()
    Local nAtual        := 0 
    Local aEstrut       := {}
    Local oColumn
     
    // Adicionando campos que ser�o mostrados na tela
    aAdd(aEstrut, {"MATRICULA",    "Matr�cula",           "C", TamSX3('RA_MAT')[01],     0, ""})
    aAdd(aEstrut, {"NOME",         "Nome",                "C", TamSX3('RA_NOME')[01],    0, ""})
    aAdd(aEstrut, {"FUNCAO",       "Fun��o",              "C", TamSX3('RJ_DESC')[01],    0, ""})
    aAdd(aEstrut, {"CTCUSTO",      "Centro de Custo",     "C", TamSX3('CTT_DESC01')[01], 0, ""})
    aAdd(aEstrut, {"ADMISSAO",     "Admiss�o",            "D", TamSX3('RA_ADMISSA')[01], 0, ""})
  
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

        // Se for o c�digo ou descri��o, adiciona a op��o de clique no cabe�alho
        If Alltrim(aEstrut[nAtual][1]) $ "MATRICULA;NOME;"
            oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "', '" +cAliasAdm+ "') }")
        EndIf

        // Adiciona a coluna
        aAdd(aColunasAdm, oColumn)
    Next
Return aColunasAdm


/*---------------------------------------------------------------------*
| Func:  fColsDem                                                     |
| Autor: Vin�cius Reies                                               |
| Data:  14/01/2025                                                   |
| Desc:  Fun��o que cria as colunas da tabela de demitidos            |
*---------------------------------------------------------------------*/
Static Function fColsDem()
    Local nAtual        := 0 
    Local aEstrut       := {}
    Local oColumn

    // Adicionando campos que ser�o mostrados na tela
    aAdd(aEstrut, {"MATRICULA",     "Matr�cula",        "C", TamSX3('RA_MAT')[01],     0, ""})
    aAdd(aEstrut, {"NOME",          "Nome",             "C", TamSX3('RA_NOME')[01],    0, ""})
    aAdd(aEstrut, {"FUNCAO",        "Fun��o",           "C", TamSX3('RJ_DESC')[01],    0, ""})
    aAdd(aEstrut, {"CTCUSTO",       "Centro de Custo",  "C", TamSX3('CTT_DESC01')[01], 0, ""})
    aAdd(aEstrut, {"ADMISSAO",      "Admiss�o",         "D", TamSX3('RA_ADMISSA')[01], 0, ""})
    aAdd(aEstrut, {"DEMISSAO",      "Demiss�o",         "D", TamSX3('RA_DEMISSA')[01], 0, ""})

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

        // Se for o c�digo ou descri��o, adiciona a op��o de clique no cabe�alho
        If Alltrim(aEstrut[nAtual][1]) $ "MATRICULA;NOME;"
            oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "', '" +cAliasDem+ "') }")
        EndIf

        // Adiciona a coluna
        aAdd(aColunasDem, oColumn)
    Next
Return aColunasDem

 
/*---------------------------------------------------------------------*
| Func:  fBuscaDados                                                  |
| Autor: Vin�cius Reies                                               |
| Data:  12/01/2025                                                   |
| Desc:  Fun��o que busca os dados dos func. e aplica nas tabelas     |
*---------------------------------------------------------------------*/
Static Function fBuscaDados()
    Local aArea        := FWGetArea()
    Local cQuery       := ""                        // Query para busca na SRA
    Local cDataDe      := FormataData(MV_PAR01, 5)  // Data De do par�metro formatada para tipo D do SQL
    Local cDataAt      := FormataData(MV_PAR02, 5)  // Data Ate do par�metro formatada para tipo D do SQL
    Local nAuxConta    := 0                         // Vari�vel auxiliar de conta
    Private cAliasAux  := ""                        // Auxiliar do Alias. Para trabalhar coom grava��o nas duas tabelas tempor�rias

    // Montagem da query para busca de informa��es
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

    // Inst�nciando a query
    TCQuery cQuery New Alias "SRA_TMP"

    // Definindo o formato dos valores do campo como data, ap�s consulta
    TcSetField("SRA_TMP", "RA_ADMISSA", "D")
    TcSetField("SRA_TMP", "RA_DEMISSA", "D")

    // Caso a query tenha informa��es
    If ! SRA_TMP->(EoF())
        
        // Definindo ponteiro no topo
        SRA_TMP->(DBGoTop())

        While ! SRA_TMP->(Eof())
            
            // Se funcion�rio for demitido, o Alias apontar� para demitidos
            cAliasAux := Iif(!Empty(SRA_TMP->RA_DEMISSA), cAliasDem, cAliasAdm )

            // incluindo valor na tabela tempor�ria com os resultados da query
            RecLock(cAliasAux, .T.)
                (cAliasAux)->MATRICULA := SRA_TMP->RA_MAT
                (cAliasAux)->NOME      := SRA_TMP->RA_NOME
                (cAliasAux)->FUNCAO    := SRA_TMP->RJ_DESC
                (cAliasAux)->CTCUSTO   := SRA_TMP->CTT_DESC01
                (cAliasAux)->ADMISSAO  := SRA_TMP->RA_ADMISSA

                // S� vai gravar demiss�o na tabela de demitidos ( ou seja, quando houver data de demiss�o )
                if !Empty(SRA_TMP->RA_DEMISSA)
                    (cAliasAux)->DEMISSAO  := SRA_TMP->RA_DEMISSA
                    // Adicionando registro de demitidos
                    nTotalDem++ 
                EndIf

                // Aplicando recno na tabela
                (cAliasAux)->RECNO  := SRA_TMP->SRAREC


            (cAliasAux)->(MsUnlock())

            aAdd(aFunExcel, {Alltrim(SRA_TMP->RA_MAT),Alltrim(SRA_TMP->RA_NOME),Alltrim(SRA_TMP->RJ_DESC),Alltrim(SRA_TMP->CTT_DESC01), DToC(SRA_TMP->RA_ADMISSA), Iif(!Empty(SRA_TMP->RA_DEMISSA), DToC(SRA_TMP->RA_DEMISSA), "")})

            // Adicionando n�mero de funcion�rios ao contador total
            nTotalFun++ 
            
            // Indo para pr�ximo registro
            SRA_TMP->(DbSkip())
        EndDo       

        // Auxiliar da opera��o para atribui��o de percentual
        nAuxConta := nTotalFun - nTotalDem

        // Aplicando valores para as informa��es do gr�fico
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
| Autor: Vin�cius Reies                                               |
| Data:  28/01/2025                                                   |
| Desc:  Fun��o para posicionar                                       |
*---------------------------------------------------------------------*/
Static Function fFunView(cAlias)
    Local aArea := FWGetArea()
    Local cFunc  := (cAlias)->MATRICULA + ' ' + Alltrim((cAlias)->NOME)
 
    // Se a pergunta for confirmada, abre a visualiza��o do colaborador
    If FWAlertYesNo("Deseja visualizar " + cFunc + "'?", "Continua?")

        DbSelectArea("SRA")
        SRA->(DbGoTo((cAlias)->RECNO))
       
        // Posiciona no funcion�rio e abre a visualiza��o
        Gpea010Vis("SRA", SRA->(RecNo()), 2)
    EndIf
 
    FWRestArea(aArea)
Return 


/*---------------------------------------------------------------------*
| Func:  fOrdena                                                       |
| Autor: Vin�cius Reies                                                |
| Data:  28/01/2025                                                    |
| Desc:  Fun��o para ordenar os campos por matricula ou descri��o      |
*---------------------------------------------------------------------*/
Static Function fOrdena(cCampo, cAlias)
    Default cCampo := ""
  
    // Pegando o �ndice conforme o campo
    cCampo := Alltrim(cCampo)

    If cCampo == "MATRICULA"
        nOrder := 1
    ElseIf cCampo == "NOME"
        nOrder := 2
    EndIf
  
    // Ordena pelo �ndice
    (cAlias)->(DbSetOrder(nOrder))
  
    // Se o �ltimo campo clicado � o mesmo, ir� mudar entre crescente / decrescente
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
| Autor: Vin�cius Reies                                                |
| Data:  28/01/2025                                                    |
| Desc:  Fun��o para atualizar a ordena��o                             |
*---------------------------------------------------------------------*/
Static Function fRefresh(cAlias)
    Local oObjecAux 

    // Se o alias posicionado for igual ao Alias de admitidos, ativa a primeira grid (Admitidos) (se n�o, demitidos)
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
| Autor: Vin�cius Reies                                                |
| Data:  28/01/2025                                                    |
| Desc:  Fun��o para gerar excel com todos colaboradores               |
*---------------------------------------------------------------------*/
Static Function fGeraExcel(aFunExcel)
	Local oFWMsExcel
    Local cArquivo    := GetTempPath() + "TurnOver_" + DToS(Date()) + cValToChar(Random(0, 50)) + cValToChar(Random(50, 99)) + ".xlsx" // Caminho para pasta tempor�ria com nome do arquivo
	Local nLinha  	  := 0					                                                                             // N�mero da linha
	Local nLinhas 	  := Len(aFunExcel)                                                                                  // N�mero de linhas do array
	Local nColuna 	  := 0					                                                                             // N�mero da coluna
	Local nColunas 	  := Len(aFunExcel[1])                                                                               // N�mero de colunas (supondo que todas as linhas t�m o mesmo n�mero de colunas)
	Local aRow 		  := {}					                                                                             // Armazenando linhas 
    Local cWorksheet  := "TurnOver"                                                                                      // Nome da WorkSheet
    Local cTableExcel := "An�lise de TurnOver referente a " + DToC(MV_PAR01) + " at� " + DToC(MV_PAR02)

	// Criando o objeto que ir� gerar o conte�do do Excel
    oFWMsExcel := FWMSExcelXLSX():New()
     
    // Aba 01 - Teste
    oFWMsExcel:AddworkSheet(cWorkSheet)

	// Criando a Tabela
	oFWMsExcel:AddTable(cWorkSheet,cTableExcel)
	
	// Criando Colunas
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Matricula", 			1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Nome", 				1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Fun��o", 				1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Cent. Custo", 	    1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Admiss�o", 			1,1)
	oFWMsExcel:AddColumn(cWorkSheet,cTableExcel, "Demiss�o", 			1,1)
    
	// Criando as Linhas
	For nLinha := 1 To nLinhas

		For nColuna := 1 To nColunas
            aAdd(aRow, aFunExcel[nLinha][nColuna])  // Adiciona o valor se n�o for vazio
		Next

		// Passando a linha no formato correto para o m�todo AddRow
		oFWMsExcel:AddRow(cWorkSheet, cTableExcel, aRow)
		aRow := {}
	Next
     
    // Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    // Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           // Abre uma nova conex�o com Excel
    oExcel:WorkBooks:Open(cArquivo)     // Abre a planilha
    oExcel:SetVisible(.T.)              // Visualiza a planilha

Return


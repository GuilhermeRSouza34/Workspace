//Bibliotecas
#Include "TOTVS.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} AEXCL003
Função para importar XMLs de Notas Fiscais de MEI emitidas pelo portal do gov.br
@type user function
@author Atilio
@since 30/01/2024
/*/

User Function AEXCL003()
    Local aArea        := FWGetArea()
    Local aPergs       := {}
    Local lContinua    := .T.
    Private cPastaErro := ""
    Private cPastaSuce := ""
    //Variáveis dos parâmetros informados pelo usuário
    Private cPastaXML  := "C:\xmls\" + Space(200)
    Private cTesPadrao := Space(TamSX3("D1_TES")[1])
    Private nTipoImpor := 1
    Private nQualProdu := 1
    Private cCodProdut := Space(TamSX3("D1_COD")[1])
    Private cDesProdut := ""
    Private nVldTomado := 1
    Private nTipoNum   := 1
    Private nInclForn  := 1

    //Adiciona os parâmetros que serão mostrados no ParamBox
    aAdd(aPergs, {1, "Pasta com os XMLs",     cPastaXML,  "", ".T.", "",    ".T.", 115, .T.}) // MV_PAR01
    aAdd(aPergs, {1, "TES Padrão",            cTesPadrao, "", ".T.", "SF4", ".T.", 040, .F.}) // MV_PAR02
    aAdd(aPergs, {2, "Tipo da Importação",    nTipoImpor, {"1=Pré Nota de Entrada", "2=Documento de Entrada"}, 080, ".T.", .T.}) // MV_PAR03
    aAdd(aPergs, {2, "Qual Produto",          nQualProdu, {"1=Pegar do campo abaixo", "2=Pegar o primeiro cadastrado no fornecedor (SA5)"}, 110, ".T.", .T.}) // MV_PAR04
    aAdd(aPergs, {1, "Código do Produto",     cCodProdut, "", ".T.", "SB1", ".T.", 080, .F.}) // MV_PAR05
    aAdd(aPergs, {2, "Valida Tomador",        nVldTomado, {"1=Sim, tomador ser igual a filial logada", "2=Não, importa sem validar"}, 115, ".T.", .T.}) // MV_PAR06
    aAdd(aPergs, {2, "Zero a Esquerda NF",    nTipoNum,   {"1=Sim, preencher conforme campo F1_DOC", "2=Não, deixar como vem no XML"}, 110, ".T.", .T.}) // MV_PAR07
    aAdd(aPergs, {2, "Incluir Fornecedor",    nInclForn,  {"1=Não incluir", "2=Sim, incluir sem mostrar tela", "3=Sim, abrir tela para incluir"}, 105, ".T.", .T.}) // MV_PAR08

    //Se a tela de parâmetros for confirmada
    If ParamBox(aPergs, "Informe os parâmetros", /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
        cPastaXML  := Alltrim(MV_PAR01)
        cTesPadrao := MV_PAR02
        nTipoImpor := Val(cValToChar(MV_PAR03))
        nQualProdu := Val(cValToChar(MV_PAR04))
        cCodProdut := MV_PAR05
        nVldTomado := Val(cValToChar(MV_PAR06))
        nTipoNum   := Val(cValToChar(MV_PAR07))
        nInclForn  := Val(cValToChar(MV_PAR08))

        //Se o último caractere da pasta não for \, adiciona
        If Right(cPastaXML, 1) != "\"
            cPastaXML += "\"
        EndIf

        //Valida se a pasta existe
        If ! ExistDir(cPastaXML)
            ExibeHelp("AEXCL003 - 001", "Pasta informada não existe", "Informe uma pasta que exista em seu computador")
            lContinua := .F.
        EndIf

        //Cria as pastas de erro e sucesso
        cPastaErro := cPastaXML + "erros\"
        cPastaSuce := cPastaXML + "ok\"
        MakeDir(cPastaErro)
        MakeDir(cPastaSuce)

        //Valida, se for Documento de Entrada, se a TES preenchida é válida
        If lContinua .And. nTipoImpor == 2
            //Se tiver vazia
            If Empty(cTesPadrao)
                ExibeHelp("AEXCL003 - 002", "TES vazia", "Para o tipo Documento de Entrada, é obrigatório informar uma TES")
                lContinua := .F.

            //Se for maior ou igual a 500 ou menor que 001
            ElseIf cTesPadrao >= "500" .Or. cTesPadrao < "001"
                ExibeHelp("AEXCL003 - 003", "TES inválida", "Utilize uma TES de Entrada (001 até 499)")
                lContinua := .F.

            //Senão
            Else
                DbSelectArea("SF4")
                SF4->(DbSetOrder(1)) //F4_FILIAL + F4_CODIGO

                //Se não conseguir encontrar a TES
                If ! SF4->(MsSeek(FWxFilial("SF4") + cTesPadrao))
                    ExibeHelp("AEXCL003 - 004", "TES não encontrada", "A TES informada (" + cTesPadrao + ") não foi encontrada no cadastro, utilize uma TES que exista!")
                    lContinua := .F.
                EndIf
            EndIf

        EndIf

        //Valida, se for Produto informado no parâmetro
        If lContinua .And. nQualProdu == 1
            //Se tiver vazia
            If Empty(cCodProdut)
                ExibeHelp("AEXCL003 - 005", "Produto Vazio", "Como foi usado para pegar o produto do parâmetro, preencha um código de produto válido")
                lContinua := .F.

            //Senão
            Else
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

                //Se não conseguir encontrar o produto
                If ! SB1->(MsSeek(FWxFilial("SB1") + cCodProdut))
                    ExibeHelp("AEXCL003 - 006", "Produto não encontrado", "O Produto informado (" + cCodProdut + ") não foi encontrado no cadastro, utilize um produto que exista!")
                    lContinua := .F.
                Else
                    cDesProdut := SB1->B1_DESC
                EndIf
            EndIf
        EndIf

        //Se todas as validações deram certo, aciona a montagem da temporária e da tela
        If lContinua
            fMontaTela()
        EndIf
    EndIf

    FWRestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Atilio
@since 30/01/2024
@version 1.0
@type function
/*/

Static Function fMontaTela()
    Local aArea       := GetArea()
    Local aCampos     := {}
    Local oTempTable  := Nil
    Local aColunas    := {}
    Local aSeek       := {}
    Local cFontPad    := 'Tahoma'
    Local oFontGrid   := TFont():New(cFontPad, /*uPar2*/, -14)
    //Janela e componentes
    Private oDlgMark
    Private oPanGrid
    Private oMarkBrowse
    Private cAliasTmp := GetNextAlias()
    Private aRotina   := MenuDef()
    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg := aTamanho[5]
    Private nJanAltu := aTamanho[6]
     
    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { 'OK',         'C',                    2, 0}) //Flag para marcação
    aAdd(aCampos, { 'NUMERO_NF',  'C',                    9, 0}) //Número da NF
    aAdd(aCampos, { 'NOME_ARQ',   'C',                  250, 0}) //Nome do Arquivo com a Pasta
    aAdd(aCampos, { 'ARQ_APENAS', 'C',                  250, 0}) //Somente nome do Arquivo
    aAdd(aCampos, { 'CONTEUDO',   'M',                   10, 0}) //Conteúdo
    aAdd(aCampos, { 'STATUS',     'C',                    1, 0}) //Status
    aAdd(aCampos, { 'DATA_EMISS', 'D',                    8, 0}) //Data Emissão
    aAdd(aCampos, { 'HORA_EMISS', 'C',                    8, 0}) //Hora Emissão
    aAdd(aCampos, { 'EMIT_CNPJ',  'C', TamSX3('A2_CGC')[1],     0}) //Emitente CNPJ
    aAdd(aCampos, { 'EMIT_NOME',  'C', TamSX3('A2_NOME')[1],    0}) //Emitente Nome
    aAdd(aCampos, { 'EMIT_END',   'C', TamSX3('A2_END')[1],     0}) //Emitente Endereço
    aAdd(aCampos, { 'EMIT_BAIRR', 'C', TamSX3('A2_BAIRRO')[1],  0}) //Emitente Bairro
    aAdd(aCampos, { 'EMIT_CEP',   'C', TamSX3('A2_CEP')[1],     0}) //Emitente CEP
    aAdd(aCampos, { 'EMIT_CIDAD', 'C', TamSX3('A2_COD_MUN')[1], 0}) //Emitente Cidade
    aAdd(aCampos, { 'EMIT_ESTAD', 'C', TamSX3('A2_EST')[1],     0}) //Emitente Estado
    aAdd(aCampos, { 'EMIT_FONE',  'C', TamSX3('A2_TEL')[1],     0}) //Emitente Fone
    aAdd(aCampos, { 'EMIT_EMAIL', 'C', TamSX3('A2_EMAIL')[1],   0}) //Emitente eMail
    aAdd(aCampos, { 'EMIT_CODIG', 'C', TamSX3('A2_COD')[1],     0}) //Emitente Código (SA2)
    aAdd(aCampos, { 'EMIT_LOJA',  'C', TamSX3('A2_LOJA')[1], 0}) //Emitente Loja (SA2)
    aAdd(aCampos, { 'EMIT_COND',  'C', TamSX3('A2_COND')[1], 0}) //Condição de Pagamento (SA2)
    aAdd(aCampos, { 'VLR_LIQUID', 'N',                   12, 2}) //Valor Líquido
    aAdd(aCampos, { 'SERV_DESCR', 'C',                  100, 0}) //Descrição do Serviço
    aAdd(aCampos, { 'TOMA_CNPJ',  'C',                   14, 0}) //Tomador CNPJ
    aAdd(aCampos, { 'TOMA_NOME',  'C',                   50, 0}) //Tomador Nome
    aAdd(aCampos, { 'TOMA_EMAIL', 'C',                   20, 0}) //Tomador eMail
    aAdd(aCampos, { 'OBSERVACAO', 'C',                  100, 0}) //Observação
    aAdd(aCampos, { 'PROD_COD',   'C',  TamSX3('B1_COD')[1], 0}) //Código do Produto
    aAdd(aCampos, { 'PROD_DESC',  'C',                   50, 0}) //Descrição do Produto

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("1", {"NUMERO_NF"})
    oTempTable:AddIndex("2", {"NOME_ARQ"})
    oTempTable:AddIndex("3", {"EMIT_CNPJ"})
    oTempTable:AddIndex("4", {"EMIT_NOME"})
    oTempTable:Create()  

    //Popula a tabela temporária
    Processa({|| fPopula()}, 'Processando...')

    //Adiciona as colunas que serão exibidas no FWMarkBrowse
    aColunas := fCriaCols()

    //Monta as pesquisas
    aAdd(aSeek, { "Numero da NF",     { { "", "C",   9, 0, "Numero da NF",     ""}                      }})
    aAdd(aSeek, { "Nome do Arquivo",  { { "", "C", 250, 0, "Nome do Arquivo",  ""}                      }})
    aAdd(aSeek, { "CNPJ do Emitente", { { "", "C",  14, 0, "CNPJ do Emitente", "@R 99.999.999/9999-99"} }})
    aAdd(aSeek, { "Nome do Emitente", { { "", "C",  50, 0, "Nome do Emitente", ""}                      }})
     
    //Criando a janela
    DEFINE MSDIALOG oDlgMark TITLE 'Informações das Notas Fiscais (MEI)' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Dados
        oPanGrid := tPanel():New(001, 001, '', oDlgMark, /*oFont*/, /*lCentered*/, /*uParam7*/, RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 1, (nJanAltu/2) - 1)
        oMarkBrowse := FWMarkBrowse():New()
        oMarkBrowse:SetAlias(cAliasTmp)                
        oMarkBrowse:SetDescription('Arquivos XML encontrados')
        oMarkBrowse:DisableFilter()
        oMarkBrowse:DisableConfig()
        oMarkBrowse:DisableSeek()
        oMarkBrowse:DisableReport()
        oMarkBrowse:DisableSaveConfig()
        oMarkBrowse:SetFontBrowse(oFontGrid)
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:AddLegend("Empty((cAliasTmp)->STATUS)", "GREEN",  "Registro pode ser importado")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '1'", "BLACK",  "Falha na conversão do XML em Objeto")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '2'", "RED",    "Sem a tag NFSE")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '3'", "ORANGE", "Sem a tag Informações NFSE")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '4'", "YELLOW", "Campo(s) obrigatório(s) não encontrado(s)")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '5'", "BLUE",   "Fornecedor não encontrado")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '6'", "PINK",   "Tomador não bate com empresa logada")
        oMarkBrowse:AddLegend("(cAliasTmp)->STATUS == '7'", "BROWN",  "Nenhum produto encontrado para o Fornecedor")
        oMarkBrowse:SetColumns(aColunas)
        oMarkBrowse:SetSeek(.T., aSeek)
        //oMarkBrowse:SetValid({|| Empty((cAliasTmp)->STATUS) }) //Não permite marcar registros que houveram algum tipo de falha
        oMarkBrowse:AllMark() 
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:Activate()
    ACTIVATE MsDialog oDlgMark CENTERED
    
    //Deleta a temporária e desativa a tela de marcação
    oTempTable:Delete()
    oMarkBrowse:DeActivate()
    
    RestArea(aArea)
Return

/*/{Protheus.doc} MenuDef
Botões usados no Browse
@author Atilio
@since 30/01/2024
@version 1.0
@type function
/*/

Static Function MenuDef()
    Local aRotina := {}
     
    //Criação das opções
    ADD OPTION aRotina TITLE 'Importar'    ACTION 'u_zExcl3Ok'           OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar'  ACTION 'VIEWDEF.AEXCL003'     OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'     ACTION 'u_zExcl3Lg'           OPERATION 2 ACCESS 0
Return aRotina

/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author Atilio
@since 30/01/2024
@version 1.0
@type function
/*/

Static Function fPopula()
    Local nTotal      := 0
    Local nAtual      := 0
    Local aArquivos   := {}
    Local aArqTemp    := {}
    Local cAviso      := ""
    Local cErro       := ""
    //Objetos dos nós do XML
    Local oNFMei      := Nil
    Local oNFSE       := Nil
    Local oInfoNF     := Nil
    Local oDataHora   := Nil
    Local oValores    := Nil
    Local oEmitente   := Nil
    Local oEmitEnder  := Nil
    Local oDPS        := Nil
    Local oInfDPS     := Nil
    Local oTomador    := Nil
    Local oServ       := Nil
    Local oServico    := Nil
    //Variáveis Gerais
    Local aSM0Data    := FWSM0Util():GetSM0Data(, cFilAnt, {'M0_CGC'})
	Local cEmpCNPJ    := aSM0Data[1][2]
    Local cStatus     := ""
    Local cObservacao := ""
    //Variáveis que vão ter o conteúdo de informações que irão para a temporária
    Local dDataEmiss  := sToD("")
    Local cHoraEmiss  := ""
    Local cNumeroNF   := ""
    Local nValorLiq   := 0
    Local cEmitCNPJ   := ""
    Local cEmitNome   := ""
    Local cEmitEnd    := ""
    Local cEmitBairr  := ""
    Local cEmitCEP    := ""
    Local cEmitCidad  := ""
    Local cEmitEstad  := ""
    Local cEmitFone   := ""
    Local cEmitEmail  := ""
    Local cEmitCodig  := ""
    Local cEmitLoja   := ""
    Local cEmitCond   := ""
    Local cDescServ   := ""
    Local cTomaCNPJ   := ""
    Local cTomaNome   := ""
    Local cTomaEmail  := ""
    Local cProdCod    := ""
    Local cProdDesc   := ""
    Local lPadAbrasf  := .F.

    //Busca os arquivos
    aDir(cPastaXML + "*.xml", aArquivos)
    
    //Se não encontrou, busca com Directory
    If Len(aArquivos) == 0
        aArqTemp := Directory(cPastaXML + "*.xml")
        For nAtual := 1 To Len(aArqTemp)
            aAdd(aArquivos, aArqTemp[nAtual][1])
        Next
    EndIf

    //Definindo o tamanho da régua
    nTotal := Len(aArquivos)
    ProcRegua(nTotal)

    //Abre as tabelas necessárias para as validações
    DbSelectArea("SA2")
    SA2->(DbSetOrder(3)) // A2_FILIAL + A2_CGC
    DbSelectArea("SA5")
    SA5->(DbSetOrder(1)) // A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO + A5_FABR + A5_FALOJA + A5_REFGRD

    //Percorre os arquivos
    For nAtual := 1 To Len(aArquivos)
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

        //Zera as variáveis que serão usadas para gravar na temporária
        cStatus     := ""
        cObservacao := ""
        dDataEmiss  := sToD("")
        cHoraEmiss  := ""
        cNumeroNF   := ""
        nValorLiq   := 0
        cEmitCNPJ   := ""
        cEmitNome   := ""
        cEmitEnd    := ""
        cEmitBairr  := ""
        cEmitCEP    := ""
        cEmitCidad  := ""
        cEmitEstad  := ""
        cEmitFone   := ""
        cEmitEmail  := ""
        cEmitCodig  := ""
        cEmitLoja   := ""
        cEmitCond   := ""
        cDescServ   := ""
        cTomaCNPJ   := ""
        cTomaNome   := ""
        cTomaEmail  := ""
        cProdCod    := ""
        cProdDesc   := ""
        lPadAbrasf  := .F.

        //Busca o conteúdo do XML
        cConteudo := fLeArquivo(cPastaXML + aArquivos[nAtual])

        //Transforma o Conteúdo XML em um Objeto
        cAviso := ""
        cErro  := ""
        oNFMei := XmlParser(cConteudo, "_", @cAviso, @cErro)

        //Se houve erro na conversão
        If ! Empty(cErro) .Or. ! Empty(cAviso)
            cStatus     := "1"
            cObservacao := "Observações XML: " + cErro + ". " + cAviso
        Else
            oNFMeiAux := oNFMei

            //Se tiver a tag COMPNFSE é padrão ABRASF
            If AttIsMemberOf(oNFMei, "_compnfse")
                lPadAbrasf := .T.
                oNFMeiAux := oNFMei:_compnfse
            EndIf

            //Verifica se tem a tag principal NFSE
            If AttIsMemberOf(oNFMeiAux, "_nfse")
                oNFSE := oNFMeiAux:_nfse

                //Verifica se tem a tag INFNFSE
                If AttIsMemberOf(oNFSE, "_infnfse")
                    oInfoNF := oNFSE:_infnfse
                    
                    //Se for padrão Abrasf
                    If lPadAbrasf .And. AttIsMemberOf(oInfoNF, "_dataemissao")
                        oDataHora := oInfoNF:_dataemissao

                    //Se veio a data e hora, busca as informações
                    ElseIf AttIsMemberOf(oInfoNF, "_dhproc")
                        oDataHora := oInfoNF:_dhproc
                    EndIf

                    //Se tem a data e hora
                    If ! Empty(oDataHora)
                        dDataEmiss := sToD(StrTran(Left(oDataHora:TEXT, 10), "-", ""))
                        cHoraEmiss := SubStr(oDataHora:TEXT, 12, 8)
                    EndIf

                    //Se for padrão Abrasf
                    If lPadAbrasf .And. AttIsMemberOf(oInfoNF, "_numero")
                        cNumeroNF := oInfoNF:_numero:TEXT

                    //Se tem a tag de número da nota, pega ela
                    ElseIf AttIsMemberOf(oInfoNF, "_nnfse")
                        cNumeroNF := oInfoNF:_nnfse:TEXT
                    EndIf

                    //Se for para preencher zeros a esquerda
                    If ! Empty(cNumeroNF) .And. nTipoNum == 1
                        cNumeroNF := PadL(cNumeroNF, TamSX3("F1_DOC")[1], "0")
                    EndIf

                    //Se for padrão Abrasf
                    If lPadAbrasf .And. AttIsMemberOf(oInfoNF, "_valoresnfse")
                        oValores := oInfoNF:_valoresnfse

                        //Se encontrou a tag de valor liquido
                        If AttIsMemberOf(oValores, "_valorliquidonfse")
                            nValorLiq := Val(oValores:_valorliquidonfse:TEXT)
                        EndIf

                    //Se tiver a tag de valores
                    ElseIf AttIsMemberOf(oInfoNF, "_valores")
                        oValores := oInfoNF:_valores

                        //Se encontrou a tag de valor liquido
                        If AttIsMemberOf(oValores, "_vliq")
                            nValorLiq := Val(oValores:_vliq:TEXT)
                        EndIf
                    EndIf

                    //Se tem a tag de emitente
                    If (lPadAbrasf .And. AttIsMemberOf(oInfoNF, "_prestadorservico")) .Or. AttIsMemberOf(oInfoNF, "_emit")
                        If lPadAbrasf
                            oEmitente := oInfoNF:_prestadorservico
                            oContato  := Nil
                            oIdentifi := Nil
                            oCpfCnpj  := Nil

                            If AttIsMemberOf(oEmitente, "_contato")
                                oContato  := oEmitente:_contato
                            EndIf

                            If AttIsMemberOf(oEmitente, "_identificacaoprestador")
                                oIdentifi := oEmitente:_identificacaoprestador

                                If AttIsMemberOf(oIdentifi, "_cpfcnpj")
                                    oCpfCnpj  := oIdentifi:_cpfcnpj
                                EndIf
                            EndIf

                            //Pega os campos principais
                            cEmitCNPJ := Iif(! Empty(oCpfCnpj) .And. AttIsMemberOf(oCpfCnpj, "_cnpj"),         oCpfCnpj:_cnpj:TEXT,         Iif(AttIsMemberOf(oCpfCnpj, "_cpf"),  oCpfCnpj:_cpf:TEXT,  ""))
                            cEmitNome := Iif(AttIsMemberOf(oEmitente, "_razaosocial"),                         oEmitente:_razaosocial:TEXT, "")
                            cEmitFone := Iif(! Empty(oContato) .And. AttIsMemberOf(oContato,  "_telefone"),    oContato:_telefone:TEXT,     "")
                            cEmitEmail:= Iif(! Empty(oContato) .And. AttIsMemberOf(oContato,  "_email"),       oContato:_email:TEXT,        "")

                            //Se tiver a tag de endereço
                            If AttIsMemberOf(oEmitente, "_endereco")
                                oEmitEnder := oEmitente:_endereco

                                //Monta os campos de endereço
                                cEmitEnd   := Iif(AttIsMemberOf(oEmitEnder, "_endereco"),           oEmitEnder:_endereco:TEXT,                   "")
                                cEmitBairr := Iif(AttIsMemberOf(oEmitEnder, "_bairro"),             oEmitEnder:_bairro:TEXT,                     "")
                                cEmitCEP   := Iif(AttIsMemberOf(oEmitEnder, "_cep"),                oEmitEnder:_cep:TEXT,                        "")
                                cEmitCidad := Iif(AttIsMemberOf(oEmitEnder, "_codigomunicipio"),    SubStr(oEmitEnder:_codigomunicipio:TEXT, 3), "")
                                cEmitEstad := Iif(AttIsMemberOf(oEmitEnder, "_uf"),                 oEmitEnder:_uf:TEXT,                         "")

                                //Se tiver número, adiciona na frente do endereço
                                If AttIsMemberOf(oEmitEnder, "_numero")
                                    cEmitEnd := Alltrim(cEmitEnd) + " - " + oEmitEnder:_numero:TEXT
                                EndIf
                            EndIf
                        Else
                            oEmitente := oInfoNF:_emit

                            //Pega os campos principais
                            cEmitCNPJ := Iif(AttIsMemberOf(oEmitente, "_cnpj"),  oEmitente:_cnpj:TEXT,  "")
                            cEmitNome := Iif(AttIsMemberOf(oEmitente, "_xnome"), oEmitente:_xnome:TEXT, "")
                            cEmitFone := Iif(AttIsMemberOf(oEmitente, "_fone"),  oEmitente:_fone:TEXT,  "")
                            cEmitEmail:= Iif(AttIsMemberOf(oEmitente, "_email"), oEmitente:_email:TEXT, "")

                            //Se tiver a tag de endereço
                            If AttIsMemberOf(oEmitente, "_endernac")
                                oEmitEnder := oEmitente:_endernac

                                //Monta os campos de endereço
                                cEmitEnd   := Iif(AttIsMemberOf(oEmitEnder, "_xlgr"),    oEmitEnder:_xlgr:TEXT,            "")
                                cEmitBairr := Iif(AttIsMemberOf(oEmitEnder, "_xbairro"), oEmitEnder:_xbairro:TEXT,         "")
                                cEmitCEP   := Iif(AttIsMemberOf(oEmitEnder, "_cep"),     oEmitEnder:_cep:TEXT,             "")
                                cEmitCidad := Iif(AttIsMemberOf(oEmitEnder, "_cmun"),    SubStr(oEmitEnder:_cmun:TEXT, 3), "")
                                cEmitEstad := Iif(AttIsMemberOf(oEmitEnder, "_uf"),      oEmitEnder:_uf:TEXT,              "")

                                //Se tiver número, adiciona na frente do endereço
                                If AttIsMemberOf(oEmitEnder, "_nro")
                                    cEmitEnd := Alltrim(cEmitEnd) + " - " + oEmitEnder:_nro:TEXT
                                EndIf
                            EndIf
                        EndIf

                        //Tira caracteres especiais do CNPJ
                        cEmitCNPJ := StrTran(cEmitCNPJ, "-", "")
                        cEmitCNPJ := StrTran(cEmitCNPJ, ".", "")
                        cEmitCNPJ := StrTran(cEmitCNPJ, "/", "")

                        //Se encontrou o fornecedor, pega o código e loja
                        If SA2->(MsSeek(FWxFilial("SA2") + cEmitCNPJ))
                            cEmitCodig := SA2->A2_COD
                            cEmitLoja  := SA2->A2_LOJA
                            cEmitCond  := SA2->A2_COND

                            //Se for para buscar o produto na SA5
                            If nQualProdu == 2

                                //Se conseguir posicionar na SA5 conforme o fornecedor, pega o primeiro cadastrado
                                If SA5->(MsSeek(FWxFilial("SA5") + cEmitCodig + cEmitLoja))
                                    cProdCod  := SA5->A5_PRODUTO
                                    cProdDesc := SA5->A5_NOMPROD

                                //Senão, marca como falha
                                Else
                                    cStatus     := "7"
                                    cObservacao := "Nenhum produto encontrado no cadastro para esse fornecedor (SA5)!"
                                EndIf
                            EndIf

                        //Senão, marca como falha
                        Else
                            If nInclForn == 1
                                cStatus     := "5"
                                cObservacao := "Fornecedor não encontrado no cadastro!"
                            Else
                                cObservacao := "Fornecedor não encontrado, mas haverá tentativa de inclusão"
                            EndIf
                            
                        EndIf
                    EndIf

                    //Se tem a tag DPS
                    If (lPadAbrasf .And. AttIsMemberOf(oInfoNF, "_declaracaoprestacaoservico")) .Or. AttIsMemberOf(oInfoNF, "_dps")
                        If lPadAbrasf
                            oDPS := oInfoNF:_declaracaoprestacaoservico
                        Else
                            oDPS := oInfoNF:_dps
                        EndIf

                        //Se tem a tag de informações DPS
                        If (lPadAbrasf .And. AttIsMemberOf(oDPS, "_infdeclaracaoprestacaoservico")) .Or. AttIsMemberOf(oDPS, "_infdps")
                            If lPadAbrasf
                                oInfDPS := oDPS:_infdeclaracaoprestacaoservico
                            Else
                                oInfDPS := oDPS:_infdps
                            EndIf

                            //Se tem a tag do tomador
                            If (lPadAbrasf .And. AttIsMemberOf(oInfDPS, "_tomador")) .Or. AttIsMemberOf(oInfDPS, "_toma")
                                If lPadAbrasf
                                    oTomador  := oInfDPS:_tomador
                                    oContato  := Nil
                                    oIdentifi := Nil
                                    oCpfCnpj  := Nil

                                    If AttIsMemberOf(oTomador, "_contato")
                                        oContato  := oTomador:_contato
                                    EndIf

                                    If AttIsMemberOf(oTomador, "_identificacaotomador")
                                        oIdentifi := oTomador:_identificacaotomador

                                        If AttIsMemberOf(oIdentifi, "_cpfcnpj")
                                            oCpfCnpj  := oIdentifi:_cpfcnpj
                                        EndIf
                                    EndIf

                                    //Busca as informações do tomador
                                    cTomaCNPJ   := Iif(! Empty(oCpfCnpj) .And. AttIsMemberOf(oCpfCnpj, "_cnpj"),  oCpfCnpj:_cnpj:TEXT,  "")
                                    cTomaNome   := Iif(AttIsMemberOf(oTomador, "_razaosocial"), oTomador:_razaosocial:TEXT, "")
                                    cTomaEmail  := Iif(! Empty(oContato) .And. AttIsMemberOf(oContato, "_email"), oContato:_email:TEXT, "")
                                Else
                                    oTomador := oInfDPS:_toma

                                    //Busca as informações do tomador
                                    cTomaCNPJ   := Iif(AttIsMemberOf(oTomador, "_cnpj"),  oTomador:_cnpj:TEXT,  "")
                                    cTomaNome   := Iif(AttIsMemberOf(oTomador, "_xnome"), oTomador:_xnome:TEXT, "")
                                    cTomaEmail  := Iif(AttIsMemberOf(oTomador, "_email"), oTomador:_email:TEXT, "")
                                EndIf

                                //Retira caracteres especiais do CNPJ
                                cTomaCNPJ := StrTran(cTomaCNPJ, "-", "")
                                cTomaCNPJ := StrTran(cTomaCNPJ, ".", "")
                                cTomaCNPJ := StrTran(cTomaCNPJ, "/", "")

                                //Se for para validar o tomador com a empresa logada
                                If nVldTomado == 1

                                    //Se não bater o CNPJ, marca como falha
                                    If Alltrim(cEmpCNPJ) != Alltrim(cTomaCNPJ)
                                        cStatus     := "6"
                                        cObservacao := "Tomador do XML não bate com a empresa logada (CNPJ " + Transform(cEmpCNPJ, "@R 99.999.999/9999-99") + ")!"
                                    EndIf
                                EndIf
                            EndIf

                            //Se for padrão Abrasf
                            If lPadAbrasf .And. AttIsMemberOf(oInfDPS, "_servico")
                                oServico := oInfDPS:_servico

                                If AttIsMemberOf(oServico, "_discriminacao")
                                    cDescServ := oServico:_discriminacao:TEXT
                                EndIf

                            //Se tiver a tag de serviço
                            ElseIf AttIsMemberOf(oInfDPS, "_serv")
                                oServ := oInfDPS:_serv

                                //Se tiver a tag com o texto do serviço
                                If AttIsMemberOf(oServ, "_cserv")
                                    oServico := oServ:_cserv

                                    //Se tiver a tag de descrição do serviço, armazena numa variável
                                    If AttIsMemberOf(oServico, "_xdescserv")
                                        cDescServ := oServico:_xdescserv:TEXT
                                    EndIf
                                EndIf
                            EndIf

                        EndIf
                    EndIf

                    //Se o produto for pra pegar do parâmetro digitado
                    If nQualProdu == 1
                        cProdCod  := cCodProdut
                        cProdDesc := cDesProdut
                    EndIf

                    //Se algum dos campos principais estiver vazio, marca como falha
                    If Empty(cStatus) .And. (Empty(dDataEmiss) .Or. Empty(cHoraEmiss) .Or. Empty(cNumeroNF) .Or. Empty(nValorLiq) .Or. Empty(cEmitCNPJ) .Or. Empty(cTomaCNPJ) .Or. Empty(cProdCod))
                        cStatus     := "4"
                        cObservacao := "Revise o XML, algumas informações não foram encontradas!"
                    EndIf

                //Senão, marca como falha
                Else
                    cStatus     := "3"
                    cObservacao := "Não encontrou a tag de Informações da NFSE"
                EndIf

            //Senão, marcará o arquivo como falha
            Else
                cStatus     := "2"
                cObservacao := "Não encontrou a tag NFSE"
            EndIf
        EndIf

        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->OK         := Space(2)
            (cAliasTmp)->NUMERO_NF  := cNumeroNF
            (cAliasTmp)->NOME_ARQ   := cPastaXML + aArquivos[nAtual]
            (cAliasTmp)->ARQ_APENAS := aArquivos[nAtual]
            (cAliasTmp)->CONTEUDO   := cConteudo
            (cAliasTmp)->STATUS     := cStatus
            (cAliasTmp)->DATA_EMISS := dDataEmiss
            (cAliasTmp)->HORA_EMISS := cHoraEmiss
            (cAliasTmp)->EMIT_CNPJ  := cEmitCNPJ
            (cAliasTmp)->EMIT_NOME  := cEmitNome
            (cAliasTmp)->EMIT_END   := cEmitEnd
            (cAliasTmp)->EMIT_BAIRR := cEmitBairr
            (cAliasTmp)->EMIT_CEP   := cEmitCEP
            (cAliasTmp)->EMIT_CIDAD := cEmitCidad
            (cAliasTmp)->EMIT_ESTAD := cEmitEstad
            (cAliasTmp)->EMIT_FONE  := cEmitFone
            (cAliasTmp)->EMIT_EMAIL := cEmitEmail
            (cAliasTmp)->EMIT_CODIG := cEmitCodig
            (cAliasTmp)->EMIT_LOJA  := cEmitLoja
            (cAliasTmp)->EMIT_COND  := cEmitCond
            (cAliasTmp)->VLR_LIQUID := nValorLiq
            (cAliasTmp)->SERV_DESCR := cDescServ
            (cAliasTmp)->TOMA_CNPJ  := cTomaCNPJ
            (cAliasTmp)->TOMA_NOME  := cTomaNome
            (cAliasTmp)->TOMA_EMAIL := cTomaEmail
            (cAliasTmp)->OBSERVACAO := cObservacao
            (cAliasTmp)->PROD_COD   := cProdCod
            (cAliasTmp)->PROD_DESC  := cProdDesc
        (cAliasTmp)->(MsUnlock())

    Next
    (cAliasTmp)->(DbGoTop())
Return

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao AEXCL003
@author Atilio
@since 30/01/2024
@version 1.0
/*/
  
Static Function ModelDef()
    Local oModel     := Nil
    Local oStTMP     := FWFormModelStruct():New()
    Local aCamposTmp := (cAliasTmp)->(DbStruct())
    Local aCampos    := {}
    Local nCampoAtu  := 0
    Local cCampoAtu  := ""
    Local cTipoAtu   := ""
    Local nTamanAtu  := 0
    Local nDecimAtu  := 0

    //Monta um array só com nome dos campos
    For nCampoAtu := 1 To Len(aCamposTmp)
        cCampoAtu := aCamposTmp[nCampoAtu][1]
        aAdd(aCampos, cCampoAtu)
    Next
       
    //Na estrutura, define os campos e a temporária
    oStTMP:AddTable(cAliasTmp, aCampos, "Temporaria")
    
    //Agora adiciona as informações dos campos no Model
    For nCampoAtu := 1 To Len(aCamposTmp)
        cCampoAtu  := aCamposTmp[nCampoAtu][1]
        cTipoAtu   := aCamposTmp[nCampoAtu][2]
        nTamanAtu  := aCamposTmp[nCampoAtu][3]
        nDecimAtu  := aCamposTmp[nCampoAtu][4]

        oStTmp:AddField(;
            Capital(cCampoAtu),;                                                                        // [01]  C   Titulo do campo
            Capital(cCampoAtu),;                                                                        // [02]  C   ToolTip do campo
            cCampoAtu,;                                                                                 // [03]  C   Id do Field
            cTipoAtu,;                                                                                  // [04]  C   Tipo do campo
            nTamanAtu,;                                                                                 // [05]  N   Tamanho do campo
            nDecimAtu,;                                                                                 // [06]  N   Decimal do campo
            Nil,;                                                                                       // [07]  B   Code-block de validação do campo
            Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
            {},;                                                                                        // [09]  A   Lista de valores permitido do campo
            .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp + "->" + cCampoAtu ),;                     // [11]  B   Code-block de inicializacao do campo
            .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
            .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .F.;                                                                                        // [14]  L   Indica se o campo é virtual
        )
    Next
       
    //Instanciando o modelo
    oModel := MPFormModel():New("zExcl003",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP)
    oModel:SetPrimaryKey({})
    oModel:SetDescription("Modelo de Dados do Cadastro")
    oModel:GetModel("FORMTMP"):SetDescription("Formulário do Cadastro")
Return oModel
  
/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao AEXCL003
@author Atilio
@since 30/01/2024
@version 1.0
/*/
  
Static Function ViewDef()
    Local oModel     := FWLoadModel("AEXCL003")
    Local oStTMPGer  := FWFormViewStruct():New()
    Local oStTMPEmi  := FWFormViewStruct():New()
    Local oStTMPTom  := FWFormViewStruct():New()
    Local oView      := Nil
    Local aCamposTmp := (cAliasTmp)->(DbStruct())
    Local aInfo      := {}
    Local nCampoAtu  := 0
    Local cCampoAtu  := ""
    Local cTipoAtu   := ""
    Local nTamanAtu  := 0
    Local nDecimAtu  := 0
    Local cMascara   := ""
    Local nPosicao   := 0
    Local cQualStruc := ""
    Local cTitCampo  := ""

    //Geral
    aAdd(aInfo, { 'NUMERO_NF',  'Número NF',             '1'})
    aAdd(aInfo, { 'NOME_ARQ',   'Nome do Arquivo',       '1'})
    aAdd(aInfo, { 'CONTEUDO',   'Conteúdo',              '1'})
    aAdd(aInfo, { 'STATUS',     'Status',                '1'})
    aAdd(aInfo, { 'DATA_EMISS', 'Data Emissão',          '1'})
    aAdd(aInfo, { 'HORA_EMISS', 'Hora Emissão',          '1'})
    aAdd(aInfo, { 'VLR_LIQUID', 'Valor Líquido',         '1'})
    aAdd(aInfo, { 'SERV_DESCR', 'Descrição do Serviço',  '1'})
    aAdd(aInfo, { 'OBSERVACAO', 'Observação',            '1'})
    aAdd(aInfo, { 'PROD_COD',   'Código do Produto',     '1'})
    aAdd(aInfo, { 'PROD_DESC',  'Descrição do Produto',  '1'})

    //Emitente
    aAdd(aInfo, { 'EMIT_CNPJ',  'CNPJ',                  '2'})
    aAdd(aInfo, { 'EMIT_NOME',  'Nome',                  '2'})
    aAdd(aInfo, { 'EMIT_END',   'Endereço',              '2'})
    aAdd(aInfo, { 'EMIT_BAIRR', 'Bairro',                '2'})
    aAdd(aInfo, { 'EMIT_CEP',   'CEP',                   '2'})
    aAdd(aInfo, { 'EMIT_CIDAD', 'Cidade',                '2'})
    aAdd(aInfo, { 'EMIT_ESTAD', 'Estado',                '2'})
    aAdd(aInfo, { 'EMIT_FONE',  'Fone',                  '2'})
    aAdd(aInfo, { 'EMIT_EMAIL', 'eMail',                 '2'})
    aAdd(aInfo, { 'EMIT_CODIG', 'Código Protheus (SA2)', '2'})
    aAdd(aInfo, { 'EMIT_LOJA',  'Loja Protheus (SA2)',   '2'})
    aAdd(aInfo, { 'EMIT_COND',  'Condi. Pagamento (SA2)','2'})

    //Tomador
    aAdd(aInfo, { 'TOMA_CNPJ',  'Tomador CNPJ',          '3'})
    aAdd(aInfo, { 'TOMA_NOME',  'Tomador Nome',          '3'})
    aAdd(aInfo, { 'TOMA_EMAIL', 'Tomador eMail',         '3'})

    //Agora adiciona as informações dos campos na View
    For nCampoAtu := 1 To Len(aCamposTmp)
        cCampoAtu  := aCamposTmp[nCampoAtu][1]
        cTipoAtu   := aCamposTmp[nCampoAtu][2]
        nTamanAtu  := aCamposTmp[nCampoAtu][3]
        nDecimAtu  := aCamposTmp[nCampoAtu][4]
        cTitCampo  := Capital(cCampoAtu)

        //Se for campo numérico, irá ter máscara
        If cTipoAtu == "N"
            cMascara := "@E 999,999,999,999,999.99"

        //Se for algum campo de CNPJ
        ElseIf cTipoAtu == "C" .And. "CNPJ" $ cCampoAtu
            cMascara := "@R 99.999.999/9999-99"

        //Senão, não tem máscara
        Else
            cMascara := ""
        EndIf

        //Busca o campo para ver em qual struct ele irá
        cQualStruc := "oStTMPGer"
        nPosicao := aScan(aInfo, {|x| Alltrim(x[1]) == Alltrim(cCampoAtu)})
        If nPosicao > 0
            If aInfo[nPosicao][3] == '2'
                cQualStruc := "oStTMPEmi"
            ElseIf aInfo[nPosicao][3] == '3'
                cQualStruc := "oStTMPTom"
            EndIf

            cTitCampo := aInfo[nPosicao][2] 
        EndIf
   
        //Adicionando campos da estrutura
        &(cQualStruc):AddField(;
            cCampoAtu,;                 // [01]  C   Nome do Campo
            StrZero(nCampoAtu, 2),;     // [02]  C   Ordem
            cTitCampo,;                 // [03]  C   Titulo do campo
            cTitCampo,;                 // [04]  C   Descricao do campo
            Nil,;                       // [05]  A   Array com Help
            cTipoAtu,;                  // [06]  C   Tipo do campo
            cMascara,;                  // [07]  C   Picture
            Nil,;                       // [08]  B   Bloco de PictTre Var
            Nil,;                       // [09]  C   Consulta F3
            .F.,;                       // [10]  L   Indica se o campo é alteravel
            Nil,;                       // [11]  C   Pasta do campo
            Nil,;                       // [12]  C   Agrupamento do campo
            Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;                       // [15]  C   Inicializador de Browse
            Nil,;                       // [16]  L   Indica se o campo é virtual
            Nil,;                       // [17]  C   Picture Variavel
            Nil;                        // [18]  L   Indica pulo de linha após o campo
        )
    Next
    
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_GER", oStTMPGer, "FORMTMP")
    oView:AddField("VIEW_EMI", oStTMPEmi, "FORMTMP")
    oView:AddField("VIEW_TOM", oStTMPTom, "FORMTMP")

    //Cria o controle de Abas
    oView:CreateFolder('ABAS')
    oView:AddSheet('ABAS', 'ABA_GER', 'Geral')
    oView:AddSheet('ABAS', 'ABA_EMI', 'Emitente')
    oView:AddSheet('ABAS', 'ABA_TOM', 'Tomador')

    //Cria os Box que serão vinculados as abas
    oView:CreateHorizontalBox('BOX_GER' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_GER')
    oView:CreateHorizontalBox('BOX_EMI' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_EMI')
    oView:CreateHorizontalBox('BOX_TOM' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_TOM')

    //Amarra as Abas aos Views de Struct criados
    oView:SetOwnerView('VIEW_GER', 'BOX_GER')
    oView:SetOwnerView('VIEW_EMI', 'BOX_EMI')
    oView:SetOwnerView('VIEW_TOM', 'BOX_TOM')
Return oView

/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author Atilio
@since 30/01/2024
@version 1.0
@type function
/*/

Static Function fCriaCols()
    Local nAtual       := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
    
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, { 'NUMERO_NF',  'Número da NF',         'C',                    9, 0, ''})
    aAdd(aEstrut, { 'NOME_ARQ',   'Caminho Completo',     'C',                  250, 0, ''})
    aAdd(aEstrut, { 'ARQ_APENAS', 'Arquivo',              'C',                  250, 0, ''})
    aAdd(aEstrut, { 'DATA_EMISS', 'Data Emissão',         'D',                    8, 0, ''})
    aAdd(aEstrut, { 'HORA_EMISS', 'Hora Emissão',         'C',                    8, 0, ''})
    aAdd(aEstrut, { 'EMIT_CNPJ',  'Emitente CNPJ',        'C',  TamSX3('A2_CGC')[1], 0, '@R 99.999.999/9999-99'})
    aAdd(aEstrut, { 'EMIT_NOME',  'Emitente Nome',        'C', TamSX3('A2_NOME')[1], 0, ''})
    aAdd(aEstrut, { 'VLR_LIQUID', 'Valor Líquido',        'N',                   12, 2, '@E 999,999,999.99'})
    aAdd(aEstrut, { 'SERV_DESCR', 'Descrição do Serviço', 'C',                  100, 0, ''})
    aAdd(aEstrut, { 'TOMA_CNPJ',  'Tomador CNPJ',         'C',                   14, 0, '@R 99.999.999/9999-99'})
    aAdd(aEstrut, { 'TOMA_NOME',  'Tomador Nome',         'C',                   50, 0, ''})
    aAdd(aEstrut, { 'PROD_COD',   'Produto',              'C',  TamSX3('B1_COD')[1], 0, ''})
    aAdd(aEstrut, { 'PROD_DESC',  'Descrição',            'C',                   50, 0, ''})
    aAdd(aEstrut, { 'OBSERVACAO', 'Observação',           'C',                  100, 0, ''})

    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])

        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas

/*/{Protheus.doc} User Function zExcl3Ok
Função acionada pelo botão continuar da rotina
@author Atilio
@since 30/01/2024
@version 1.0
@type function
/*/

User Function zExcl3Ok()
    Processa({|| fProcessa()}, 'Processando...')
Return

/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
@author Atilio
@since 30/01/2024
@version 1.0
@type function
/*/

Static Function fProcessa()
    Local aArea      := FWGetArea()
    Local cMarca     := oMarkBrowse:Mark()
    Local nAtual     := 0
    Local nTotal     := 0
    Local nTotMarc   := 0
    Local aCabec     := {}
    Local aItens     := {}
    Local aLinha     := {}
    Local cItem      := ""
    Local dDataHoje  := Date()
    Local cLog       := ''
	Local cPastaLogs := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local aLogErro   := {}
	Local nLinhaErro := 0
    Local lFalhou    := .F.
    Local cFunBkp    := FunName()
    Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
    
    //Define o tamanho da régua
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)

    //Se for abrir a tela de fornecedor, mostra a observação e ativa o atalho
    If nInclForn == 3
        FWAlertInfo("Quando a tela do Fornecedor abrir, para preencher os campos aperte a tecla -F7- !", "Preencher campos Fornecedor")
        SetKey(VK_F7, {|| u_zExcl3Fo()})
    EndIf
    
    //Percorrendo os registros
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        nAtual++
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
    
        //Caso esteja marcado
        If oMarkBrowse:IsMark(cMarca)
            nTotMarc++

            //Zera as variáveis
            lMsErroAuto := .F.
            aCabec      := {}
            aItens      := {}
            aLinha      := {}
            cItem       := PadL('', TamSX3('D1_ITEM')[01], '0')
            lFalhou     := .F.
            
            //Somente se o status tiver ok
            If Empty((cAliasTmp)->STATUS)
                //Se não tiver fornecedor
                If Empty((cAliasTmp)->EMIT_CODIG)
                    //Se for para tentar criar o fornecedor automaticamente
                    If nInclForn == 2

                        //Adiciona os campos
                        aDados := {}
                        aAdd(aDados, {"A2_NOME",     (cAliasTmp)->EMIT_NOME,    Nil})
                        aAdd(aDados, {"A2_CGC",      (cAliasTmp)->EMIT_CNPJ,    Nil})
                        aAdd(aDados, {"A2_END",      (cAliasTmp)->EMIT_END,     Nil})
                        aAdd(aDados, {"A2_BAIRRO",   (cAliasTmp)->EMIT_BAIRR,   Nil})
                        aAdd(aDados, {"A2_CEP",      (cAliasTmp)->EMIT_CEP,     Nil})
                        aAdd(aDados, {"A2_EST",      (cAliasTmp)->EMIT_ESTAD,   Nil})
                        aAdd(aDados, {"A2_COD_MUN",  (cAliasTmp)->EMIT_CIDAD,   Nil})
                        aAdd(aDados, {"A2_TEL",      (cAliasTmp)->EMIT_FONE,    Nil})
                        aAdd(aDados, {"A2_EMAIL",    (cAliasTmp)->EMIT_EMAIL,   Nil})

                        //Chama a inclusão
                        MsExecAuto({|x, y| MATA020(x, y)}, aDados, 3)

                        //Se houve erro, mostra a mensagem, e aborta o restante das operações
                        If lMsErroAuto
                            cPastaLogs := '\x_logs\'
                            cNomeErro  := 'erro_xml_sa2_' + (cAliasTmp)->NUMERO_NF + '_' + dToS(dDataHoje) + '_' + StrTran(Time(), ':', '-') + '.txt'

                            //Se a pasta de erro não existir, cria ela
                            If ! ExistDir(cPastaLogs)
                                MakeDir(cPastaLogs)
                            EndIf

                            //Pegando log do ExecAuto, percorrendo e incrementando o texto
                            aLogErro := GetAutoGRLog()
                            cTextoErro := ''
                            For nLinhaErro := 1 To Len(aLogErro)
                                cTextoErro += aLogErro[nLinhaErro] + CRLF
                            Next

                            //Criando o arquivo txt e incrementa o log
                            MemoWrite(cPastaLogs + cNomeErro, cTextoErro)
                            cLog += '- Falha ao incluir registro, documento [' + (cAliasTmp)->NUMERO_NF + '], do fornecedor [' + (cAliasTmp)->EMIT_NOME + '], não foi possível incluir o fornecedor, arquivo de log em ' + cPastaLogs + cNomeErro + CRLF
                            lFalhou := .T.

                        //Senão, atualiza o fornecedor
                        Else
                            RecLock(cAliasTmp, .F.)
                                (cAliasTmp)->EMIT_CODIG := SA2->A2_COD
                                (cAliasTmp)->EMIT_LOJA  := SA2->A2_LOJA
                            (cAliasTmp)->(MsUnlock())
                        EndIf
                        lMsErroAuto := .F.
                    
                    //Se for mostrar a tela
                    ElseIf nInclForn == 3
                        SetFunName("MATA020")
                        nClicouOk := FWExecView('Inclusão Fornecedor', 'MATA020', MODEL_OPERATION_INSERT)
                        SetFunName(cFunBkp)

                        //Se clicou no Ok, e for o mesmo fornecedor
                        If nClicouOk == 0 .And. SA2->A2_CGC == (cAliasTmp)->EMIT_CNPJ
                            RecLock(cAliasTmp, .F.)
                                (cAliasTmp)->EMIT_CODIG := SA2->A2_COD
                                (cAliasTmp)->EMIT_LOJA  := SA2->A2_LOJA
                            (cAliasTmp)->(MsUnlock())
                        Else
                            cLog += '- Falha ao incluir registro, documento [' + (cAliasTmp)->NUMERO_NF + '], do fornecedor [' + (cAliasTmp)->EMIT_NOME + '], não foi possível incluir o fornecedor via tela' + CRLF
                            lFalhou := .T.
                        EndIf
                    EndIf
                EndIf

                //Se não houve falha
                If ! lFalhou

                    //Cabeçalho do documento
                    aCabec := {}
                    aAdd(aCabec, {"F1_TIPO"    , "N"                      , Nil})
                    aAdd(aCabec, {"F1_FORMUL"  , "N"                      , Nil})
                    aAdd(aCabec, {"F1_DOC"     , (cAliasTmp)->NUMERO_NF   , Nil})
                    aAdd(aCabec, {"F1_SERIE"   , ""                       , Nil})
                    aAdd(aCabec, {"F1_EMISSAO" , (cAliasTmp)->DATA_EMISS  , Nil})
                    aAdd(aCabec, {"F1_FORNECE" , (cAliasTmp)->EMIT_CODIG  , Nil})
                    aAdd(aCabec, {"F1_LOJA"    , (cAliasTmp)->EMIT_LOJA   , Nil})
                    aAdd(aCabec, {"F1_ESPECIE" , "NFS"                    , Nil})
                    aAdd(aCabec, {"F1_COND"    , (cAliasTmp)->EMIT_COND   , Nil})

                    //Itens do Documento
                    cItem := Soma1(cItem)
                    aGets := {}
                    aAdd(aLinha, {"D1_ITEM"    , cItem     		         , Nil} )
                    aAdd(aLinha, {"D1_COD"     , (cAliasTmp)->PROD_COD   , Nil} )
                    aAdd(aLinha, {"D1_QUANT"   , 1                       , Nil} )
                    aAdd(aLinha, {"D1_VUNIT"   , (cAliasTmp)->VLR_LIQUID , Nil} )
                    aAdd(aLinha, {"D1_TOTAL"   , (cAliasTmp)->VLR_LIQUID , Nil} )
                    If ! Empty(cTesPadrao)
                        aAdd(aLinha, {"D1_TES" , cTesPadrao              , Nil} )
                    EndIf
                    aAdd(aItens, aClone(aLinha))

                    //Se for Pré Nota
                    If nTipoImpor == 1
                        MSExecAuto({|x, y, z| Mata140(x, y, z) }, aCabec, aItens, 3)

                    //Senão, vai ser documento de entrada
                    Else
                        MSExecAuto({|x, y, z| Mata103(x, y, z) }, aCabec, aItens, 3)
                    EndIf

                    //Se houve erro, gera o log
                    If lMsErroAuto
                        cPastaLogs := '\x_logs\'
                        cNomeErro  := 'erro_xml_' + (cAliasTmp)->NUMERO_NF + '_' + dToS(dDataHoje) + '_' + StrTran(Time(), ':', '-') + '.txt'

                        //Se a pasta de erro não existir, cria ela
                        If ! ExistDir(cPastaLogs)
                            MakeDir(cPastaLogs)
                        EndIf

                        //Pegando log do ExecAuto, percorrendo e incrementando o texto
                        aLogErro := GetAutoGRLog()
                        cTextoErro := ''
                        For nLinhaErro := 1 To Len(aLogErro)
                            cTextoErro += aLogErro[nLinhaErro] + CRLF
                        Next

                        //Criando o arquivo txt e incrementa o log
                        MemoWrite(cPastaLogs + cNomeErro, cTextoErro)
                        cLog += '- Falha ao incluir registro, documento [' + (cAliasTmp)->NUMERO_NF + '], do fornecedor [' + (cAliasTmp)->EMIT_NOME + '], arquivo de log em ' + cPastaLogs + cNomeErro + CRLF
                        lFalhou := .T.
                    Else
                        cLog += '+ Sucesso na inclusão do documento [' + (cAliasTmp)->NUMERO_NF + '], do fornecedor [' + (cAliasTmp)->EMIT_NOME + '];' + CRLF
                    EndIf
                EndIf
            Else
                lFalhou := .T.
                cLog += '- Falha ao incluir registro, documento [' + (cAliasTmp)->NUMERO_NF + '], do fornecedor [' + (cAliasTmp)->EMIT_NOME + '], pois: ' + (cAliasTmp)->OBSERVACAO + CRLF
            EndIf

            //Se houve falha, move para a subpasta de erros
            If lFalhou
                __CopyFile(cPastaXML + (cAliasTmp)->ARQ_APENAS, cPastaErro + (cAliasTmp)->ARQ_APENAS)

            //Senão, move para a pasta de sucesso
            Else
                __CopyFile(cPastaXML + (cAliasTmp)->ARQ_APENAS, cPastaSuce + (cAliasTmp)->ARQ_APENAS)
            EndIf

            //Apaga o arquivo original
            FErase(cPastaXML + (cAliasTmp)->ARQ_APENAS)
        EndIf
         
        (cAliasTmp)->(DbSkip())
    EndDo
    
    //Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
    ShowLog(cLog)
    oDlgMark:End()

    FWRestArea(aArea)
Return

/*/{Protheus.doc} fLeArquivo
Realiza a leitura do arquivo
@type  Static Function
@author Atilio
@since 30/01/2024
/*/

Static Function fLeArquivo(cArquivo)
    Local oFile
    Local cConteudo

    //Tenta abrir o arquivo e pegar o conteudo
    oFile := FwFileReader():New(cArquivo)
    If oFile:Open()

        //Se deu certo abrir o arquivo
        cConteudo  := oFile:FullRead()
    EndIf
    oFile:Close()
Return cConteudo

/*/{Protheus.doc} zExcl3Lg
Função que dispara o bloco de código para exibir a legenda
@type user function
@author Atilio
@since 30/01/2024
/*/

User Function zExcl3Lg()
    eVal(oMarkBrowse:oBrowse:aColumns[2]:bLDblClick)
Return

/*/{Protheus.doc} zExcl3Fo
Função que preenche os campos da tela de fornecedor via F7
@type user function
@author Atilio
@since 18/04/2024
/*/

User Function zExcl3Fo()
    Local aArea := FWGetArea()

    //Define os campos e atualiza a tela
    FWFldPut("A2_NOME",     (cAliasTmp)->EMIT_NOME )
    FWFldPut("A2_CGC",      (cAliasTmp)->EMIT_CNPJ )
    FWFldPut("A2_END",      (cAliasTmp)->EMIT_END  )
    FWFldPut("A2_BAIRRO",   (cAliasTmp)->EMIT_BAIRR)
    FWFldPut("A2_CEP",      (cAliasTmp)->EMIT_CEP  )
    FWFldPut("A2_EST",      (cAliasTmp)->EMIT_ESTAD)
    FWFldPut("A2_COD_MUN",  (cAliasTmp)->EMIT_CIDAD)
    FWFldPut("A2_TEL",      (cAliasTmp)->EMIT_FONE )
    FWFldPut("A2_EMAIL",    (cAliasTmp)->EMIT_EMAIL)
    GetDRefresh()

    FWRestArea(aArea)
Return


#include "Protheus.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// Fun��o Principal
User Function ZZCRUD()
    Local cOpcao := ""

    while cOpcao != "5"
        cOpcao := MsgBox("Escolha uma op��o: " + CRLF + ;
                        "1. Criar Tabela" + CRLF + ;
                        "2. Inserir Registro" + CRLF + ;
                        "3. Consultar Registros" + CRLF + ;
                        "4. Editar Registro" + CRLF + ;
                        "5. Sair", "Menu CRUD", , 1)
        Do Case
            Case cOpcao == "1"
                CriaTabela()
            Case cOpcao == "2"
                InserirRegistro()
            Case cOpcao == "3"
                ConsultarRegistros()
            Case cOpcao == "4"
                EditarRegistro()
            Case cOpcao == "5"
                MsgInfo("Saindo...", "Aviso")
            Otherwise
                MsgStop("Op��o inv�lida!", "Erro")
        EndCase
    EndDo

Return

// Fun��o para criar tabela no banco de dados
Static Function CriarTabela()
    Local aCampos := { ;
        {"ZZCOD", "C", 10, 0}, ; // Codigo (Caractere, tamanho 10)
        {"ZZDESC", "C", 50, 0}, ; // Descri��o (Caractere, tamanho 50)
    }

    If DbCreate("ZZTESTE", aCampos, "TOPCONN")
        MsgInfo("Tabela criada com sucesso!", "Aviso")
    Else
        MsgStop("Erro ao criar tabela!", "Erro")
    EndIf
Return

// Fun��o para inserir novo registro na tabela
Static Function InserirRegistro()
    Local cCodigo := ""
    Local cDescricao := ""

    // Campos para solicitar dados aos usuarios
    cCodigo := InputBox("Informe o c�digo:", "Inserir Registro")
    cDescricao := InputBox("Informe a descri��o:", "Inserir Registro")

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbAppend()
    Field->ZZCOD := cCodigo
    Field->ZZDESC := cDescricao
    DbCommit()
    DbCloseArea()

    MsgInfo("Registro inserido com sucesso!", "Confirma��o")
Return

// Fun��o para consultar registros na tabela
Static Function ConsultarRegistros()
    Local cResultado := ""

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbGoTop()

    Do While !Eof()
        cResultado += "C�digo: " + Field->ZZCOD + " | Descri��o: " + Field->ZZDESC + CRLF
        DbSkip()
    EndDo

    DbCloseArea()

    If Empty(cResultado)
        MsgInfo("Nenhum registro encontrado!", "Aviso")
    Else
        MsgInfo(cResultado, "Registros")
    EndIf

Return

// Fun��o para editar um registro na tabela
Static Function EditarRegistro()
    Local cCodigo := ""
    Local cDescricao := ""

    // Solicitar c�digo do registro a ser editado
    cCodigo := InputBox("Informe o c�digo do registro a ser editado:", "Editar Registro")

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbGoTop()
    Do While !Eof()
        If Field->ZZCOD == cCodigo
            cNovaDescricao := InputBox("Informe a nova descri��o:", "Editar Registro")
            Field->ZZDESC := cNovaDescricao
            DbCommit()
            MsgInfo("Registro editado com sucesso!", "Confirma��o")
            DbCloseArea()
            Return
        EndIf
        DbSkip()
    EndDo

    DbCloseArea()
    MsgStop("Registro n�o encontrado!", "Erro")
Return

// Fun��o para excluir uym registro
Static Function ExcluirRegistro()
    Local cCodigo := ""

    // Solicitar c�digo do registro a ser exclu�do
    cCodigo := InputBox("Informe o c�digo do registro a ser exclu�do:", "Excluir Registro")

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbGoTop()

    Do While!Eof()
        If Field->ZZCOD == cCodigo
            DbDelete()
            DbCommit()
            MsgInfo("Registro exclu�do com sucesso!", "Confirma��o")
            DbCloseArea()
            Return
        EndIf
        DbSkip()
    EndWhile
    
    DbCloseArea()
    MsgStop("Registro n�o encontrado!", "Erro")
Return
    
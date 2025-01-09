
#include "Protheus.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// Função Principal
User Function ZZCRUD()
    Local cOpcao := ""

    while cOpcao != "5"
        cOpcao := MsgBox("Escolha uma opção: " + CRLF + ;
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
                MsgStop("Opção inválida!", "Erro")
        EndCase
    EndDo

Return

// Função para criar tabela no banco de dados
Static Function CriarTabela()
    Local aCampos := { ;
        {"ZZCOD", "C", 10, 0}, ; // Codigo (Caractere, tamanho 10)
        {"ZZDESC", "C", 50, 0}, ; // Descrição (Caractere, tamanho 50)
    }

    If DbCreate("ZZTESTE", aCampos, "TOPCONN")
        MsgInfo("Tabela criada com sucesso!", "Aviso")
    Else
        MsgStop("Erro ao criar tabela!", "Erro")
    EndIf
Return

// Função para inserir novo registro na tabela
Static Function InserirRegistro()
    Local cCodigo := ""
    Local cDescricao := ""

    // Campos para solicitar dados aos usuarios
    cCodigo := InputBox("Informe o código:", "Inserir Registro")
    cDescricao := InputBox("Informe a descrição:", "Inserir Registro")

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbAppend()
    Field->ZZCOD := cCodigo
    Field->ZZDESC := cDescricao
    DbCommit()
    DbCloseArea()

    MsgInfo("Registro inserido com sucesso!", "Confirmação")
Return

// Função para consultar registros na tabela
Static Function ConsultarRegistros()
    Local cResultado := ""

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbGoTop()

    Do While !Eof()
        cResultado += "Código: " + Field->ZZCOD + " | Descrição: " + Field->ZZDESC + CRLF
        DbSkip()
    EndDo

    DbCloseArea()

    If Empty(cResultado)
        MsgInfo("Nenhum registro encontrado!", "Aviso")
    Else
        MsgInfo(cResultado, "Registros")
    EndIf

Return

// Função para editar um registro na tabela
Static Function EditarRegistro()
    Local cCodigo := ""
    Local cDescricao := ""

    // Solicitar código do registro a ser editado
    cCodigo := InputBox("Informe o código do registro a ser editado:", "Editar Registro")

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbGoTop()
    Do While !Eof()
        If Field->ZZCOD == cCodigo
            cNovaDescricao := InputBox("Informe a nova descrição:", "Editar Registro")
            Field->ZZDESC := cNovaDescricao
            DbCommit()
            MsgInfo("Registro editado com sucesso!", "Confirmação")
            DbCloseArea()
            Return
        EndIf
        DbSkip()
    EndDo

    DbCloseArea()
    MsgStop("Registro não encontrado!", "Erro")
Return

// Função para excluir uym registro
Static Function ExcluirRegistro()
    Local cCodigo := ""

    // Solicitar código do registro a ser excluído
    cCodigo := InputBox("Informe o código do registro a ser excluído:", "Excluir Registro")

    DbUseArea(.T., "TOPCONN", "ZZTESTE", .T., .T. )
    DbGoTop()

    Do While!Eof()
        If Field->ZZCOD == cCodigo
            DbDelete()
            DbCommit()
            MsgInfo("Registro excluído com sucesso!", "Confirmação")
            DbCloseArea()
            Return
        EndIf
        DbSkip()
    EndWhile
    
    DbCloseArea()
    MsgStop("Registro não encontrado!", "Erro")
Return
    
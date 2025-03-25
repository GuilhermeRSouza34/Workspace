#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"

/*/{Protheus.doc} MonitorEstoque
Funcao para monitoramento automatico de niveis de estoque
@type function
@author Guilherme Souza
@since 2025
/*/
User Function MonitorEstoque()
    Local aArea      := GetArea()
    Local cQuery     := ""
    Local cAlias     := GetNextAlias()
    Local nMinimo    := 0
    Local nAtual     := 0
    Local cProduto   := ""
    Local cDescricao := ""
    Local cMensagem  := ""
    Local aEmails    := {"gestor.estoque@empresa.com.br"}
    Local lEnviou    := .F.
    Local oRelatorio
    
    Private lMsErroAuto := .F.
    
    // Prepara ambiente caso seja job
    If Select("SX2") <= 0
        PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST"
    EndIf
    
    // Query para buscar produtos com estoque abaixo do minimo
    cQuery := " SELECT B1_COD, B1_DESC, B1_EMIN, B2_QATU "
    cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
    cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 ON "
    cQuery += " B1_COD = B2_COD "
    cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
    cQuery += " AND SB2.D_E_L_E_T_ = ' ' "
    cQuery += " AND B2_QATU <= B1_EMIN "
    
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
    
    While !(cAlias)->(Eof())
        cProduto   := (cAlias)->B1_COD
        cDescricao := (cAlias)->B1_DESC
        nMinimo    := (cAlias)->B1_EMIN
        nAtual     := (cAlias)->B2_QATU
        
        // Monta mensagem de alerta
        cMensagem := "Alerta de Estoque Baixo" + CRLF + CRLF
        cMensagem += "Produto: " + cProduto + " - " + cDescricao + CRLF
        cMensagem += "Estoque Mínimo: " + cValToChar(nMinimo) + CRLF
        cMensagem += "Estoque Atual: " + cValToChar(nAtual) + CRLF
        
        // Envia email de alerta
        lEnviou := U_EnviaEmail(aEmails, "Alerta de Estoque Baixo - " + cProduto, cMensagem)
        
        // Gera log
        If lEnviou
            U_GravaLog("ESTOQUE", "Alerta enviado para produto " + cProduto)
            
            // Gera relatorio do produto
            oRelatorio := estoque.RelatorioMovEstoque():new()
            oRelatorio:setFiltros(FirstDay(Date()), LastDay(Date()), cProduto, "", "")
            oRelatorio:processar()
            oRelatorio:exportarExcel()
        EndIf
        
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    RestArea(aArea)
    
    // Fecha ambiente se foi job
    If Type("cFilAnt") == "U"
        RESET ENVIRONMENT
    EndIf
    
Return

/*/{Protheus.doc} EnviaEmail
Funcao para envio de email
@type function
@author Guilherme Souza
@since 2025
@param aTo, array, Array com emails dos destinatarios
@param cAssunto, character, Assunto do email
@param cCorpo, character, Corpo do email
@return logical, Verdadeiro se enviou com sucesso
/*/
User Function EnviaEmail(aTo, cAssunto, cCorpo)
    Local oMail
    Local lRet := .F.
    
    oMail := TMailManager():New()
    oMail:Init("", "smtp.empresa.com.br", "usuario@empresa.com.br",
               "senha", 0, 25)
    
    If oMail:SmtpConnect()
        If oMail:SendMail("monitor.estoque@empresa.com.br", aTo,
                         cAssunto, cCorpo)
            lRet := .T.
        EndIf
        oMail:SmtpDisconnect()
    EndIf
    
Return lRet

/*/{Protheus.doc} GravaLog
Funcao para gravacao de log
@type function
@author Guilherme Souza
@since 2025
@param cTipo, character, Tipo do log
@param cMensagem, character, Mensagem do log
/*/
User Function GravaLog(cTipo, cMensagem)
    Local aArea    := GetArea()
    Local cTabela  := "ZLG"
    Local cChave   := ""
    Local aVetor   := {}
    
    DbSelectArea("ZLG")
    RecLock("ZLG", .T.)
    ZLG->ZLG_FILIAL := xFilial("ZLG")
    ZLG->ZLG_DATA   := Date()
    ZLG->ZLG_HORA   := Time()
    ZLG->ZLG_TIPO   := cTipo
    ZLG->ZLG_MSG    := cMensagem
    MsUnlock()
    
    RestArea(aArea)
Return
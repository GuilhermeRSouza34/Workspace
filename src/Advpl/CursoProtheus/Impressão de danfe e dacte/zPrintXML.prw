#Include 'totvs.ch'

/*/{Protheus.doc} zPrintXML
    Realiza impressao de danfe baseado no XML
    > Video de demonstracao da rotina: https://youtu.be/XAmbw_xdVSY

    @type  Function
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 26/08/2024
    @version 1.0
    @example
        u_zPrintXML()
    @see Links Totvs
            https://centraldeatendimento.totvs.com/hc/pt-br/articles/360025397031-MP-SIGACOM-Documento-de-Entrada-Rotina-Autom%C3%A1tica-MATA103-EXECAUTO-
            https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=516629672
            https://tdn.totvs.com/pages/releaseview.action?pageId=6085187
/*/    
User Function zPrintXML()
      
    Local aArea := FWGetArea()

    FWMsgRun( ,;
              {|| fAcionaPainel() },;
              "Aguarde",;
              "Carregando arquivos...";
            )

    FWRestArea(aArea)
Return 

/*/{Protheus.doc} fAcionaPainel
    Apresenta painal para impressao dos documentos
    @type  Static Function
    @author Sulivan Simoes (sulivansimoes@gmail.com)
    @since 26/08/2024
    @version 1.0    
/*/
Static Function fAcionaPainel()

    Local oPainel:= zPainelXML():New()
    oPainel:OpenWindow()
    
    FreeObj(oPainel)
Return  

//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zImgProd
Realiza a importa��o de imagens para o reposit�rio do Protheus
@type  Function
@author Atilio
@since 07/05/2021
@version version
@obs Essa fun��o executa a importa��o para o arquivo SIGAADV.BMR, se necess�rio altere o nome do
    Reposit�rio na linha 59

    As extens�es de imagens validadas s�o .jpg, .png e .bmp, se necess�rio � poss�vel alterar tamb�m
@see https://tdn.totvs.com/pages/releaseview.action?pageId=240977325
/*/

User Function zImgProd()
    Local aArea   := GetArea()
    Local cDirIni := "C:\importacao"
    Local cTipArq := ""
    Local cTitulo := "Selecione a pasta para importar imagens dos produtos"
    Local lSalvar := .F.
    Local cPasta  := ""
 
    //Chama a fun��o para buscar a pasta
    cPasta := tFileDialog(;
        cTipArq,;                  // Filtragem de tipos de arquivos que ser�o selecionados
        cTitulo,;                  // T�tulo da Janela para sele��o dos arquivos
        ,;                         // Compatibilidade
        cDirIni,;                  // Diret�rio inicial da busca de arquivos
        lSalvar,;                  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
        GETF_RETDIRECTORY;         // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
    )

    //Se foi confirmado e existe uma pasta
    If ! Empty(cPasta)
        cPasta := Alltrim(cPasta)

        //Se o �ltimo caractere n�o for uma barra, adiciona
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf

        Processa({|| fImporta(cPasta) }, "Importando imagens para o reposit�rio...")	
    EndIf
 
    RestArea(aArea)
Return

Static Function fImporta(cDiretor)
	Local aFiles    := {} //Array com os arquivos que ser�o processados
	Local cNomeArq  := "" //Nome do arquivo completo com extens�o, por exemplo, F00001.jpg
	Local cNomeRep  := "" //Nome do arquivo que ser� salvo no reposit�rio, por exemplo, F00001
	Local cCodProd  := ""
	Local lDeuCerto := .F.
	Local oReposit
	Local oDlgImp
	Local cMsg      := ""
	Local nArqAtu
    Local cDirCerto := cDiretor + "importados\"
    Local cDirTemp  := GetTempPath()
    Local cNomeLog  := ""
	
    //Se a pasta de importados n�o existir, cria
    If ! ExistDir(cDirCerto)
        MakeDir(cDirCerto)
    EndIf

    //Busca todos os arquivos dentro da pasta
	aFiles := Directory(cDiretor + "*.*", "")

    //Define o reposit�rio como o SIGAADV
	SetRepName("SIGAADV")

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD

    //Monta uma dialog de 1 pixel, apenas para poder instanciar um reposit�rio
	DEFINE MSDIALOG oDlgImp TITLE "Importa��o - Reposit�rio de Imagens" FROM 000, 000  TO 001, 001 PIXEL
    
        //Instancia um repositorio
		@ 000,000 REPOSITORY oReposit SIZE 0,0 OF oDlgImp
        
        //Define o tamanho da r�gua conforme a quantidade de arquivos
		ProcRegua(Len(aFiles))

        //Percorre todos os arquivos
		For nArqAtu := 1 To Len(aFiles)

            //Pega o nome do arquivo atual
            cNomeArq := aFiles[nArqAtu][1]

            //Incrementa a r�gua de processamento
			IncProc("Analisando arquivo " + cValToChar(nArqAtu) + " de " + cValToChar(Len(aFiles)) + " (" + cNomeArq + ")...")
            
            //Se for jpg, png ou bmp
            If ".JPG" $ Upper(cNomeArq) .Or. ".PNG" $ Upper(cNomeArq) .Or. ".BMP" $ Upper(cNomeArq)

                //O c�digo do produto ser� o nome todo em maiusculo e sem a extens�o
	        	cCodProd  := Upper(AllTrim(cNomeArq))
	        	cCodProd  := SubStr(cCodProd, 1, At('.', cCodProd) - 1)
	        	cNomeRep  := cCodProd 
			    
			    //Se conseguir posicionar no Produto
			    If SB1->(DbSeek(xFilial("SB1")+cCodProd))

                    //Se o arquivo j� existir no reposit�rio, exclui
					If oReposit:ExistBmp(cNomeRep)
						oReposit:DeleteBmp(cNomeRep)
					EndIf
					
                    //Chama a inser��o da imagem no reposit�rio
					lDeuCerto  := .F.
					oReposit:InsertBmp( cDiretor + cNomeArq , cNomeRep , @lDeuCerto )

                    //Se deu certo
                    If lDeuCerto
                        cMsg += "* Arquivo inclu�do: " + cNomeArq + CRLF

                        //Atualiza o cadastro de produtos com o nome da imagem
                        RecLock("SB1", .F.)
                            SB1->B1_BITMAP := cNomeRep
                        SB1->(MsUnlock())
						
                        //Copia o arquivo para a subpasta
                        FRename(cDiretor + cNomeArq, cDirCerto + cNomeArq)
                    Else
  						cMsg += "* Erro ao incluir: " + cNomeArq + CRLF
					EndIf
				
				Else
					cMsg+="- Produto " + cCodProd + " n�o encontrado na base;"+CRLF
			    EndIf
			    
			EndIf
		Next
	
    //Ao abrir a dialog, j� fecha ela
	ACTIVATE MSDIALOG oDlgImp CENTERED ON INIT (oDlgImp:End()) 

	//Se tiver mensagem
	If ! Empty(cMsg)
        //Define o nome do log que ser� gravado
        cNomeLog := "log_zimgprod_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".log"

        //Grava na tempor�ria do Windows
        MemoWrite(cDirTemp + cNomeLog, cMsg)

        //Abre o arquivo gerado
        ShellExecute("OPEN", cNomeLog, "", cDirTemp, 1)
	EndIf
    
    //Fecha o reposit�rio de imagens
	FechaReposit()
Return

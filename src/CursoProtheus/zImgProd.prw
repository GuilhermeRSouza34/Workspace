//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zImgProd
Realiza a importação de imagens para o repositório do Protheus
@type  Function
@author Atilio
@since 07/05/2021
@version version
@obs Essa função executa a importação para o arquivo SIGAADV.BMR, se necessário altere o nome do
    Repositório na linha 59

    As extensões de imagens validadas são .jpg, .png e .bmp, se necessário é possível alterar também
@see https://tdn.totvs.com/pages/releaseview.action?pageId=240977325
/*/

User Function zImgProd()
    Local aArea   := GetArea()
    Local cDirIni := "C:\importacao"
    Local cTipArq := ""
    Local cTitulo := "Selecione a pasta para importar imagens dos produtos"
    Local lSalvar := .F.
    Local cPasta  := ""
 
    //Chama a função para buscar a pasta
    cPasta := tFileDialog(;
        cTipArq,;                  // Filtragem de tipos de arquivos que serão selecionados
        cTitulo,;                  // Título da Janela para seleção dos arquivos
        ,;                         // Compatibilidade
        cDirIni,;                  // Diretório inicial da busca de arquivos
        lSalvar,;                  // Se for .T., será uma Save Dialog, senão será Open Dialog
        GETF_RETDIRECTORY;         // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
    )

    //Se foi confirmado e existe uma pasta
    If ! Empty(cPasta)
        cPasta := Alltrim(cPasta)

        //Se o último caractere não for uma barra, adiciona
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf

        Processa({|| fImporta(cPasta) }, "Importando imagens para o repositório...")	
    EndIf
 
    RestArea(aArea)
Return

Static Function fImporta(cDiretor)
	Local aFiles    := {} //Array com os arquivos que serão processados
	Local cNomeArq  := "" //Nome do arquivo completo com extensão, por exemplo, F00001.jpg
	Local cNomeRep  := "" //Nome do arquivo que será salvo no repositório, por exemplo, F00001
	Local cCodProd  := ""
	Local lDeuCerto := .F.
	Local oReposit
	Local oDlgImp
	Local cMsg      := ""
	Local nArqAtu
    Local cDirCerto := cDiretor + "importados\"
    Local cDirTemp  := GetTempPath()
    Local cNomeLog  := ""
	
    //Se a pasta de importados não existir, cria
    If ! ExistDir(cDirCerto)
        MakeDir(cDirCerto)
    EndIf

    //Busca todos os arquivos dentro da pasta
	aFiles := Directory(cDiretor + "*.*", "")

    //Define o repositório como o SIGAADV
	SetRepName("SIGAADV")

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD

    //Monta uma dialog de 1 pixel, apenas para poder instanciar um repositório
	DEFINE MSDIALOG oDlgImp TITLE "Importação - Repositório de Imagens" FROM 000, 000  TO 001, 001 PIXEL
    
        //Instancia um repositorio
		@ 000,000 REPOSITORY oReposit SIZE 0,0 OF oDlgImp
        
        //Define o tamanho da régua conforme a quantidade de arquivos
		ProcRegua(Len(aFiles))

        //Percorre todos os arquivos
		For nArqAtu := 1 To Len(aFiles)

            //Pega o nome do arquivo atual
            cNomeArq := aFiles[nArqAtu][1]

            //Incrementa a régua de processamento
			IncProc("Analisando arquivo " + cValToChar(nArqAtu) + " de " + cValToChar(Len(aFiles)) + " (" + cNomeArq + ")...")
            
            //Se for jpg, png ou bmp
            If ".JPG" $ Upper(cNomeArq) .Or. ".PNG" $ Upper(cNomeArq) .Or. ".BMP" $ Upper(cNomeArq)

                //O código do produto será o nome todo em maiusculo e sem a extensão
	        	cCodProd  := Upper(AllTrim(cNomeArq))
	        	cCodProd  := SubStr(cCodProd, 1, At('.', cCodProd) - 1)
	        	cNomeRep  := cCodProd 
			    
			    //Se conseguir posicionar no Produto
			    If SB1->(DbSeek(xFilial("SB1")+cCodProd))

                    //Se o arquivo já existir no repositório, exclui
					If oReposit:ExistBmp(cNomeRep)
						oReposit:DeleteBmp(cNomeRep)
					EndIf
					
                    //Chama a inserção da imagem no repositório
					lDeuCerto  := .F.
					oReposit:InsertBmp( cDiretor + cNomeArq , cNomeRep , @lDeuCerto )

                    //Se deu certo
                    If lDeuCerto
                        cMsg += "* Arquivo incluído: " + cNomeArq + CRLF

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
					cMsg+="- Produto " + cCodProd + " não encontrado na base;"+CRLF
			    EndIf
			    
			EndIf
		Next
	
    //Ao abrir a dialog, já fecha ela
	ACTIVATE MSDIALOG oDlgImp CENTERED ON INIT (oDlgImp:End()) 

	//Se tiver mensagem
	If ! Empty(cMsg)
        //Define o nome do log que será gravado
        cNomeLog := "log_zimgprod_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".log"

        //Grava na temporária do Windows
        MemoWrite(cDirTemp + cNomeLog, cMsg)

        //Abre o arquivo gerado
        ShellExecute("OPEN", cNomeLog, "", cDirTemp, 1)
	EndIf
    
    //Fecha o repositório de imagens
	FechaReposit()
Return

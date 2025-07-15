#Include 'totvs.ch'
#Include 'fileio.ch'

/*/{Protheus.doc} zArquivo 
@description Classe fornece metodos para manipular arquivos com qualquer extensao no remote e no servidor.
             Tem o objetivo de centralizar essas tarefas. 
@version     1.0
@since      02/2020
@see	Links Totvs
			01 - https://tdn.totvs.com/display/tec/Encapsulamento+-+Modificador+de+Acesso
			02 - https://tdn.totvs.com/pages/viewpage.action?pageId=6063065
			03 - https://tdn.totvs.com/display/tec/Tipagem+de+Dados
			04 - https://tdn.totvs.com/display/tec/CpyT2S
			05 - https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018425712-MP-ADVPL-Comportamento-de-Case-sensitive-na-fun%C3%A7%C3%A3o-CopyFile
/*/
Class zArquivo From LongNameClass

	Private Data cDirOrig     As Character
	Private Data cDirDest     As Character
	Private Data cExtensao    As Character
	Private Data cNomeArquivo As Character
	Private Data lComprime    As Logical  
	Private Data lSalvou	  AS Logical 
	Private Data aExtensoes   AS Array
	
	//Construtor
	Public Method New()	Constructor		
	
	//Getters	
	Private Method isSalvou() 			 As Logical
	Public  Method getDiretorioOrigem()	 As Character
	Public  Method getDiretorioDestino() As Character
	Public  Method getExtensaoArquivo()  As Character
	Public  Method getNomeArquivo() 	 As Character 
	Public  Method isComprime() 		 As Logical
	Public  Method getExtensoesValidas() As Array
		
	//Setters
	Private Method setSalvou(lSalvou As Logical) 			 
	Private Method setExtensao(cExtensao As Character) 		 
	Public  Method setDiretorioOrigem(cDirOrig As Character) 
	Public  Method setDiretorioDestino(cDirDest As Character)
	Public  Method setNomeArquivo(cNomeArquivo As Character) 
	Public  Method setComprime(lComprime As Logical)		 
	Public  Method addExtensoesValidas(aExtensoes As Array)	 
	
	//Outros metodos
	Public Method isExtensaoValida()        As Logical  
	Public Method salvaArquivoServidor()    As Logical
	Public Method salvaArquivoNoLocalHost() AS Logical 
	Public Method removeArquivo(cArquivo   As Character) As Logical  	
	Public Method isArquivoExiste(cArquivo As Character) As Logical
	Public Method escreveArquivo(cArquivo  As Character, cTexto As Character) As Logical
	Public Method getSizeArquivo(cArquivo As Character ) As Numeric
	Public Method leArquivoTxt(cArquivo As Character ) As Character
	Public Method editaArquivoTxt(cArquivo As Character,cTexto As Character, lPulaLinha As Logical) As Logical
EndClass

/*/{Protheus.doc} Constructor 
@description Construtor da classe
/*/
Method New() Class zArquivo As Object 
	::setDiretorioOrigem("")
	::setDiretorioDestino("")
	::setExtensao("")
	::setNomeArquivo("")
	::setComprime(.T.)
	::setSalvou(.F.)
	
Return Self

/*/{Protheus.doc} isSalvou 
@description Retorna se o arquivo ja foi salvo ou nao.
@return 	Logical, .T. caso ja tenha sido salvo e .F. caso contrario
/*/
Method isSalvou() Class zArquivo As Logical  
Return ::lSalvou

/*/{Protheus.doc} getDiretorioOrigem 
@description Retorna o diretorio de origem do arquivo.
@return 	Character, diretorio origem.
/*/
Method getDiretorioOrigem() Class zArquivo As Character
Return ::cDirOrig

/*/{Protheus.doc} getDiretorioDestino 
@description Retorna o diretorio de destino do arquivo
@return 	Character, diretorio destino.
/*/
Method getDiretorioDestino() Class zArquivo As Character
Return ::cDirDest

Method getExtensaoArquivo() Class zArquivo As Character
Return ::cExtensao

/*/{Protheus.doc} getNomeArquivo 
@description Retorna o nome que o arquivo possui
@return 	Character, nome do arquivo
/*/
Method getNomeArquivo() Class zArquivo As Character 
Return ::cNomeArquivo

/*/{Protheus.doc} isComprime 
@description Retorna se no momento de envio do arquivo para o servidor
             ele deve ser comprimido antes. Eh usado no metodo salvaArquivoServidor]
@return 	Logical, .T. caso seja para comprimir, .F. caso contrario
/*/
Method isComprime() Class zArquivo As Logical
Return ::lComprime

/*/{Protheus.doc} getExtensoesValidas 
@description Retorna todas as extensoes que são validas (poderao ser salvas)
@return 	Array, extensoes que podem ser salvas
/*/
Method getExtensoesValidas() Class zArquivo As Array
Return ::aExtensoes

/*/{Protheus.doc} setSalvou 
@description Flag indicando se arquivo ja foi salvo ou nao.
@param 		lSalvou, .T. caso arquivo ja tenha sido salvo .F. caso contrario
@return 	Undefinied
/*/
Method setSalvou(lSalvou) Class zArquivo 
	::lSalvou := lSalvou	
Return

/*/{Protheus.doc} setExtensao 
@description Altera propriedade que contem a extensao do arquivo origem
@param 		Character, extensao do arquivo.
@return 	Undefinied
/*/ 
Method setExtensao(cExtensao) Class zArquivo 	
	::cExtensao := cExtensao
Return

/*/{Protheus.doc} setDiretorioOrigem 
@description Altera propriedade que contem diretorio origem
@param 		Character, diretorio origem.
@return 	Undefinied
/*/  
Method setDiretorioOrigem(cDirOrig) Class zArquivo 
	
	::cDirOrig := cDirOrig
	::setSalvou(.F.)
	::setExtensao(Lower(Right(Alltrim(::cDirOrig),4)))
Return 

/*/{Protheus.doc} setDiretorioDestino 
@description Altera propriedade que contem diretorio destino do arquivo
@param 		Character, diretorio destino (incluindo o nome e extensao do arquivo).
@return 	Undefinied
/*/
Method setDiretorioDestino(cDirDest) Class zArquivo 
	::cDirDest := cDirDest
Return 

/*/{Protheus.doc} setNomeArquivo 
@description Altera o nome do arquivo origem antes de ser copiado
@param 		Caractsaor, diretorio destino (incluindo o nome e extensao do arquivo).
@return 	Logical, .T. caso tenha conseguido alterar o nome, .F. caso contrario.
/*/
Method setNomeArquivo(cNomeArquivo) Class zArquivo As Logical 
	
	Local nRet 		 := -1
	Local cDirOrigem := ""
	Local aDirOrigem := {}
	Local nIndice    := 0
	
	If !(::isSalvou())
		
		::cNomeArquivo := cNomeArquivo
						
		aDirOrigem := StrTokArr2( ::getDiretorioOrigem(), "\")
		For nIndice := 1 To Len(aDirOrigem)-1 
			cDirOrigem += aDirOrigem[nIndice]+"\"
		Next
		cDirOrigem += ::getNomeArquivo() + ::getExtensaoArquivo()
		
		If( !Empty(Alltrim(::getNomeArquivo())) )
		
			nRet := fRename( ::getDiretorioOrigem(), cDirOrigem )
			If(nRet != -1)
				::setDiretorioOrigem(cDirOrigem)
			Else
				u_zConOut("<zArquivo>[alteraNomeArquivo] - FError -> "+FError() )
			Endif
		Endif
		
	Endif
Return Iif(nRet == -1,.F., .T.)

/*/{Protheus.doc} setComprime 
@description Altera propriedade que contem a propriedade que define se arquivo deve ou nao 
             ser comprmido antes de ser copiado.Eh usado no metodo salvaArquivoServidor]
@param 		Logical, .T. caso deve ser comprimido .F. caso contrario
@return 	Undefinied
/*/
Method setComprime(lComprime) Class zArquivo 
	::lComprime := lComprime	
Return 

/*/{Protheus.doc} addExtensoesValidas 
@description Adiciona quais extensoes poderao ser salvas
@param 		Array, Array contendo extensoes validas exemplo {".mp4",".pdf",".jpg"}
@return 	Undefinied
/*/
Method addExtensoesValidas(aExtensoes) Class zArquivo 
	
	Local nIndice:=0
	
	::aExtensoes := Iif( ValType(::aExtensoes)=="A",::aExtensoes,{})	
	If( ValType(aExtensoes) == "A" )		
		For nIndice := 1 To Len(aExtensoes)
			Aadd(::aExtensoes,aExtensoes[nIndice])
		Next
	Endif
Return 
 
/*/{Protheus.doc} isExtensaoValida 
@description Retorna se extensao do arquivo sao validas ou nao. 
@return 	Logical, .T. se extensao for validas, .F. caso contrario
/*/
Method isExtensaoValida() Class zArquivo As Logical  
	Local nIndice := 0
	Local lValida := .F.
	
	For nIndice := 1 To Len(::getExtensoesValidas())
		If(::getExtensoesValidas()[nIndice] == ::getExtensaoArquivo())
			lValida := .T.
			exit
		Endif
	Next
		
Return lValida

/*/{Protheus.doc} salvaArquivoServidor 
@description Salva arquivo no diretorio destino localizado no Servidor. 
			 diretorio precisa estar na raiz do Protheus_data. Exemplo \temp\
@return 	Logical, .T. caso arquivo tenha sido salvo com sucesso, .F. caso contrario.
/*/
Method salvaArquivoServidor() Class zArquivo As Logical 
				
	If( !Empty(::getDiretorioOrigem()) .AND. !Empty(::getDiretorioDestino()) )
		
		If( ::isExtensaoValida() )				
			::setSalvou( CpyT2S( ::getDiretorioOrigem() ,; 
								 ::getDiretorioDestino(),;
								 ::isComprime() 		 ;
							   ))		
		Endif
	Endif
Return ::isSalvou()

/*/{Protheus.doc} salvaArquivoNoLocalHost 
@description Salva arquivo no diretorio destino localizado no smartcliet Local. 
			 diretorio origem precisa estar na raiz do Protheus_data. Exemplo \temp\
@return 	Logical, .T. caso arquivo tenha sido e  com sucesso, .F. caso contrario.     
@obs		Para usar esse metodo o diretorio oritem e o destino devem estar com o nome + extensao do arquivo.  
/*/
Method salvaArquivoNoLocalHost() Class zArquivo As Logical 	
	
	::setSalvou( __CopyFile( ::getDiretorioOrigem() ,; 
							 ::getDiretorioDestino() ;
							))	
Return  ::isSalvou()

/*/{Protheus.doc} removeArquivo 
@description Deleta arquivo no diretorio 
@param		Character, diretorio + nome do arquivo + extensao do arquivo a ser deletado.
@return 	Logical, .T. caso arquivo tenha sido deletado com sucesso, .F. caso contrario.
/*/
Method removeArquivo(cArquivo) Class zArquivo As Logical 
	
	Local   nRet 	 := -1
	Default cArquivo := ""
	
	If(::isArquivoExiste(cArquivo))
		nRet := Ferase( cArquivo ) 
		If ( nRet == -1 )
			u_zConOut("<zArquivo>[removeArquivo] - Falha na deleção do arquivo - "+FError())
		Endif
	Else
		u_zConOut("<zArquivo>[removeArquivo] - Arquivo ["+cArquivo+"] nao existe!")
	Endif
Return Iif(nRet == -1, .F., .T. )

/*/{Protheus.doc} isArquivoExiste 
@description Verifica arquivo no diretorio 
@param		Character, diretorio + nome do arquivo + extensao do arquivo a ser verificado.			
@return 	Logical, .T. caso arquivo tenha sidoexista no diretorio, .F. caso contrario.
/*/
Method isArquivoExiste(cArquivo) Class zArquivo As Logical 
Return File(cArquivo)

/*/{Protheus.doc} getSizeArquivo 
@description retorna o tamanho do arquivo em bytes 
@param		Character, diretorio + nome do arquivo + extensao do arquivo a ser verificado.
			caso nao seja informado esse parametro será considerado o arquivo que está no diretorio origem.
@return 	Numeric, tamaho do arquivo am Bytes. Caso nao consiga abrir o arquivo retorna -1
/*/
Method getSizeArquivo(cArquivo) Class zArquivo As Numeric 
	Local oArquivo 	:= Nil
	Local nBytes	:= -1
	
	Default cArquivo:= ::getDiretorioOrigem()
	
	oArquivo:= FWFileReader():new(cArquivo)
	If( oArquivo:Open() )
		nBytes := oArquivo:getFileSize()
		oArquivo:Close()
	Else
		u_zConOut("<zArquivo>[getSizeArquivo] - nao conseguiu abrir Arquivo ["+cArquivo+"]") 
 	EndIF 	
 	FreeObj( oArquivo ) 	
Return nBytes

/*/{Protheus.doc} escreveArquivo  
@description Permite escrever e salvar um arquivo texto.
@param		Character, diretorio + nome do arquivo + extensao do arquivo a ser escrito/criado.
@param		Character, Texto que deve ser escrito no arquivo.			
@return 	Logical, .T. caso arquivo tenha sido criado no diretorio, .F. caso contrario.
/*/
Method escreveArquivo(cArquivo,cTexto) Class zArquivo As Logical
	
	Local lEscreveu := MemoWrite( Alltrim(cArquivo), cTexto ) 
	
	If(!lEscreveu)
		u_zConOut("<zArquivo>[escreveArquivo] - nao conseguiu escrever/criar Arquivo ["+cArquivo+"] - Erro do FError = "+cValTochar(FError()))		
	EndIf
Return lEscreveu		
 
/*/{Protheus.doc} escreveArquivo  
@description Permite ler um arquivo texto.
@param		Character, diretorio + nome do arquivo + extensao do arquivo a ser lido. Default sao o arquivoOrigem
@return 	Character, Conteudo que foi lido no arquivo.
/*/
Method leArquivoTxt(cArquivo) Class zArquivo As Character
			
	Default cArquivo:= ::getDiretorioOrigem()		
Return 	MemoRead(Alltrim(cArquivo))
 
/*/{Protheus.doc} editaArquivo  
@description Permite editar arquivo de texto, inserindo um texto em seu final
@param		Character, diretorio + nome do arquivo + extensao do arquivo a ser editado. Default sao o arquivoOrigem
@param 		Character, Texto que deverá ser adicionado ao arquivo.
@param 		Logical, .T. caso seja para pular linha antes de começar a escrever, .F. caso contrario.
@return 	Logical, .T. caso tenha conseguido editar o arquivo, .F. caso contrario.
/*/ 
Method editaArquivoTxt(cArquivo,cTexto,lPulaLinha) Class zArquivo As Logical
	Local lRet			:= .T.
	Local cPulaLinha	:= Chr(13) + Chr(10)
	
	Default cArquivo	:= ::getDiretorioOrigem()
	Default cTexto		:= ""	
	Default lPulaLinha	:= .F.
	 
	// Abre o arquivo
	nHandle := fopen(cArquivo, FO_READWRITE + FO_SHARED )
	If nHandle == -1
	   u_zConOut("Erro de abertura do arquivo ["+cArquivo+"] para editar: FERROR "+cValTochar(ferror()) )
	   lRet := .F.
	Else
	   FSeek(nHandle, 0, FS_END)  			       	// Posiciona no fim do arquivo	
	   If( lPulaLinha )
	   		FWrite(nHandle, cPulaLinha, Len(cTexto))
	   Endif   
	   FWrite(nHandle, cTexto, Len(cTexto))			// Insere texto no arquivo
	   fclose(nHandle)                   			// Fecha arquivo	   
	Endif
	
Return lRet

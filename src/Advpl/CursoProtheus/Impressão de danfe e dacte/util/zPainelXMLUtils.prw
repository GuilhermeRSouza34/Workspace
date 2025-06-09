#Include 'totvs.ch'

#Define XML_DE_NFE 1
#Define XML_DE_CTE 2

/*/{Protheus.doc} zPainelXMLUtils
@description	metodos utilitarios utilizados no painel de impressao de xml.
@author    		Sulivan Simoes (sulivansimoes@gmail.com)
@since		    26/08/2024
/*/
Class zPainelXMLUtils From LongNameClass
	
	Static Method BuildTempTable(oTempTable As Object) As Character
	Static Method PopulateTempTable(cAliasTemp As Character, cAliasTemp As cDiretorioArquivos) 		
	Static Method GetColumnsMarkBrowse() As Array
	Static Method GetContentFiles(oMarkBrowse As Object, cTempTable As Character, cDiretorioArquivo As Character) As Array
	Static Method MoveFiles(oMarkBrowse As Object, cTempTable As Character, cDiretorioArquivo As Character) 
	Static Method F3Diretorio( cGet As Character )
	
EndClass

/*/{Protheus.doc} PopulateTempTable 
@description Popula a tabela temporaria que contem os registros para marcacao.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@param		Character, nome de alias da tabela temporaria criada.
@param		Character, caminho do diretorio que sera usado para recuperar arquivos. Exemplo: C:\temp\
@return     Undefinied
/*/
Method PopulateTempTable(cTempTable,cDiretorioArquivos) Class zPainelXMLUtils 
	
	Local F_NAME   := 1
	Local F_SIZE   := 2
	Local F_DATE   := 3
	Local nIndice  := 0
	Local oXML	   := Nil
	Local cTipo    := ''
	Local cDoc     := ''
	Local cSerie   := ''
	Local cCodigo  := ''
	Local cLoja    := ''
	Local cRazao   := ''
	Local cObs     := ''
	Local nValMerc := 0
	Local nTipoXML := 0
	
	DbSelectArea(cTempTable)	
	(cTempTable)->(__dbzap()) //Limpa tabela antes de popular.
	
	aFiles := Directory( Alltrim(cDiretorioArquivos) + "*.xml")	
	For nIndice := 1 To Len( aFiles )			

		cObs	 := "Arquivo nao eh de um XML valido"											
		cTipo    := cDoc := cSerie := cCodigo := cLoja := cRazao := ''					
		nValMerc := 0

		// XML_DE_NFE = 1
 		// XML_DE_CTE = 2
		For nTipoXML:= 1 To 2
			
			oXML:= zConvetFileToObjectFactory():GetStrategyFor(nTipoXML)
			oXML:ConvertToObject(Nil, Alltrim(cDiretorioArquivo)+Alltrim(aFiles[nIndice,F_NAME]))
			If oXML:IsXMLValid()

				u_zConOut("<zPainelXMLUtils>[PopulateTempTable] Identificou arquivo "+Alltrim(aFiles[nIndice,F_NAME])+" como "+Iif(nTipoXML==XML_DE_NFE,"NFE","CTE"))			
			
				cObs	  := ''
				cTipo 	  := "N"			
				nValMerc  := oXML:GetValorMercadoria()
				cRazao	  := oXML:GetRazaoSocial()
				cCgcEmit  := oXML:GetGCG()
				cDoc	  := oXML:GetNumeroNotaFiscal()
				cSerie	  := oXML:GetSerieNotaFiscal()
				cCodigo   := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_COD" )
				cLoja     := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_LOJA")

				If( RecLock(cTempTable, .T.) )			
					(cTempTable)->ARQUIVO  := aFiles[nIndice,F_NAME]
					(cTempTable)->TAMANHO  := aFiles[nIndice,F_SIZE]
					(cTempTable)->CRIACAO  := aFiles[nIndice,F_DATE]
					(cTempTable)->CODIGO   := cCodigo
					(cTempTable)->LOJA     := cLoja
					(cTempTable)->RAZAO	   := cRazao
					(cTempTable)->DOCUMENTO:= cDoc
					(cTempTable)->SERIE    := cSerie
					(cTempTable)->VLR_MERC := NoRound(nValMerc,2)
					(cTempTable)->OBS	   := cObs
					(cTempTable)->XML	   := oXML:GetTextXML()
					MsUnLock()
				EndIf

				Exit
			Endif		
		Next
	Next		
Return 

/*/{Protheus.doc} BuildTempTable 
@description Retorna a tabela temporaria que armazenara os registros para marcacao.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024
@param		Object, Endereco do objeto que sera criado a tabela temporaria. 
@return 	Character, nome de alias da tabema temporaria criada.
/*/
Method BuildTempTable(oTempTable) Class zPainelXMLUtils As Character
	Local cAliasTemp := "ZMARC_"+FWTimeStamp(1)
	Local aFields    := {}
		
	//Monta estrutura de campos da temporaria
	aAdd(aFields, { "OK"  	    , "C",  2, 0 })
	aAdd(aFields, { "CODIGO"  	, "C",  GetSX3Cache("A2_COD","X3_TAMANHO")   , 0 })
	aAdd(aFields, { "LOJA"  	, "C",  GetSX3Cache("A2_LOJA","X3_TAMANHO")  , 0 })
	aAdd(aFields, { "RAZAO"  	, "C",  GetSX3Cache("A2_NOME","X3_TAMANHO")  , 0 })
	aAdd(aFields, { "DOCUMENTO" , "C",  GetSX3Cache("F1_DOC","X3_TAMANHO")   , 0 })
	aAdd(aFields, { "SERIE"  	, "C",  GetSX3Cache("F1_SERIE","X3_TAMANHO") , 0 })
	aAdd(aFields, { "VLR_MERC"  , "N",  GetSX3Cache("F1_VALMERC","X3_TAMANHO"), 2 })
	aAdd(aFields, { "OBS"  	    , "C",	100, 0 })
	aAdd(aFields, { "ARQUIVO"   , "C", 	 99, 0 })
	aAdd(aFields, { "TAMANHO"   , "N", 	 10, 2 })
	aAdd(aFields, { "CRIACAO"   , "D",    8, 0 })
	aAdd(aFields, { "XML"  	    , "M",	  8, 0 })
		
	oTempTable:= FWTemporaryTable():New(cAliasTemp)
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("01", {"ARQUIVO"} )	
	oTempTable:Create()	
Return oTempTable:GetAlias()

/*/{Protheus.doc} GetColumnsMarkBrowse 
@description Retorna a estrutura das colunas que tera o FWMarkBrowse.
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024 
@return 	Array, estrutura das colunas que o FwMarkBrowse tera.
/*/
Method GetColumnsMarkBrowse() Class zPainelXMLUtils As Array
	Local nX	   := 0 
	Local aColumns := {}
	Local aStruct  := {}
	Local aNames   := { Nil,;
					   "Codigo",;
					   "Loja",;
					   "Razao Social",;
					   "Numero da nota",;
					   "Serie da nota",;
					   "Valor Mercadoria",;
					   "Observacao",;
					   "Arquivo",;
					   "Tamanho em Bytes",;
					   "Data criacao",;
					   "XML"}
	
	aAdd(aStruct, { "OK"  	    , "C",  2, 0 })
	aAdd(aStruct, { "CODIGO"  	, "C",  GetSX3Cache("A2_COD","X3_TAMANHO")   , 0 })
	aAdd(aStruct, { "LOJA"  	, "C",  GetSX3Cache("A2_LOJA","X3_TAMANHO")  , 0 })
	aAdd(aStruct, { "RAZAO"  	, "C",  GetSX3Cache("A2_NOME","X3_TAMANHO")  , 0 })
	aAdd(aStruct, { "DOCUMENTO" , "C",  GetSX3Cache("F1_DOC","X3_TAMANHO")   , 0 })
	aAdd(aStruct, { "SERIE"  	, "C",  GetSX3Cache("F1_SERIE","X3_TAMANHO") , 0 })
	aAdd(aStruct, { "VLR_MERC"  , "N",  GetSX3Cache("F1_VALMERC","X3_TAMANHO"), 2 })
	aAdd(aStruct, { "OBS"  	    , "C",	100, 0 })
	aAdd(aStruct, { "ARQUIVO"	, "C",   99, 0 })
	aAdd(aStruct, { "TAMANHO"	, "N",   10, 2 })
	aAdd(aStruct, { "CRIACAO"	, "D",    8, 0 })
	aAdd(aStruct, { "XML"  	    , "M",    8, 0 })
            
    For nX := 2 To Len(aStruct)    
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aNames[nX])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])              
    Next nX
Return aColumns

/*/{Protheus.doc} GetContentFiles 
@description Retorna array contendo conteudo de cada arquivo selecionado no MarkBrowse
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024 
@param		Object	 , oMarkBrowse, intancia do markbrowse da tela.
@param 		Character, cTempTable, Alias da tabela temporaria que contem os registros.
@return 	Array	 , conteudo dos arquivos selecionados no markbrowse, 
				[1] - Conteudo do XML
				[2] - Nome do arquivo
/*/
Method GetContentFiles(oMarkBrowse, cTempTable) Class zPainelXMLUtils As Array
	
	Local aArea 	 := GetArea()
	Local cMarca 	 := oMarkBrowse:Mark()
	Local aArquivos  := {}
	
	DbSelectArea(cTempTable)
	(cTempTable)->( dbGoTop() )
	While !(cTempTable)->( EOF() )
	    If oMarkBrowse:IsMark(cMarca) .And. Empty((cTempTable)->OBS)
	            	       
	        aAdd(aArquivos, { (cTempTable)->XML , (cTempTable)->ARQUIVO }) 
	    EndIf
	    (cTempTable)->( dbSkip() )
	Enddo
	
	RestArea( aArea )
Return aArquivos

/*/{Protheus.doc} MoveFiles 
@description Move os arquivos importados para a Pasta de acordo com status de importação			
@author  	Sulivan Simoes (sulivansimoes@gmail.com)
@since		26/08/2024 
@param		cDiretorioArquivo, Character, Caminho do diretório que se encontram os arquivos.
@param		cArquivo, Character, nome do arquivo a ser movido
@param 		nTipoXML, Numeric, tipo do xml. XML_DE_NFE=1; XML_DE_CTE=2
@return 	Undefinied
/*/
Method MoveFiles(cDiretorioArquivo, cArquivo, nTipoXML) Class zPainelXMLUtils As Array
	
	Local aArea 	 := GetArea()
	Local oArquivo   := zArquivo():New() 
	Local cDirDest1	 := Alltrim(cDiretorioArquivo)+Iif(nTipoXML==XML_DE_CTE,"\xml_cte\","\xml_nfe\")
	Local cDirDest   := cDirDest1

	If( !ExistDir(cDirDest) )
		MakeDir(cDirDest)				
	Endif 
		
	oArquivo:SetDiretorioOrigem(Alltrim(cDiretorioArquivo) + Alltrim(cArquivo) )
	oArquivo:SetDiretorioDestino(cDirDest+Alltrim(cArquivo))
	If( oArquivo:SalvaArquivoNoLocalHost() )
	    oArquivo:RemoveArquivo(oArquivo:GetDiretorioOrigem())
	Endif  	       
	    	
	FreeObj(oArquivo)
	RestArea( aArea )
Return 

/*/{Protheus.doc} F3Diretorio 
@description Preenche o Get com caminho de diretório escolhido pelo usuário.
@author  	Sulivan
@since		06/2020 
@param 		cGet, Character, endereço do get que deverá ser preenchido com caminho do diretório.
@return 	Undefinied
/*/
Method F3Diretorio( cGet ) Class zPainelXMLUtils 

	Default cGet := ""
	cGet := cGetFile( ,"Seleção de diretório",,,.T., nOR(GETF_NETWORKDRIVE,GETF_LOCALHARD, GETF_RETDIRECTORY)) //"Seleciona diretórios
	 
	If( Empty( Alltrim(cGet)) )
		Alert("Você não selecionou um diretório.")
	Endif
Return 

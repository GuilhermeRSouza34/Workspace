#Include 'totvs.ch'

#Define MATA103_CTE_NOTA 2
#Define MATA103_CTE_PRE_NOTA 1
#Define MATA116 3

#Define XML_DE_CTE 1
#Define XML_DE_NFE 2

/*/{Protheus.doc} zImportacaoXMLUtils
@description	metodos utilitarios utilizados no painel de importaÃ§Ã£o de xml.
@author    		Súlivan Simões (sulivan@atiliosistemas.com)
@since		    04/2022
/*/
Class zImportacaoXMLUtils From LongNameClass
	
	Static Method BuildTempTable(oTempTable As Object) As Character
	Static Method PopulateTempTable(cAliasTemp As Character, cAliasTemp As cDiretorioArquivos) As Undefinied		
	Static Method GetColumnsMarkBrowse() As Array
	Static Method GetContentFiles(oMarkBrowse As Object, cTempTable As Character, cDiretorioArquivo As Character) As Array
	Static Method MoveFiles(oMarkBrowse As Object, cTempTable As Character, cDiretorioArquivo As Character) As Undefinied
EndClass

/*/{Protheus.doc} PopulateTempTable 
@description Popula a tabela temporÃ¡ria que contÃ©m os registros para marcaÃ§Ã£o.
@author  	Súlivan Simões (sulivan@atiliosistemas.com)
@since		04/2022
@param		Character, nome de alias da tabela temporaria criada.
@param		Character, caminho do diretÃ³rio que serÃ¡ usado para recuperar arquivos. Exemplo: C:\temp\
@return     Undefinied
/*/
Method PopulateTempTable(cTempTable,cDiretorioArquivos, nTipoXML) Class zImportacaoXMLUtils As Undefinied
	
	Local F_NAME   := 1
	Local F_SIZE   := 2
	Local F_DATE   := 3
	Local nIndice  := 0
	Local oXML	   := zConvetFileToObjectFactory():GetStrategyFor(nTipoXML)
	Local cTipo    := ''
	Local cDoc     := ''
	Local cSerie   := ''
	Local cCodigo  := ''
	Local cLoja    := ''
	Local cRazao   := ''
	Local cObs     := ''
	Local nValMerc := 0
	
	DbSelectArea(cTempTable)	
	(cTempTable)->(__dbzap()) //Limpa tabela antes de popular.
	
	aFiles := Directory( Alltrim(cDiretorioArquivos) + "*.xml")	
	For nIndice := 1 To Len( aFiles )			
	
		cObs	 := "Arquivo nao eh de um XML valido"											
		cTipo    := cDoc := cSerie := cCodigo := cLoja := cRazao := ''					
		nValMerc := 0

		oXML:ConvertToObject(Nil, Alltrim(cDiretorioArquivo)+Alltrim(aFiles[nIndice,F_NAME]))
		If oXML:IsXMLValid()
				
			cObs	  := ''
			cTipo 	  := "N"			
			nValMerc  := oXML:GetValorMercadoria()
			cRazao	  := oXML:GetRazaoSocial()
			cCgcEmit  := oXML:GetGCG()
			cDoc	  := oXML:GetNumeroNotaFiscal()
			cSerie	  := oXML:GetSerieNotaFiscal()
			cCodigo   := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_COD" )
			cLoja     := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_LOJA")
					
			If Empty(cCodigo)
				cObs += "Fornecedor nao encontrado; "
			EndIf					
								
			If !Empty( Alltrim( Posicione("SF1",1,FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja,"F1_DOC") ))
				cObs += "Nota fiscal ja cadastrada; "			
			EndIf
		Endif

		If( RecLock(cTempTable, .T.) )			
			(cTempTable)->ARQUIVO  := aFiles[nIndice,F_NAME]
			(cTempTable)->TAMANHO  := aFiles[nIndice,F_SIZE]
			(cTempTable)->CRIACAO  := aFiles[nIndice,F_DATE]
			(cTempTable)->CODIGO   := cCodigo
			(cTempTable)->LOJA     := cLoja
			(cTempTable)->RAZAO	   := cRazao
			(cTempTable)->DOCUMENTO:= cDoc
			(cTempTable)->SERIE    := cSerie
			(cTempTable)->VLR_MERC := nValMerc
			(cTempTable)->OBS	   := cObs
			(cTempTable)->XML	   := oXML:GetTextXML()
			MsUnLock()
		EndIf
	Next		
Return 

/*/{Protheus.doc} BuildTempTable 
@description Retorna a tabela temporÃ¡ria que amazenarÃ¡ os registros para marcaÃ§Ã£o.
@author  	Súlivan Simões (sulivan@atiliosistemas.com)
@since		04/2022
@param		Object, EndereÃ§o do objeto que serÃ¡ criado a tabela temporaria. 
@return 	Character, nome de alias da tabema temporaria criada.
/*/
Method BuildTempTable(oTempTable) Class zImportacaoXMLUtils As Character
	Local cAliasTemp := "ZMARC_"+FWTimeStamp(1)
	Local aFields    := {}
		
	//Monta estrutura de campos da temporÃ¡ria
	aAdd(aFields, { "OK"  	    , "C",  2, 0 })
	aAdd(aFields, { "CODIGO"  	, "C",  GetSX3Cache("A2_COD","X3_TAMANHO")   , 0 })
	aAdd(aFields, { "LOJA"  	, "C",  GetSX3Cache("A2_LOJA","X3_TAMANHO")  , 0 })
	aAdd(aFields, { "RAZAO"  	, "C",  GetSX3Cache("A2_NOME","X3_TAMANHO")  , 0 })
	aAdd(aFields, { "DOCUMENTO" , "C",  GetSX3Cache("F1_DOC","X3_TAMANHO")   , 0 })
	aAdd(aFields, { "SERIE"  	, "C",  GetSX3Cache("F1_SERIE","X3_TAMANHO") , 0 })
	aAdd(aFields, { "VLR_MERC"  , "N",  GetSX3Cache("F1_VALMERC","X3_TAMANHO"), GetSX3Cache("F1_VALMERC","X3_DECIMAL") })
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
@description Retorna a estrutura das colunas que terÃ¡ o FWMarkBrowse.
@author  	Súlivan Simões (sulivan@atiliosistemas.com)
@since		04/2022 
@return 	Array, estrutura das colunas que o FwMarkBrowse terÃ¡.
/*/
Method GetColumnsMarkBrowse() Class zImportacaoXMLUtils As Array
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
	aAdd(aStruct, { "VLR_MERC"  , "N",  GetSX3Cache("F1_VALMERC","X3_TAMANHO"), GetSX3Cache("F1_VALMERC","X3_DECIMAL") })
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
@author  	Súlivan Simões (sulivan@atiliosistemas.com)
@since		04/2022 
@param		Object	 , oMarkBrowse, intancia do markbrowse da tela.
@param 		Character, cTempTable, Alias da tabela temporaria que contÃ©m os registros.
@return 	Array	 , conteudo dos arquivos selecionados no markbrowse, 
				[1] - Conteudo do XML
				[2] - Nome do arquivo
/*/
Method GetContentFiles(oMarkBrowse, cTempTable) Class zImportacaoXMLUtils As Array
	
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
@author  	Súlivan Simões (sulivan@atiliosistemas.com)
@since		04/2022 
@param		cDiretorioArquivo, Character, Caminho do diretório que se encontram os arquivos.
@param		cArquivo, Character, nome do arquivo a ser movido
@param 		lImportou, Logical, .T. caso a importacao tenha ocorrido com sucesso .F. caso contrário
@return 	Undefinied
/*/
Method MoveFiles(cDiretorioArquivo, cArquivo, lImportou) Class zImportacaoXMLUtils As Array
	
	Local aArea 	 := GetArea()
	Local oArquivo   := zArquivo():New() 
	Local cDirDest1	 := Alltrim(cDiretorioArquivo)+"\sucesso\"
	Local cDirDest2	 := Alltrim(cDiretorioArquivo)+"\com erros\"
	Local cDirDest   := If(lImportou,cDirDest1,cDirDest2)	

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

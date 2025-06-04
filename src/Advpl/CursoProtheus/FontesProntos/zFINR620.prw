#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#Define TOT_SAIDA   1
#Define TOT_ENTRADA 2

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)

/*/{Protheus.doc} User Function zFINR620
Movimentação Bancária
@author Daniel Atilio [criou a função orignal em TReport]
@author Súlivan Simões [Adaptou função para imprmir relatório em FwMSPrinter]
@since 20/05/2021 [data da criação]
@since 21/02/2022 [data da adaptação]
@version 2.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function zFINR620()

	Local aArea := GetArea()
	Local aPergs   := {}
	Local xPar0 := Space(TamSX3('E5_FILIAL')[1])
	Local xPar1 := StrTran(xPar0, ' ', 'Z')
	Local xPar2 := FirstDate(Date())
	Local xPar3 := LastDate(Date())
	Local xPar4 := Space(TamSX3('E5_BANCO')[1])
	Local xPar5 := StrTran(xPar4, ' ', 'Z')
    Local xPar6 := Space(TamSX3('E5_NATUREZ')[1])
    Local xPar7 := StrTran(xPar6, ' ', 'Z')
    Private cMaskVlr := "@E 999,999,999,999.99"
	    
	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Filial De"            , xPar0,  "", ".T.", "SM0", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Filial Até"           , xPar1,  "", ".T.", "SM0", ".T.", 60,  .T.})
	aAdd(aPergs, {1, "Data De"              , xPar2,  "", ".T.", ""   , ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Até"             , xPar3,  "", ".T.", ""   , ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Banco De"             , xPar4,  "", ".T.", "SA6", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Banco Até"            , xPar5,  "", ".T.", "SA6", ".T.", 60,  .T.})
    aAdd(aPergs, {1, "Natureza De"          , xPar6,  "", ".T.", "SED", ".T.", 60,  .F.})
    aAdd(aPergs, {1, "Natureza Até"         , xPar7,  "", ".T.", "SED", ".T.", 60,  .F.})

	//Se a pergunta for confirma, cria as definicoes do relatorio
	If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
        Processa( {|| fFINR620() },;
                   "Aguarde...",;
                   "Processando informações... ",;
                   .F. )	
	EndIf
	
	RestArea(aArea)
Return

/*/{Protheus.doc} fFINR620
Processamento geral do relatório
@type  Static Function
@author Súlivan
@since 21/02/2022 
/*/
Static Function fFINR620()

    Local aArea      := GetArea()
    Local cAliasQuery:= ""
    Local oTempTable := Nil
	Local cTempTable := ""

    Private nTotAux_    := 0
    //Parametros    
    Private cDaFilial_  := MV_PAR01
    Private cAtFilial_  := MV_PAR02
    Private cDaData_    := dToS(MV_PAR03)
    Private cAtData_    := dToS(MV_PAR04)
    Private cDoBanco_   := MV_PAR05
    Private cAtBanco_   := MV_PAR06
    Private cDaNatureza_:= MV_PAR07
    Private cAtNatureza_:= MV_PAR08

    //Constrói estrutura da temporária
	cTempTable := fBuildTmp(@oTempTable) 

    //Pega result set da query principal
	cAliasQuery := fExecQry() 
			
    IncProc("Populando tabela temporária..") 
    fPopulateTemp(cTempTable, cAliasQuery, oTempTable:GetRealName())
	
    IncProc("Imprimindo relatório..") 
    fPrintPDF(cTempTable)

	(cAliasQuery)->( DbCloseArea() )
    oTempTable:Delete()
	FreeObj(oTempTable)
    RestArea(aArea)
Return

/*/{Protheus.doc} fBuildTmp
Constrói tabela temporária.
@type       Static Function
@author     Súlivan Simões
@since      02/02/2022
@param		Object, Endereço do content da temporária
@return 	Character, nome da tabela criada.	
/*/
Static Function fBuildTmp(oTempTable)

	Local cAliasTemp := "zFINR620T_"+FWTimeStamp(1)
	Local aFields    := {}
		
	//Monta estrutura de campos da temporária
    aAdd(aFields, { "E5_FILIAL" , GetSx3Cache("E5_FILIAL"  ,"X3_TIPO"), GetSx3Cache("E5_FILIAL"  ,"X3_TAMANHO"), GetSx3Cache("E5_FILIAL" ,"X3_DECIMAL")  })
    aAdd(aFields, { "E5_NATUREZ", GetSx3Cache("E5_NATUREZ" ,"X3_TIPO"), GetSx3Cache("E5_NATUREZ" ,"X3_TAMANHO"), GetSx3Cache("E5_NATUREZ","X3_DECIMAL")  })
	aAdd(aFields, { "E5_DTDISPO", GetSx3Cache("E5_DTDISPO" ,"X3_TIPO"), GetSx3Cache("E5_DTDISPO" ,"X3_TAMANHO"), GetSx3Cache("E5_DTDISPO","X3_DECIMAL")  })
    aAdd(aFields, { "E5_BANCO"  , GetSx3Cache("E5_BANCO"   ,"X3_TIPO"), GetSx3Cache("E5_BANCO"   ,"X3_TAMANHO"), GetSx3Cache("E5_BANCO"  ,"X3_DECIMAL")  })
	aAdd(aFields, { "E5_AGENCIA", GetSx3Cache("E5_AGENCIA" ,"X3_TIPO"), GetSx3Cache("E5_AGENCIA" ,"X3_TAMANHO"), GetSx3Cache("E5_AGENCIA","X3_DECIMAL")  })
    aAdd(aFields, { "E5_CONTA"  , GetSx3Cache("E5_CONTA"   ,"X3_TIPO"), GetSx3Cache("E5_CONTA"   ,"X3_TAMANHO"), GetSx3Cache("E5_CONTA"  ,"X3_DECIMAL")  })
    aAdd(aFields, { "E5_DOCUMEN", GetSx3Cache("E5_DOCUMEN" ,"X3_TIPO"), GetSx3Cache("E5_DOCUMEN" ,"X3_TAMANHO"), GetSx3Cache("E5_DOCUMEN","X3_DECIMAL")  })
    aAdd(aFields, { "V_ENTRADA" , GetSx3Cache("E5_VALOR"   ,"X3_TIPO"), GetSx3Cache("E5_VALOR"   ,"X3_TAMANHO"), GetSx3Cache("E5_VALOR"  ,"X3_DECIMAL")  })
    aAdd(aFields, { "V_SAIDA"   , GetSx3Cache("E5_VALOR"   ,"X3_TIPO"), GetSx3Cache("E5_VALOR"   ,"X3_TAMANHO"), GetSx3Cache("E5_VALOR"  ,"X3_DECIMAL")  })
    aAdd(aFields, { "V_SALDO"   , GetSx3Cache("E5_VALOR"   ,"X3_TIPO"), GetSx3Cache("E5_VALOR"   ,"X3_TAMANHO"), GetSx3Cache("E5_VALOR"  ,"X3_DECIMAL")  })			
	
	oTempTable:= FWTemporaryTable():New(cAliasTemp)
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("01", {"E5_DTDISPO"} )	
	oTempTable:Create()	

Return oTempTable:GetAlias()

/*/{Protheus.doc} fExecQry
Executa a query que comporá o relatório
@type       Static Function
@author     Daniel Atilio (criou query que realiza consulta)
@author     Súlivan Simões (fez ajustes na query e a isolou em uma função especifica diminuindo as responsabilidades das funções)
@since      21/02/2022
@return 	Character, nome do alias da query	
/*/
Static Function fExecQry()

    Local cQry    	 := "" 
	Local cAliasTemp := "zFINR620C_"+FWTimeStamp(1)
	Local cNameSE5   := RetSqlName("SE5")
    Local cNameSX5   := RetSqlName("SX5")

    cQry := " SELECT "
	cQry += "     E5_DTDISPO, "
	cQry += "     E5_BANCO, "
	cQry += "     E5_AGENCIA, "
	cQry += "     E5_CONTA, "
	cQry += "     E5_DOCUMEN, "
    cQry += "     E5_PREFIXO, "
    cQry += "     E5_NUMERO, "
    cQry += "     E5_PARCELA, "
	cQry += "     E5_NUMCHEQ, "
	cQry += "     E5_MOTBX, "
    cQry += "     E5_RECPAG, "
    cQry += "     E5_NATUREZ, "
    cQry += "     E5_FILIAL, "
	cQry += "     CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE 0 END AS V_ENTRADA, "
	cQry += "     CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR ELSE 0 END AS V_SAIDA "
	cQry += " FROM "+ cNameSE5 + " SE5 "
	cQry += " WHERE E5_FILIAL BETWEEN '" + cDaFilial_ + "' AND '" + cAtFilial_ + "' "
	cQry += "   AND E5_SITUACA <> 'C' "
	cQry += "   AND E5_NUMCHEQ <> '%*' "
	cQry += "   AND E5_DTDISPO BETWEEN   '" + cDaData_     + "' AND '" + cAtData_     + "' "
	cQry += "   AND E5_BANCO   BETWEEN   '" + cDoBanco_    + "' AND '" + cAtBanco_    + "' "
    cQry += "   AND E5_NATUREZ BETWEEN   '" + cDaNatureza_ + "' AND '" + cAtNatureza_ + "' "    
	cQry += "   AND E5_DTDIGIT BETWEEN '19890101' AND '20500101' "
	cQry += "   AND E5_TIPODOC NOT IN ('DC', 'JR', 'MT', 'BA', 'MT', 'CM', 'D2', 'J2', 'M2', 'C2', 'V2', 'CX', 'CP', 'TL', 'VA') "
	cQry += "   AND NOT ( E5_MOEDA IN ('C1', 'C2', 'C3', 'C4', 'C5', 'CH') AND E5_NUMCHEQ = '' AND NOT (E5_TIPODOC IN ('TR, TE')) ) "
	cQry += "   AND NOT ( E5_TIPODOC IN ('TR', 'TE') AND E5_NUMERO = '' AND NOT (E5_MOEDA IN ('CC', 'CD', 'CH', 'CO', 'DOC', 'FI', 'R$', 'TB', 'TC', 'VL')) ) "
	cQry += "   AND NOT ( E5_TIPODOC IN ('TR', 'TE') AND SUBSTRING(E5_NUMCHEQ, 1, 1) = '*' OR SUBSTRING(E5_DOCUMEN, 1, 1) = '*' ) "
	cQry += "   AND NOT ( E5_MOEDA = 'CH' AND E5_BANCO NOT IN (SELECT X5_CHAVE FROM "+cNameSX5+" SX5 WHERE X5_TABELA = '23' AND SX5.D_E_L_E_T_ = ' ') AND E5_TIPODOC IN ('TR', 'TE') ) "
	cQry += "   AND NOT ( E5_BANCO = '' ) "
	cQry += "   AND NOT ( E5_SITUACA = 'C' ) "
	cQry += "   AND NOT ( E5_TIPODOC IN ('DC', 'JR', 'MT', 'BA', 'MT', 'CM', 'D2', 'J2', 'M2', 'C2', 'V2', 'CX', 'CP', 'TL') ) "
	cQry += "   AND NOT ( E5_TIPODOC = 'SG' AND NOT E5_MOEDA IN ('R$') ) "
	cQry += "   AND NOT ( SUBSTRING(E5_NUMCHEQ, 1, 1) = '*' ) "
	cQry += "   AND NOT ( SUBSTRING(E5_DOCUMEN, 1, 1) = '*' ) "
	cQry += "   AND SE5.D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY "
	cQry += "     E5_BANCO, "
	cQry += "     E5_AGENCIA, "
	cQry += "     E5_CONTA, "
	cQry += "     E5_FILORIG, "
	cQry += "     E5_DTDISPO, "
	cQry += "     R_E_C_N_O_, "
	cQry += "     E5_NUMCHEQ, "
	cQry += "     E5_DOCUMEN, "
	cQry += "     E5_PREFIXO, "
	cQry += "     E5_NUMERO"

    cQry:= ChangeQuery(cQry)
    VarInfo(FunName()+"[u_zFIN620][fExecQry] QUERY -> ",cQry)
    TcQuery cQry New Alias (cAliasTemp)
    
    TcSetField( cAliasTemp, 'E5_DTDISPO', 'D' )

    //Define o tamanho da régua
    Count to nTotAux_
    ProcRegua(nTotAux_)
Return cAliasTemp


/*/{Protheus.doc} fPopulateTemp
Popula tabela temporária que armazena informações que serão impressas.
@type       Static Function
@author     Daniel Atilio (criou lógica para percorrer query e obter informações)
@author     Súlivan Simões (responsável por adaptar a regra de negócio)
@since      21/02/2022
@param      cTempTable, Character, alias do relatório que será impresso
@param      cAliasQry, Character, alias do relatório que será impresso
@param      cNameTable, Character, nome da tabela temporaria do relatório
@return 	Character, nome do alias da query	
/*/
Static Function fPopulateTemp(cTempTable, cAliasQry, cNameTable)
    
    Local lAcao		:= .T. //.F. = Altera, .T.= Inclui
    Local cDoc      := ""
    Local cBancoAtu := ""
    Local cBancoAnt := ""
    Local cAgencAnt := ""
    Local cCCAnt    := ""
    Local dDtMovAnt := cTod('//')
    Local nSaldo    := 0
    Local aTotais   := {0,0}

    DbSelectArea(cTempTable)
    (cAliasQry)->(DbGoTop())
	While !(cAliasQry)->( Eof() )

        //Regra do fonte padrão que valida o motivo da baixa
        If ! Empty( (cAliasQry)->E5_MOTBX )
            If ! MovBcoBx((cAliasQry)->E5_MOTBX)
                (cAliasQry)->(DbSkip())
                Loop
            EndIf
        EndIf
        
        If cBancoAtu != (cAliasQry)->E5_BANCO + (cAliasQry)->E5_AGENCIA + (cAliasQry)->E5_CONTA
            
            //Se tiver Saldo, pega totalizadores
            If nSaldo != 0
               fCalcTot(@aTotais, cNameTable, cBancoAnt, cAgencAnt, cCCAnt, dDtMovAnt)
               If RecLock(cTempTable, lAcao)                     

                    (cTempTable)->E5_DTDISPO := dDtMovAnt
                    (cTempTable)->E5_BANCO	 := cBancoAnt
                    (cTempTable)->E5_AGENCIA := cAgencAnt
                    (cTempTable)->E5_CONTA	 := cCCAnt
                    (cTempTable)->E5_DOCUMEN := 'TOTAIS:'
                    (cTempTable)->V_ENTRADA	 := aTotais[TOT_ENTRADA]
                    (cTempTable)->V_SAIDA	 := aTotais[TOT_SAIDA]
                    (cTempTable)->V_SALDO	 := nSaldo
                    (cTempTable)->( MsUnLock() ) 	
                Endif 
            EndIf

            nSaldo   := fGetSaldo((cAliasQry)->E5_BANCO, (cAliasQry)->E5_AGENCIA, (cAliasQry)->E5_CONTA, (cAliasQry)->E5_DTDISPO)

            If RecLock(cTempTable, lAcao) 
                (cTempTable)->E5_FILIAL  := (cAliasQry)->E5_FILIAL
                (cTempTable)->E5_NATUREZ := (cAliasQry)->E5_NATUREZ
                (cTempTable)->E5_DTDISPO := (cAliasQry)->E5_DTDISPO                
                (cTempTable)->E5_BANCO	 := (cAliasQry)->E5_BANCO
                (cTempTable)->E5_AGENCIA := (cAliasQry)->E5_AGENCIA
                (cTempTable)->E5_CONTA	 := (cAliasQry)->E5_CONTA
                (cTempTable)->E5_DOCUMEN := 'SALDO INICIAL:'
                (cTempTable)->V_ENTRADA	 := 0
                (cTempTable)->V_SAIDA	 := 0
                (cTempTable)->V_SALDO	 := nSaldo
                (cTempTable)->( MsUnLock() ) 	
            Endif 
        Endif
    
        //Montagem da coluna documento
        cDoc := SubStr(Alltrim((cAliasQry)->E5_DOCUMEN), 1, 15)
        If Empty(cDoc)
            cDoc := Alltrim((cAliasQry)->E5_PREFIXO) + ;
                    Iif(! Empty((cAliasQry)->E5_PREFIXO), "-", "") + ;
                    Alltrim((cAliasQry)->E5_NUMERO) + ;
                    Iif(! Empty((cAliasQry)->E5_PARCELA), "-" + (cAliasQry)->E5_PARCELA, "")
        Endif
        If Empty(cDoc)
                cDoc := "Ch: " + (cAliasQry)->E5_NUMCHEQ
        EndIf

        //Saldos
        If (cAliasQry)->E5_RECPAG == 'R'
            nSaldo += (cAliasQry)->V_ENTRADA
        Else
            nSaldo -=(cAliasQry)->V_SAIDA
        EndIf

        If RecLock(cTempTable, lAcao) 
			(cTempTable)->E5_FILIAL  := (cAliasQry)->E5_FILIAL
            (cTempTable)->E5_NATUREZ := (cAliasQry)->E5_NATUREZ
            (cTempTable)->E5_DTDISPO := (cAliasQry)->E5_DTDISPO
			(cTempTable)->E5_BANCO	 := (cAliasQry)->E5_BANCO
			(cTempTable)->E5_AGENCIA := (cAliasQry)->E5_AGENCIA
			(cTempTable)->E5_CONTA	 := (cAliasQry)->E5_CONTA
			(cTempTable)->E5_DOCUMEN := cDoc
            (cTempTable)->V_ENTRADA	 := Iif((cAliasQry)->E5_RECPAG == 'R', (cAliasQry)->V_ENTRADA, 0)
			(cTempTable)->V_SAIDA	 := Iif((cAliasQry)->E5_RECPAG != 'R', (cAliasQry)->V_SAIDA  , 0)
			(cTempTable)->V_SALDO	 := nSaldo
			(cTempTable)->( MsUnLock() ) 	
		Endif 

        //Pegando registro atual antes de iterar
        cBancoAtu := (cAliasQry)->E5_BANCO + (cAliasQry)->E5_AGENCIA + (cAliasQry)->E5_CONTA
        cBancoAnt := (cAliasQry)->E5_BANCO
        cAgencAnt := (cAliasQry)->E5_AGENCIA
        cCCAnt    := (cAliasQry)->E5_CONTA        
        dDtMovAnt := (cAliasQry)->E5_DTDISPO

        (cAliasQry)->( DbSkip() )
	Enddo	

    //Obtem totais do último banco
    fCalcTot(@aTotais, cNameTable, cBancoAnt, cAgencAnt, cCCAnt, dDtMovAnt)
    If RecLock(cTempTable, lAcao)                     

        (cTempTable)->E5_DTDISPO := dDtMovAnt
        (cTempTable)->E5_BANCO	 := cBancoAnt
        (cTempTable)->E5_AGENCIA := cAgencAnt
        (cTempTable)->E5_CONTA	 := cCCAnt
        (cTempTable)->E5_DOCUMEN := 'TOTAIS:'
        (cTempTable)->V_ENTRADA	 := aTotais[TOT_ENTRADA]
        (cTempTable)->V_SAIDA	 := aTotais[TOT_SAIDA]
        (cTempTable)->V_SALDO	 := nSaldo
        (cTempTable)->( MsUnLock() ) 	
    Endif
Return

/*/{Protheus.doc} fExecQryRel
calcula o saldo inicial
@type       Static Function
@author     Daniel Antilio
@since      20/05/2021
/*/
Static Function fGetSaldo(cBanco, cAgencia, cConta, dDtMov)
    Local aArea    := GetArea()
    Local nValor   := 0
    Local cQrySE8  := ""
    Local cNameSE8 := RetSQLName('SE8')

    //Busca o último saldo antes do dia da movimentação
    cQrySE8 += " SELECT TOP 1 "
    cQrySE8 += "     E8_SALRECO "
    cQrySE8 += " FROM "
    cQrySE8 += "     " + cNameSE8 + " SE8 "
    cQrySE8 += " WHERE "
    cQrySE8 += "     E8_BANCO = '" + cBanco + "' "
    cQrySE8 += "     AND E8_AGENCIA = '" + cAgencia + "' "
    cQrySE8 += "     AND E8_CONTA = '" + cConta + "' "
    cQrySE8 += "     AND E8_DTSALAT < " + dToS(dDtMov) + " "
    cQrySE8 += "     AND SE8.D_E_L_E_T_ = ' ' "
    cQrySE8 += " ORDER BY "
    cQrySE8 += "     E8_DTSALAT DESC "
    PlsQuery(cQrySE8, "QRY_SE8")
    
    //Se houver dados
    If ! QRY_SE8->(EoF())
        nValor := QRY_SE8->E8_SALRECO
    EndIf
    QRY_SE8->(DbCloseArea())
    RestArea(aArea)
Return nValor

/*/{Protheus.doc} fCalcTot
Calcula os totais dos movimentos a preenche o array aTotais
@type       Static Function
@author     Súlivan Simões
@since      28/02/2022
@param      aTotais, Array, referencia do array que contém os totais
@param      cTempTable, Character, alias do relatório que será impresso
@param      cBanco, Character, codigo do banco
@param      cAgencia, Character, codigo da agencia
@param      cConta, Character, codigo da conta
@param      dDtMovimento, Date, data do movimento
/*/
Static Function fCalcTot(aTotais, cTempTable, cBanco, cAgencia, cConta, dDtMovimento)

    Local cAliasTot :="fCalcTot"+FWTimeStamp(1)
    Local cQuery    :=""

    cQuery := " SELECT SUM(V_ENTRADA) AS V_ENTRADA, "
    cQuery += "        SUM(V_SAIDA)   AS V_SAIDA    "
    cQuery += " FROM "+cTempTable
    cQuery += " WHERE E5_BANCO   = '"+cBanco   +"' "
    cQuery += "   AND E5_AGENCIA = '"+cAgencia +"' "
    cQuery += "   AND E5_CONTA   = '"+cConta   +"' "
    cQuery += "   AND E5_DTDISPO = '"+dTos(dDtMovimento)+"' "

    cQuery:= ChangeQuery(cQuery)
    VarInfo(FunName()+"[u_zFIN620][fCalcTot] QUERY -> ",cQuery)
    TcQuery cQuery New Alias (cAliasTot)

    If !(cAliasTot)->(EoF())
        aTotais[TOT_ENTRADA] := (cAliasTot)->V_ENTRADA
        aTotais[TOT_SAIDA]   := (cAliasTot)->V_SAIDA
    EndIf
    (cAliasTot)->(DbClosearea())
Return


/*/{Protheus.doc} fPrintPDF
    Realiza a montagem e impressão do relatório em PDF

    @type  Static Function
    @author Daniel Atilio ( Criação da lógica de estilização do relatório )
    @author Súlivan (Realizado adpatações para regra de negócio)
    @since  26/02/2022
    @param  cAliasTMP, Character, alias do relatório que será impresso
/*/
Static Function fPrintPDF(cAliasTmp)
    
    Local nAtuAux      := 0
    Local cArquivo     := FWTimeStamp(1)+"_Movimentação Bancária.pdf"
    Local cPictureNum1 := GetSx3Cache("E5_VALOR","X3_PICTURE")
    Local cBancoAtu    := ""

    Private oPrintPvt  := Nil
    Private oBrushAzul := TBRUSH():New(,nCorAzul)
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 820
    Private nColIni    := 010
    Private nColFin    := 585
    Private nEspCol    := (nColFin-(nColIni+150))/13
    Private nColMeio   := (nColFin-nColIni)/2
    //Colunas dos relatorio
    Private nColData    := nColIni
    Private nColBanco   := nColIni + 050
    Private nColAgencia := nColFin - 490
    Private nColConta   := nColFin - 460
    Private nColDoc     := nColFin - 370
    Private nColEnt     := nColFin - 270
    Private nColSaida   := nColFin - 180
    Private nColSaldo   := nColFin -  80
    Private nColProx    := nColFin -  30
    //Declarando as fontes
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
        
    (cAliasTmp)->(DbGoTop())
     
    //Somente se tiver dados
    If ! (cAliasTmp)->(EoF())
        //Criando o objeto de impressao
       	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., GetTempPath(), .T., , , @oPrintPvt , , , .F., )
        If(oPrintPvt:nModalResult == PD_CANCEL)
		    FreeObj(oPrintPvt)
		    Return
	    Endif
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        // oPrintPvt:SetLandscape()
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
 
        //Imprime os dados
        fImpCab()
        While ! (cAliasTmp)->(EoF())
            nAtuAux++
            IncProc("Imprimindo registro " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux_) + "...")

            //Se é um novo banco quebra página            
            fQuebra( cBancoAtu != (cAliasTmp)->E5_BANCO + (cAliasTmp)->E5_AGENCIA + (cAliasTmp)->E5_CONTA .And. !Empty(Alltrim(cBancoAtu)) )    
            
            //Se atingiu o limite, quebra de pagina
            fQuebra()
             
            //Faz o zebrado ao fundo
            If nAtuAux % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
            EndIf
 
            //Imprime a linha atual
            oPrintPvt:SayAlign(nLinAtu, nColData   , dToc((cAliasTmp)->E5_DTDISPO)                  , oFontDet,  (nColBanco   - nColData) , 10, , PAD_LEFT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColBanco  , (cAliasTmp)->E5_BANCO                          , oFontDet,  (nColAgencia - nColBanco), 10, , PAD_LEFT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColAgencia, (cAliasTmp)->E5_AGENCIA                        , oFontDet,  (nColConta - nColAgencia), 10, , PAD_LEFT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColConta  , (cAliasTmp)->E5_CONTA                          , oFontDet,  (nColDoc - nColConta)    , 10, , PAD_LEFT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColDoc    , (cAliasTmp)->E5_DOCUMEN                        , oFontDet,  (nColEnt  - nColDoc)     , 10, , PAD_LEFT ,  )
            oPrintPvt:SayAlign(nLinAtu, nColEnt    , Iif((cAliasTmp)->V_ENTRADA!=0,Transform((cAliasTmp)->V_ENTRADA, cPictureNum1),''), oFontDet,  (nColSaida - nColEnt)    , 10, , PAD_RIGHT,  )
            oPrintPvt:SayAlign(nLinAtu, nColSaida  , Iif((cAliasTmp)->V_SAIDA!=0  ,Transform((cAliasTmp)->V_SAIDA, cPictureNum1)  ,''), oFontDet,  (nColSaldo - nColSaida), 10, , PAD_RIGHT,  )
            oPrintPvt:SayAlign(nLinAtu, nColSaldo  , Iif((cAliasTmp)->V_SALDO!=0  ,Transform((cAliasTmp)->V_SALDO, cPictureNum1)  ,''), oFontDet,  (nColFin - nColSaldo) , 10, , PAD_RIGHT,  )

            nLinAtu += 15
            oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)

            //Se atingiu o limite, quebra de pagina
            fQuebra()
                          
            cBancoAtu:= (cAliasTmp)->E5_BANCO + (cAliasTmp)->E5_AGENCIA + (cAliasTmp)->E5_CONTA 
            (cAliasTmp)->(DbSkip())

        EndDo
        fQuebra()

        fImpRod()
        
        IncProc("Abrindo relatório..")
        oPrintPvt:Preview()
    Else
        MsgStop("Não foram encontradas informações com os parâmetros informados!", "Atenção")
    EndIf
    FreeObj(oPrintPvt) 
Return 

/*/{Protheus.doc} fImpCab
imprime o cabecalho do relatório
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      26/02/2022
/*/
Static Function fImpCab()

    Local cTexto   := ""
    Local nLinCab  := 015
     
    //Iniciando Pagina
    oPrintPvt:StartPage()
     
    //Cabecalho
    cTexto := "Movimentação Bancária"
    oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
     
    //Linha Separatoria
    nLinCab += 020
    oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
     
    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinCab + 5
 
    oPrintPvt:SayAlign(nLinAtu+05, nColData   ,   "Data"     , oFontMin,  (nColBanco   - nColData) ,   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColBanco  ,   "Banco"    , oFontMin,  (nColAgencia - nColBanco),   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColAgencia,   "Agência"  , oFontMin,  (nColConta - nColAgencia),   10, nCorCinza, PAD_LEFT,   )    
    oPrintPvt:SayAlign(nLinAtu+05, nColConta  ,   "Conta"    , oFontMin,  (nColDoc - nColConta)    ,   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColDoc    ,   "Documento", oFontMin,  (nColEnt  - nColDoc)     ,   10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColEnt    ,   "Entrada"  , oFontMin,  (nColSaida - nColEnt)    ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+05, nColSaida  ,   "Saída"    , oFontMin,  (nColSaldo - nColSaida)  ,   10, nCorCinza, PAD_RIGHT,  )
    oPrintPvt:SayAlign(nLinAtu+05, nColSaldo  ,   "Saldo"    , oFontMin,  (nColProx - nColSaldo)   ,   10, nCorCinza, PAD_RIGHT,  )
   
    nLinAtu += 25
Return

/*/{Protheus.doc} fImpRod
imprime o rodape do relatório
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      26/02/2022
/*/
Static Function fImpRod()
    Local nLinRod:= nLinFin
    Local cTexto := ''
 
    //Linha Separatoria
    oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (zFINR620)     " + UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
     
    //Direita
    cTexto := "Pagina "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
     
    //Finalizando a pagina e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return

/*/{Protheus.doc} fQuebra
Realiza a finalização de uma página e inicialização de outra quando necessário.
@author     Daniel Atilio ( Criação da lógica de estilização do relatório )
@author     Súlivan (Realizado adpatações para regra de negócio)
@since      26/02/2022
@param      lForce, Logical, força a finalização de uma página e inicialização de outra 
            mesmo que a página não tenha acabado. Default .F.
/*/
Static Function fQuebra(lForce)

    Default lForce := .F.

    If lForce .Or. nLinAtu >= nLinFin-10
        fImpRod()
        fImpCab()
    EndIf
Return

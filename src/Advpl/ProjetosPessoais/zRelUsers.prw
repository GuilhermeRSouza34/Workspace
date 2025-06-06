#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

Static nPosRecno := 1 //Id da tabela de usuários (r_e_c_n_o_)
Static nPosIdUser:= 2 //Id do usuário
Static nPosLogin := 3 //Login do Usuário
Static nPosNomUsr:= 4 //Nome do usuário
Static nPosEmailU:= 5 //email do usuário
Static nPosDepUsr:= 6 //departamento do usuário
Static nPosCargo := 7 //cargo do usuário

Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(163, 203, 255)

/*/{Protheus.doc} zRelUsers
    Relatório traz informações dos usuários de acordo com o filtros informados
    @type  Function
    @author Súlivan Simões (sulivansimoes@gmail.com)    
    @since 28/08/2022
    @version 1.0    
    @return Unidefied
    @see Link Totvs
            https://tdn.totvs.com/pages/releaseview.action?pageId=267792734
            https://tdn.totvs.com/pages/releaseview.action?pageId=6814847
            https://tdn.totvs.com/pages/releaseview.action?pageId=6815010
    /*/
User Function zRelUsers()
    
    Local aArea := GetArea()
    Local aPergs:= {}
	Local xPar0 := Space(6)
	Local xPar1 := StrTran(xPar0, ' ', 'Z')
	Local xPar2 := Space(25)
	Local xPar3 := StrTran(xPar0, ' ', 'Z')
    	    
	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Do código"            , xPar0,  "", ".T.", "USR   ", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Até código"           , xPar1,  "", ".T.", "USR   ", ".T.", 60,  .T.})
	aAdd(aPergs, {1, "Do Login"             , xPar2,  "", ".T.", "AGRUSR", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Até Login"            , xPar3,  "", ".T.", "AGRUSR", ".T.", 80,  .T.})

	//Se a pergunta for confirma, cria as definicoes do relatorio
	If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
        Processa( {|| fRelUsers() },;
                   "Aguarde...",;
                   "Processando informações... ",;
                   .F. )	
	EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} fRelUsers
    Realiza processamento geral
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)    
    @since 28/08/2022
    @version 1.0    
    @return Unidefied
/*/
Static Function fRelUsers()

    Local aAllusers := FWSFAllUsers()
    Local aUsers    := {}
    Local nIndice   := 0
    
    //Parametros    
    Private cDoCodigo_  := MV_PAR01
    Private cAtCodigo_  := MV_PAR02
    Private cDoLogin_   := MV_PAR03
    Private cAtLogin_   := MV_PAR04
    
    IncProc("Filtrando usuários..") 
    For nIndice := 1 To Len(aAllusers)
        If ( aAllusers[nIndice][nPosIdUser] >= cDoCodigo_ .And. aAllusers[nIndice][nPosIdUser] <= cAtCodigo_ ) .And.;
           ( aAllusers[nIndice][nPosLogin]  >= cDoLogin_  .And. aAllusers[nIndice][nPosLogin]  <= cAtLogin_  )
           
           aAdd(aUsers,aAllusers[nIndice])
        Endif
    Next

    IncProc("Imprimindo relatório..") 
    If Len(aUsers) > 0
        fPrintPDF(@aUsers)
    Else
        MsgAlert("Não há usuários de acordo com parâmetros informados.", "Aviso!")
    Endif
Return

/*/{Protheus.doc} fPrintPDF
    Realiza impressão do relatório em PDF
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)    
    @since 28/08/2022
    @version 1.0
    @return Unidefied
/*/
Static Function fPrintPDF(aUsers)
    
    Local cArquivo     := FWTimeStamp(1)+"_usuarios.pdf"
    Local nLinha	   := 1         
     
    Private aAcessos    := GetAccessList()
    Private aModulos    := fAllModulos()
    Private aModulosUser:= {}    
    Private aUserAux    := {}
	Private oPrintPvt   := Nil
    Private oBrushAzul  := TBRUSH():New(,nCorAzul)
    Private cHoraEx     := Time()
    Private nPagAtu     := 1
    Private nAtuAux     := 0
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 780
    Private nColIni    := 010
    Private nColFin    := 585
	Private nColIni2   := nColFin/2
	Private nColIni3   := nColFin/1.9
    Private nEspCol    := (nColFin-(nColIni+150))/13
    Private nColMeio   := (nColFin-nColIni)/2
    //Colunas dos relatorio
    Private nColDtMov   := nColIni    
    Private nColInfo1	:= nColIni  + 095
	Private nColInfo2	:= nColIni2 + 055
	Private nColInfo3	:= nColIni3 + 70
    Private nColDoc		:= nColIni + 070
	Private nColProd	:= nColIni + 050
    Private nColQtdBase := nColFin - 150
    Private nColUnid    := nColFin - 425
    Private nColObs  	:= nColFin - 650
    Private nColQtdSaldo:= nColFin - 185
    Private nColProx    := nColFin - 150
    //Declarando as fontes
    Private cNomeFont  := "Arial"
    Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)

    //Criando o objeto de impressao
    If( oPrintPvt == Nil )
    	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., GetTempPath(), .T., , , @oPrintPvt , , , .F., )
        If(oPrintPvt:nModalResult == PD_CANCEL)
            FreeObj(oPrintPvt)
            Return
        Endif
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
		ProcRegua(Len(aUsers))
    EndIf
    
    For nLinha := 1 To Len(aUsers)
    
        IncProc("Imprimindo usuários " + cValToChar(nLinha) + " de " + cValToChar(Len(aUsers)) + "...")

        aUserAux    := fGetInfoUser(aUsers[nLinha][nPosIdUser], 2)     
        aModulosUser:= fGetInfoUser(aUsers[nLinha][nPosIdUser], 3)
     
        fImpCab(aUsers[nLinha])    
        fImpHorarios()
        fImpEmpresa(aUsers[nLinha][nPosIdUser])
        fImpGrupos(aUsers[nLinha])
        fImpModulos()
        fImpAcessos() 
    Next
    fImpRod()                
		
	IncProc("Abrindo relatório..")
	oPrintPvt:Preview()
	FreeObj(oPrintPvt)
Return

/*/{Protheus.doc} fImpHorarios
    Imprime horarios que usuário pode acessar o sistema
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022    
    @return Unidefied
/*/
Static Function fImpHorarios()
    Local nDia       := 1
    Local aDiaSemana := {"Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"}

    fImpSubCab("Horários que usuário pode acessar sistema")
    
    For nDia := 1 To Len(aUserAux[1])
        nAtuAux++ 
        //Faz o zebrado ao fundo
        If nAtuAux % 2 == 0
            oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
        EndIf
        oPrintPvt:SayAlign(nLinAtu, nColIni   , aDiaSemana[nDia], oFontDet, 200, 10, , PAD_LEFT  , )
        oPrintPvt:SayAlign(nLinAtu, nColIni+35," - Hora inicial: " + Substr(aUserAux[1][nDia],1,5)  +;
                                               " - Hora final: "   + Substr(aUserAux[1][nDia],7,5)   , oFontDet, 200, 10, , PAD_LEFT  , )
        nLinAtu += 15
    Next
    nLinAtu += 10
Return 

/*/{Protheus.doc} fImpEmpresa
    Imprime horarios que usuário pode acessar o sistema
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022        
    @return Unidefied
/*/
Static Function fImpEmpresa(cUser)

    Local aEmpFil    := {}
    Local aEmpFilAux := {}
    Local nCont      := 0  
    
    fGetEmpresa( cUser, @aEmpFil, @aEmpFilAux )

    fImpSubCab("Empresa/Filial liberados para o usuário")
    For nCont := 1 To Len(aEmpFilAux)
       nAtuAux++
       //Faz o zebrado ao fundo
       If nAtuAux % 2 == 0
           oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
       EndIf
        
       oPrintPvt:SayAlign(nLinAtu, nColIni, aEmpFilAux[nCont], oFontDet, 350, 10, , PAD_LEFT  , )
       nLinAtu += 15
    
       //Se atingiu o limite, quebra de pagina
       fQuebra(,"Empresa/Filial liberados para o usuário")
    Next
    nLinAtu += 10
Return

/*/{Protheus.doc} fGetEmpresa
    Obtem nome das empresas e filiais que usuário tem acesso realizando tratativas necessárias    
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022    
    @param cUser, Character, código do usuário os quais as empresas serão obtidas
    @param aEmpFil, Array, empresas e filiais que usuário tem acesso e serão impressos
    @param aEmpFilAux, Array, com nome das empresas e filiais que usuário tem acesso e serão impressos 
    @return Unidefied
/*/
Static Function fGetEmpresa(cUser, aEmpFil, aEmpFilAux)
    Local nCont := 0

    aEmpFil:= fGetInfoUser(cUser, 2)[6]    

    If Len(aEmpFil) == 1 .And. "@" $ aEmpFil[1]
        aAdd(aEmpFilAux, "TODAS EMPRESAS - TODAS FILIAIS")
    Else
        For nCont := 1 To Len(aEmpFil)
            aAdd(aEmpFilAux, Alltrim(FWEmpName(Substr(aEmpFil[nCont],1,2)))+' - '+;
                             Alltrim(FWFilialName(Substr(aEmpFil[nCont] ,1,2), Substr(aEmpFil[nCont],3))))
        Next
    Endif
Return

/*/{Protheus.doc} fImpGrupos
    Imprime grupos vinculados ao usuário
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022
    @return Unidefied
/*/
Static Function fImpGrupos(aUser)
    Local aGrupos:= {}
    Local nGrupo := 1

    fImpSubCab("Grupos do usuário")
    aGrupos:= UsrRetGrp(aUser[nPosIdUser])
    aGrupos:= Iif(Len(aGrupos) >= 1, aGrupos, {"NÃO PERTENCE A NENHUM GRUPO"})
    For nGrupo := 1 To Len(aGrupos)
        nAtuAux++
        //Faz o zebrado ao fundo
        If nAtuAux % 2 == 0
            oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
        EndIf
        
        oPrintPvt:SayAlign(nLinAtu, nColIni, aGrupos[nGrupo]+" - "+GrpRetName(aGrupos[nGrupo]), oFontDet, 250, 10, , PAD_LEFT  , )
        nLinAtu += 15
    
        //Se atingiu o limite, quebra de pagina
        fQuebra(,"Grupos do usuário")
    Next
    nLinAtu += 10     
Return

/*/{Protheus.doc} fImpModulos
    Imprime modulos que usuário tem acesso
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022    
    @return Unidefied
/*/
Static Function fImpModulos()
    
    Local nModulo      := 1
    fImpSubCab("Módulos do usuário")        

    For nModulo := 1 To Len(aModulosUser)
        If Substr(aModulosUser[nModulo],3,1) != "X"
            nAtuAux++
            //Faz o zebrado ao fundo
            If nAtuAux % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
            EndIf
            oPrintPvt:SayAlign(nLinAtu, nColIni   , aModulos[nModulo][1]+" - "+aModulos[nModulo][2], oFontDet, 250, 10, , PAD_LEFT  , )
            oPrintPvt:SayAlign(nLinAtu, nColIni+75, " - "+aModulos[nModulo][3]                     , oFontDet, 250, 10, , PAD_LEFT  , )
            nLinAtu += 15
            //Se atingiu o limite, quebra de pagina
            fQuebra(,"Módulos do usuário")
        Endif
    Next
    nLinAtu += 10
Return

/*/{Protheus.doc} fImpAcessos
    Imprime os acessos que o usuário possui
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022    
    @return Unidefied
/*/
Static Function fImpAcessos()
    Local nAcesso := 1

    fImpSubCab("Acessos do usuário")
    For nAcesso := 1 To Len(aAcessos)
        nAtuAux++
        //Faz o zebrado ao fundo
        If nAtuAux % 2 == 0
            oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushAzul)
        EndIf
        oPrintPvt:SayAlign(nLinAtu, 10, "[    ]" , oFontDet, 50    , 10, , PAD_LEFT  , )
        If fUserHasAccess(@aUserAux, nAcesso)
            oPrintPvt:SayAlign(nLinAtu, 10, "  X  " , oFontDet, 50 , 10, , PAD_LEFT  , )
        Endif
        oPrintPvt:SayAlign(nLinAtu, 30, cValToChar(aAcessos[nAcesso][1])+ "-"+cValToChar(aAcessos[nAcesso][2]) , oFontDet, 150  	 	 , 10, , PAD_LEFT  , )
        nLinAtu += 15
        //Se atingiu o limite, quebra de pagina
        fQuebra(,"Acessos do usuário")
    Next
Return

/*/{Protheus.doc} fImpCab
    imprime o cabecalho do relatório
    @author Daniel Atilio ( Criação da lógica de estilização do relatório )
    @author Súlivan (Realizado adpatações para regra de negócio)
    @since 28/08/2022
    @return Unidefied
/*/
Static Function fImpCab(aUser)

	Local cTexto   := ""
	Local nLinCab  := 015
    Local nColInfo1:= 065
    
    oPrintPvt:StartPage()

	//Cabecalho
	cTexto := "Listagem de usuários"
	oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
	
	//Linha Separatoria
	nLinCab += 020
	oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)
	
	//Atualizando a linha inicial do relatorio
	nLinAtu := nLinCab + 5
	oPrintPvt:SayAlign(nLinAtu, nColIni  , "Usuário"               , oFontDet,  (nColInfo1 - nColIni ) , 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : " + aUser[nPosLogin], oFontDet,  200                    , 10,           , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni2 , "Bloqueado"   	  	   , oFontDet,  100                    , 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo2, " : "+ Iif(fGetInfoUser(aUser[nPosIdUser], 1)[17],'SIM','NÃO'), oFontDet,  (nColInfo1 - nColIni),  10,           , PAD_LEFT  ,  )

    nLinAtu+=10
    oPrintPvt:SayAlign(nLinAtu, nColIni  , "Nome"                   , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : " + aUser[nPosNomUsr], oFontDet,  200                  , 10,           , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni2 , "Dias p/expirar" 	    , oFontDet,  100                  , 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo2, " : "+cValToChar(fGetInfoUser(aUser[nPosIdUser], 1)[7])  , oFontDet,  (nColInfo1 - nColIni), 10,           , PAD_LEFT  ,  )
    
    nLinAtu+=10
    oPrintPvt:SayAlign(nLinAtu, nColIni  , "E-mail"                 , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : " + aUser[nPosEmailU], oFontDet,  200                  , 10,           , PAD_LEFT  ,  )
	oPrintPvt:SayAlign(nLinAtu, nColIni2  , "Retroage"              , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo2, " : " + cValToChar(fGetInfoUser(aUser[nPosIdUser], 1)[23][2])+" Dia(s)", oFontDet,  200, 10,           , PAD_LEFT  ,  )
    
    nLinAtu+=10
	oPrintPvt:SayAlign(nLinAtu, nColIni  , "Departamento"      	    , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : " + aUser[nPosDepUsr], oFontDet,  200                  , 10,           , PAD_LEFT  ,  )	
    oPrintPvt:SayAlign(nLinAtu, nColIni2 , "Avança"                 , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo2, " : " + cValToChar(fGetInfoUser(aUser[nPosIdUser], 1)[23][3])+" Dia(s)", oFontDet,  200                  , 10,           , PAD_LEFT  ,  )
	
    nLinAtu+=10
	oPrintPvt:SayAlign(nLinAtu, nColIni  , "Cargo"             	   , oFontDet,  (nColInfo1 - nColIni), 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo1, " : " + aUser[nPosCargo], oFontDet,  200                  , 10,           , PAD_LEFT  ,  )	
    oPrintPvt:SayAlign(nLinAtu, nColIni2 , "Acesso Simultâneo: "   , oFontDet,  100                  , 10, nCorCinza , PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu, nColInfo2+25, CValToChar(fGetInfoUser(aUser[nPosIdUser], 1)[15])  , oFontDet,  90, 10,     , PAD_LEFT  ,  )
	
    nLinAtu += 15
    oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)
Return

/*/{Protheus.doc} fImpSubCab
    Realiza a impressão do sub-cabeçalho
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022
    @param param_name, param_type, param_descr
    @return cTexto, Character, texto do sub-cabeçalho a ser impresso
/*/
Static Function fImpSubCab(cTexto)
    
    Local cLinTrac := "- - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - -"
    nAtuAux := 1
    nLinAtu += 15
    oPrintPvt:SayAlign(nLinAtu-6, nColIni, cLinTrac, oFontDet,  (nColFin - nColIni ) , 10, nCorCinza, PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu  , nColIni, cTexto  , oFontDet,  (nColFin - nColIni ) , 10, nCorCinza, PAD_LEFT  ,  )
    oPrintPvt:SayAlign(nLinAtu+6, nColIni, cLinTrac, oFontDet,  (nColFin - nColIni ) , 10, nCorCinza, PAD_LEFT  ,  )
    nLinAtu += 15
Return 

/*/{Protheus.doc} fImpRod
    imprime o rodape do relatório
    @author Daniel Atilio ( Criação da lógica de estilização do relatório )
    @author Súlivan (Realizado adpatações para regra de negócio)
    @since 28/08/2022
    @return Unidefied
/*/
Static Function fImpRod()
	Local nLinRod:= nLinFin
	Local cTexto := ''  

	//Linha Separatoria
	oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
	nLinRod += 3
	
	//Dados da Esquerda
	cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() + " (zRelUsers)     " + UsrRetName(RetCodUsr())
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
    @author Daniel Atilio ( Criação da lógica de estilização do relatório )
    @author Súlivan (Realizado adpatações para regra de negócio)
    @since 28/08/2022
    @param lForce, Logical, força a finalização de uma página e inicialização de outra 
    	   mesmo que a página não tenha acabado. Default .F.
    @param cTextoSubCab, Character, texto do subcabeçalho para a nova página
    @return Unidefied
/*/
Static Function fQuebra(lForce,cTextoSubCab)
    Local nLinCab  := 015

    Default lForce      := .F.
    Default cTextoSubCab:= ""

	If lForce .Or. nLinAtu >= nLinFin-20
		fImpRod()

        nLinAtu := nLinCab + 5
        oPrintPvt:StartPage()

        fImpSubCab(cTextoSubCab)
	EndIf
Return

/*/{Protheus.doc} fGetInfoUser
    Retorna array contendo informações do usuário
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 28/08/2022
    @version version
    @param nRetorno, Numeric, tipo de retorno esperado
            1 - Informações do usuário
            2 - Detalhes do usuário (impressão, configuração de página, tipo de ambiente e etc)
            3 - Menus do usuário.
    @return aArray, Array, array com informações do usuário
    @see Link Totvs
            https://tdn.totvs.com/pages/releaseview.action?pageId=267792734
/*/
Static Function fGetInfoUser(cUser, nRetorno)
    Local aArea      := GetArea()
    Local aArray     := {}
    
    PswOrder(1)
    If PswSeek( cUser, .T. )  
        aArray := PswRet() // Retorna vetor com informações do usuário    
        aArray := aArray[nRetorno]
    Endif
    RestArea(aArea)    
Return aArray

/*/{Protheus.doc} fUserHasAccess
    Verifica se usuário tem ou não acesso determinado acesso liberado
    @type  Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 03/09/2022    
    @param aAcessos, Array, listagem de acessos
    @param nAcess, Numeric, numero do acesso a ser validado
    @return lHasAcess, Logical, .T. se usuário tem acesso libereado, .F. caso contrário    
/*/
Static Function fUserHasAccess(aAcessos, nAcess)
    
    Local lHasAcess  := .T.
    If Substr(aAcessos[5],nAcess,1) == "N"
        Return !lHasAcess
    Endif
Return lHasAcess

/*/{Protheus.doc} fAllModulos
    Retorna array com todos os módulos do ERP
    @type  Static Function
    @author Súlivan Simões (sulivansimoes@gmail.com)
    @since 14/09/2022        
    @return aModulos, Array, array contendo todos módulos do erp
/*/
Static Function fAllModulos()
    Local aModulos :=  {;
                        {"01","SIGAATF"  ,"Ativo Fixo                              "},;
                        {"02","SIGACOM"  ,"Compras                                 "},;
                        {"03","SIGACON"  ,"Contabilidade                           "},;
                        {"04","SIGAEST"  ,"Estoque/Custos                          "},;
                        {"05","SIGAFAT"  ,"Faturamento                             "},;
                        {"06","SIGAFIN"  ,"Financeiro                              "},;
                        {"07","SIGAGPE"  ,"Gestao de Pessoal                       "},;
                        {"08","SIGAFAS"  ,"Faturamento Servico                     "},;
                        {"09","SIGAFIS"  ,"Livros Fiscais                          "},;
                        {"10","SIGAPCP"  ,"Planej.Contr.Producao                   "},;
                        {"11","SIGAVEI"  ,"Veiculos                                "},;
                        {"12","SIGALOJA" ,"Controle de Lojas                       "},;
                        {"13","SIGATMK"  ,"Call Center                             "},;
                        {"14","SIGAOFI"  ,"Oficina                                 "},;
                        {"15","SIGARPM"  ,"Gerador de Relatorios Beta1             "},;
                        {"16","SIGAPON"  ,"Ponto Eletronico                        "},;
                        {"17","SIGAEIC"  ,"Easy Import Control                     "},;
                        {"18","SIGAGRH"  ,"Gestao de R.Humanos                     "},;
                        {"19","SIGAMNT"  ,"Manutencao de Ativos                    "},;
                        {"20","SIGARSP"  ,"Recrutamento e Selecao Pessoal          "},;
                        {"21","SIGAQIE"  ,"Inspecao de Entrada                     "},;
                        {"22","SIGAQMT"  ,"Metrologia                              "},;
                        {"23","SIGAFRT"  ,"Front Loja                              "},;
                        {"24","SIGAQDO"  ,"Controle de Documentos                  "},;
                        {"25","SIGAQIP"  ,"Inspecao de Projetos                    "},;
                        {"26","SIGATRM"  ,"Treinamento                             "},;
                        {"27","SIGAEIF"  ,"Importacao - Financeiro                 "},;
                        {"28","SIGATEC"  ,"Field Service                           "},;
                        {"29","SIGAEEC"  ,"Easy Export Control                     "},;
                        {"30","SIGAEFF"  ,"Easy Financing                          "},;
                        {"31","SIGAECO"  ,"Easy Accounting                         "},;
                        {"32","SIGAAFV"  ,"Administracao de Forca de Vendas        "},;
                        {"33","SIGAPLS"  ,"Plano de Saude                          "},;
                        {"34","SIGACTB"  ,"Contabilidade Gerencial                 "},;
                        {"35","SIGAMDT"  ,"Medicina e Seguranca no Trabalho        "},;
                        {"36","SIGAQNC"  ,"Controle de Nao-Conformidades           "},;
                        {"37","SIGAQAD"  ,"Controle de Auditoria                   "},;
                        {"38","SIGAQCP"  ,"Controle Estatistico de Processos       "},;
                        {"39","SIGAOMS"  ,"Gestao de Distribuicao                  "},;
                        {"40","SIGACSA"  ,"Cargos e Salarios                       "},;
                        {"41","SIGAPEC"  ,"Auto Pecas                              "},;
                        {"42","SIGAWMS"  ,"Gestao de Armazenagem                   "},;
                        {"43","SIGATMS"  ,"Gestao de Transporte                    "},;
                        {"44","SIGAPMS"  ,"Gestao de Projetos                      "},;
                        {"45","SIGACDA"  ,"Controle de Direitos Autorais           "},;
                        {"46","SIGAACD"  ,"Automacao Coleta de Dados               "},;
                        {"47","SIGAPPA"  ,"PPAP                                    "},;
                        {"48","SIGAREP"  ,"Replica                                 "},;
                        {"49","SIGAGAC"  ,"Gerenciamento Academico                 "},;
                        {"50","SIGAEDC"  ,"Easy DrawBack Control                   "},;
                        {"51","SIGAHSP"  ,"Gestao Hospitalar                       "},;
                        {"52","SIGADOC"  ,"Viewer                                  "},;
                        {"53","SIGAAPD"  ,"Avaliacao e Pesquisa de Desempenho      "},;
                        {"54","SIGAGSP"  ,"Gestao de Serviços Publicos             "},;
                        {"55","SIGACRD"  ,"Sistema de Fidel.e Analise Credito      "},;
                        {"56","SIGASGA"  ,"Gestao Ambiental                        "},;
                        {"57","SIGAPCO"  ,"Planejamento e Controle Orcamentario    "},;
                        {"58","SIGAGPR"  ,"Gestao de Pesquisa e Resultados         "},;
                        {"59","SIGAGAC"  ,"Gestao de Acervos                       "},;
                        {"60","SIGAHEO"  ,"HRP Estrutura Organizacional            "},;
                        {"61","SIGAHGP"  ,"HRP Gestao de Pessoal                   "},;
                        {"62","SIGAHHG"  ,"HRP Ferramentas de Informacao           "},;
                        {"63","SIGAHPL"  ,"HRP Planejamento e Desenvolvimento      "},;
                        {"64","SIGAAPT"  ,"Acompanhamento de Processos Trabalhistas"},;
                        {"65","SIGAGAV"  ,"Gestao Advocaticia                      "},;
                        {"66","SIGAICE"  ,"Gestao de Riscos                        "},;
                        {"67","SIGAAGR"  ,"Gestao Agricolas - Graos                "},;
                        {"68","SIGAARM"  ,"Gestao de Armazens Gerais               "},;
                        {"69","SIGAGCT"  ,"Gestao de Contratos                     "},;
                        {"70","SIGAORG"  ,"Arquitetura Organizacional              "},;
                        {"71","SIGALVE"  ,"Locacao de Veiculos                     "},;
                        {"72","SIGAPHOTO","Controle de Lojas - Photo               "},;
                        {"73","SIGACRM"  ,"Costumer Relationship Management        "},;
                        {"74","SIGABPM"  ,"BPM - Business Process Management       "},;
                        {"75","SIGAAPON" ,"Apontamento/Ponto Eletronico            "},;
                        {"76","SIGAJURI" ,"Juridico                                "},;
                        {"77","SIGAPFS"  ,"Pre-Faturamento de Servicos             "},;
                        {"78","SIGAGFE"  ,"Gestao de Frete Embarcador              "},;
                        {"79","SIGASFC"  ,"Chão de Fábrica                         "},;
                        {"80","SIGAACV"  ,"Acessibilidade Visual                   "},;
                        {"81","SIGALOG"  ,"Monitoramento de Desempenho Logistico   "},;
                        {"82","SIGADPR"  ,"Desenvolvedor de Produtos               "},;
                        {"83","SIGAVPON" ,"Monitoramento de Apontamentos           "},;
                        {"84","SIGATAF"  ,"TOTVS Automação Fiscal                  "},;
                        {"85","SIGAESS"  ,"Easy Siscoserv                          "},;
                        {"86","SIGAVDF"  ,"Vida Funcional                          "},;
                        {"87","SIGAGCP"  ,"Gestão de Licitações                    "},;
                        {"88","SIGAGTP"  ,"Transporte de Passageiros               "},;
                        {"89","SIGATUR"  ,"Gestão de Viagens e Turismo             "},;
                        {"90","SIGAGCV"  ,"Gestão Comercial do Varejo              "},;
                        {"91","SIGAPDS"  ,"Promoção da Saúde                       "},;
                        {"92","SIGATFL"  ,"TOTVS Automação Fiscal                  "},;
                        {"93","SIGACEN"  ,"Central de obrigações                   "},;
                        {"94","SIGALOC"  ,"Locação de Equipamentos                 "},;
                        {"95","SIGAGFR"  ,"Gestão de Frotas                        "},;
                        {"96","SIGAESP2" ,"Especificos II                          "},;
                        {"97","SIGAESP"  ,"Especificos                             "},;
                        {"98","SIGAESP1" ,"Especificos I                           "},;
                        {"99","SIGACFG"  ,"Configurador                            "}}
Return aModulos

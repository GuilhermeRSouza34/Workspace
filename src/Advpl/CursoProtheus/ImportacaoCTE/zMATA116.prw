#Include 'totvs.ch'

#Define XML_DE_CTE 1
#Define XML_DE_NFE 2

/*/{Protheus.doc} zMATA116
    obtem o persistencia  objeto de persistencia especifica
    @author Súlivan Simões (sulivan@atiliosistemas.com)
    @since 11/04/2022
    @version 1.0
    @see Link Totvs
            https://tdn.totvs.com/pages/releaseview.action?pageId=6085187
/*/
Class zMATA116
    
    Private Data nOperation As Numeric

    //Construtor
	Public Method New()	Constructor

    //Outros Métodos
    Public Method Commit(oNF As Object) As Logical 

EndClass

/*/{Protheus.doc} New
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 11/04/2022
    @version 1.0    
    @return Undefinied
/*/
Method New() Class zMATA116
    ::nOperation := 2
    FwLogMsg("INFO", /*cTransactionId*/, "<zMATA116>[New]", FunName(), "", "01", "Classe zMATA116 instanciada", 0, 0, {})
Return 

/*/{Protheus.doc} Commit
    Realiza o commit da nota pela rotina MATA103 via execAuto
    @author Súlivan Simões (sulivan@atiliosistemas.com)
    @since 11/04/2022    
    @param oNF, Object, objeto de nf-e que deve ser persistido
    @return lMsErroAuto, Logical, .F. caso tenha ocorrido um erro no commit, .T. caso contrário
/*/
Method Commit(oNF) Class zMATA116
   
    Local cCgcEmit   := oNF:GetGCG()
    Local cCodigo    := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_COD" )
    Local cLoja      := Posicione("SA2",3,FWxFilial("SA2")+ cCgcEmit,"A2_LOJA")
    Local cParCond   := cParCond_
    Local cParTes    := cParTes_
    Local nFormProrio:= 1
    Local nTipoNF    := 1
    Local nNaoAglut  := 2
    Local aCabec116  := {}
    Local aItens116  := {}
    Local cPastaErro := GetTempPath()
    Local cNomeErro  := "zMATA116_"+ dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local cTextoErro := ""
    Local aLogErro   := {}
    Local nLinhaErro := 0

    Private lMsErroAuto    := .F.
    Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	aAdd(aCabec116, {""          ,  DaySub(dDataBase, 90)               }) // Data inicial para filtro das notas
	aAdd(aCabec116, {""          ,  dDataBase                           }) // Data final para filtro das notas
	aAdd(aCabec116, {""          ,  ::nOperation                        }) // 2-Inclusao ; 1=Exclusao
	aAdd(aCabec116, {""          ,  Space(GetSX3Cache("F1_FORNECE","X3_TAMANHO")) })    // Rementente das notas contidas no conhecimento
	aAdd(aCabec116, {""          ,  Space(GetSX3Cache("F1_LOJA"   ,"X3_TAMANHO")) })
	aAdd(aCabec116, {""          ,  nTipoNF                             }) // Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
	aAdd(aCabec116, {""          ,  nNaoAglut                           }) // 1=Aglutina itens ; 2=Nao aglutina itens
	aAdd(aCabec116, {"F1_EST"    ,  ""                                  }) // UF das notas contidas no conhecimento
	aAdd(aCabec116, {""          ,  oNF:GetValorPrestacaoServico()      }) // Valor do conhecimento
	aAdd(aCabec116, {"F1_FORMUL" ,  nFormProrio                         }) // Formulario proprio: 1=Nao ; 2=Sim
	aAdd(aCabec116, {"F1_DOC"    ,  oNF:GetNumeroNotaFiscal()           }) // Numero da nota de conhecimento
	aAdd(aCabec116, {"F1_SERIE"  ,  oNF:GetSerieNotaFiscal()            }) // Serie da nota de conhecimento
	aAdd(aCabec116, {"F1_FORNECE",  cCodigo                             }) // Fornecedor da nota de conhecimento
	aAdd(aCabec116, {"F1_LOJA"   ,  cLoja                               }) // Loja do fornecedor da nota de conhecimento
	aAdd(aCabec116, {""          ,  cParTes                             }) // TES a ser utilizada nos itens do conhecimento
	aAdd(aCabec116, {"F1_BASERET",  oNF:GetBaseDeCalculoICMS()          }) // Valor da base de calculo do ICMS retido
	aAdd(aCabec116, {"F1_ICMRET" ,  oNF:GetValorICMS()                  }) // Valor do ICMS retido
	aAdd(aCabec116, {"F1_COND"   ,  cParCond                            }) // Condicao de pagamento
	aAdd(aCabec116, {"F1_EMISSAO",  oNF:GetDataEmissao()                }) // Data de emissao do conhecimento
	aAdd(aCabec116, {"F1_ESPECIE",  "CTE"                               }) // Especie do documento
	
	MsExecAuto({|x, y, z| MATA116(x, y, z)}, aCabec116, aItens116, {})

    If(lMsErroAuto)
        
        aLogErro := GetAutoGRLog()
        For nLinhaErro := 1 To Len(aLogErro)
            cTextoErro += aLogErro[nLinhaErro] + CRLF
        Next

        //Criando o arquivo txt e incrementa o log
        MemoWrite(cPastaErro + cNomeErro, cTextoErro)   
        //Se tiver log, mostra ele
        If ! Empty(cTextoErro)            
            ShellExecute("OPEN", cNomeErro, "", cPastaErro, 1)
        EndIf
    EndIf

Return !lMsErroAuto

#Include 'totvs.ch'

#Define XML_DE_CTE 1
#Define XML_DE_NFE 2

/*/{Protheus.doc} zMATA140CTe
    obtem o persistencia  objeto de persistencia especifica
    @author Súlivan Simões (sulivan@atiliosistemas.com)
    @since 10/07/2022
    @version 1.0
/*/
Class zMATA140CTe
    
    Private Data oPersistence As Object
    
    //Construtor
	Public Method New()	Constructor

    //Outros Métodos
    Public Method Commit(oNF As Object) As Logical 

EndClass

/*/{Protheus.doc} New
    @author Sulivan Simoes (sulivan@atiliosistemas.com)
    @since 10/07/2022
    @version 1.0      
/*/
Method New() Class zMATA140CTe
    Local lIsPreNota:= .T.
    
    ::oPersistence:= zMATA103CTe():New(lIsPreNota)

    FwLogMsg("INFO", /*cTransactionId*/, "<zMATA140CTe>[New]", FunName(), "", "01", "Classe zMATA140CTe instanciada", 0, 0, {})
Return 

/*/{Protheus.doc} Commit
    Realiza o commit da nota pela rotina MATA103/MATA140 via execAuto
    @author Súlivan Simões (sulivan@atiliosistemas.com)
    @since 10/07/2022    
    @param oNF, Object, objeto de nf-e que deve ser persistido
    @return lMsErroAuto, Logical, .F. caso tenha ocorrido um erro no commit, .T. caso contrário
/*/
Method Commit(oNF) Class zMATA140CTe
   
    Local lMsErroAuto := ::oPersistence:Commit(oNF)
Return !lMsErroAuto

#Include 'totvs.ch'

#Define MATA103_CTE_NOTA 2
#Define MATA103_CTE_PRE_NOTA 1
#Define MATA116 3

/*/{Protheus.doc}zDocEntFactory
obtem o persistencia  objeto de persistencia especifica
@author Súlivan Simões (sulivan@atiliosistemas.com)        
/*/
Class zDocEntFactory From LongNameClass

    Static Method GetStrategyFor(nOperation As Numeric) As Variadic
    
EndClass

/*/{Protheus.doc} GetStrategyFor
obtem o classe especifica de persistencia
@author Súlivan Simões (sulivan@atiliosistemas.com)
@since 28/03/2022
@param nOperation, Numeric, operação indicando o tipo de arquivo que será convertido.
@return Variadic, objeto conforme especificado no parametro
/*/
Method GetStrategyFor(nOperation) Class zDocEntFactory As Variadic 
    
    Default nOperation := -1
    
	Do Case
        Case nOperation == MATA103_CTE_NOTA
            Return zMATA103CTe():New()   
        Case nOperation == MATA103_CTE_PRE_NOTA
            Return zMATA140CTe():New()   
        Case nOperation == MATA116
            Return zMATA116():New()                
        Otherwise
            FwLogMsg("ERROR", /*cTransactionId*/, "<zDocEntFactory>[GetStrategyFor]", FunName(), "", "01", "Strategy "+CValToChar(nOperation)+" nao encontrada", 0, 0, {})
    EndCase

Return Nil


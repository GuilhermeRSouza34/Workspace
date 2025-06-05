#Include 'totvs.ch'

#Define XML_DE_CTE 1
#Define XML_DE_NFE 2
#Define MATA103_CTE_NOTA 2
#Define MATA103_CTE_PRE_NOTA 1
#Define MATA116 3

/*/{Protheus.doc}zConvetFileToObjectFactory
obtem o conversor especifico de arquivo para objeto
@author Súlivan Simões (sulivan@atiliosistemas.com)        
/*/
Class zConvetFileToObjectFactory From LongNameClass

    Static Method GetStrategyFor(nOperation As Numeric) As Variadic
    
EndClass

/*/{Protheus.doc} GetStrategyFor
obtem o conversor especifico de arquivo para objeto
@author Súlivan Simões (sulivan@atiliosistemas.com)
@since 28/03/2022
@param nOperation, Numeric, operação indicando o tipo de arquivo que será convertido.
@return Variadic, objeto de conversão conforme especificado no parametro
/*/
Method GetStrategyFor(nOperation) Class zConvetFileToObjectFactory As Variadic 
    
    Default nOperation := -1
	
	Do Case
        Case nOperation == XML_DE_CTE
            Return zConvertXMLCTeStrategy():New()   
        Case nOperation == XML_DE_NFE
            /*/@TODO 
                future implements
            /*/
            FwLogMsg("WARN", /*cTransactionId*/, "<zConvetFileToObjectFactory>[GetStrategyFor]", FunName(), "", "01", "Strategy "+CValToChar(nOperation)+" nao implementada", 0, 0, {})
            Return Nil                  
        Otherwise
            FwLogMsg("ERROR", /*cTransactionId*/, "<zConvetFileToObjectFactory>[GetStrategyFor]", FunName(), "", "01", "Strategy "+CValToChar(nOperation)+" nao encontrada", 0, 0, {})
    EndCase

Return Nil

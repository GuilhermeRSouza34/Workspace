#Include 'Totvs.ch'

#Define XML_DE_NFE 1
#Define XML_DE_CTE 2

/*/{Protheus.doc}zConvetFileToObjectFactory
obtem o conversor especifico de arquivo para objeto
@author S�livan Sim�es (sulivansimoes@gmail.com)        
/*/
Class zConvetFileToObjectFactory From LongNameClass

    Static Method GetStrategyFor(nOperation As Numeric) As Variadic
    
EndClass

/*/{Protheus.doc} GetStrategyFor
obtem o conversor especifico de arquivo para objeto
@author S�livan Sim�es (sulivansimoes@gmail.com)
@since 09/2024
@param nOperation, Numeric, opera��o indicando o tipo de arquivo que ser� convertido.
@return Variadic, objeto de convers�o conforme especificado no parametro
/*/
Method GetStrategyFor(nOperation) Class zConvetFileToObjectFactory As Variadic 
    
    Default nOperation := -1
	
	Do Case
        Case nOperation == XML_DE_NFE
            Return zConvertXMLNFeStrategy():New()   
        Case nOperation == XML_DE_CTE
            Return zConvertXMLCTeStrategy():New()   
            Return Nil                  
        Otherwise
            u_zConOut("<zConvetFileToObjectFactory>[GetStrategyFor] Strategy "+CValToChar(nOperation)+" nao encontrada") 
    EndCase

Return Nil

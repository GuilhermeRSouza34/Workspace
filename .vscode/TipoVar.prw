User Function Func1()
Local cVar1 := "Local"
Private cVar2 := "Private"

U_Func2()

Alert(cVar2) //Private
Alert(cVar1) //Local

RETURN

User Function U_Func2()
public cVar3 := "Public"
public cVar4 := "Private 2"

Alert(cVar2) //Private
Alert(cVar3) //Public

U_Func3()

RETURN

User Function U_Func3()

Alert(cVar3) //Global
Alert(cVar2) //Private

RETURN

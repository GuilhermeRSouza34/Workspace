/*/{Protheus.doc} IoT Integration System
    @type  function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     IoT Integration System for Protheus - Real-time production monitoring
    @see     https://tdn.totvs.com
*/

#include "protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"

#Define IOT_ENDPOINT "http://localhost:8080/iot"
#Define REFRESH_RATE 5 // Seconds

/*/{Protheus.doc} User Function IOTSTART
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Initialize IoT monitoring
    @param   cProductionLine, character, Production line identifier
    @return  logical, Success status
*/
User Function IOTSTART(cProductionLine)
    Local lRet      := .T.
    Local aAreaSC2  := SC2->(GetArea())
    Local cEndpoint := SuperGetMV("MV_IOTEND", .F., IOT_ENDPOINT)
    Local nRefresh  := SuperGetMV("MV_IOTREF", .F., REFRESH_RATE)
    
    Private aSensors := {}
    
    // Validate parameters
    If Empty(cProductionLine)
        MsgStop("Production line not specified", "Error")
        Return .F.
    EndIf
    
    // Initialize sensors
    If !InitSensors(cProductionLine)
        MsgStop("Failed to initialize sensors", "Error")
        Return .F.
    EndIf
    
    // Start monitoring thread
    StartMonitoring(cProductionLine, cEndpoint, nRefresh)
    
    RestArea(aAreaSC2)
    Return lRet
Return

/*/{Protheus.doc} InitSensors
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Initialize IoT sensors
    @param   cProductionLine, character, Production line identifier
    @return  logical, Success status
*/
Static Function InitSensors(cProductionLine)
    Local lRet := .T.
    Local oSensor
    
    // Temperature sensor
    oSensor := JsonObject():New()
    oSensor['type'] := "TEMPERATURE"
    oSensor['id']   := "TEMP_" + cProductionLine
    oSensor['unit'] := "Celsius"
    aAdd(aSensors, oSensor)
    
    // Humidity sensor
    oSensor := JsonObject():New()
    oSensor['type'] := "HUMIDITY"
    oSensor['id']   := "HUM_" + cProductionLine
    oSensor['unit'] := "%"
    aAdd(aSensors, oSensor)
    
    // Pressure sensor
    oSensor := JsonObject():New()
    oSensor['type'] := "PRESSURE"
    oSensor['id']   := "PRESS_" + cProductionLine
    oSensor['unit'] := "PSI"
    aAdd(aSensors, oSensor)
    
    // Vibration sensor
    oSensor := JsonObject():New()
    oSensor['type'] := "VIBRATION"
    oSensor['id']   := "VIB_" + cProductionLine
    oSensor['unit'] := "Hz"
    aAdd(aSensors, oSensor)
    
    Return lRet
Return

/*/{Protheus.doc} StartMonitoring
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Start monitoring thread
    @param   cProductionLine, character, Production line identifier
    @param   cEndpoint, character, IoT endpoint
    @param   nRefresh, numeric, Refresh rate in seconds
    @return  logical, Success status
*/
Static Function StartMonitoring(cProductionLine, cEndpoint, nRefresh)
    Local lRet := .T.
    
    // Start monitoring in a separate thread
    StartJob("U_MonitoringThread", GetEnvServer(), .F., cProductionLine, cEndpoint, nRefresh)
    
    Return lRet
Return

/*/{Protheus.doc} User Function MonitoringThread
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Monitoring thread function
    @param   cProductionLine, character, Production line identifier
    @param   cEndpoint, character, IoT endpoint
    @param   nRefresh, numeric, Refresh rate in seconds
*/
User Function MonitoringThread(cProductionLine, cEndpoint, nRefresh)
    Local oData
    Local nI
    
    While .T.
        // Collect sensor data
        oData := JsonObject():New()
        oData['timestamp'] := DtoC(Date()) + " " + Time()
        oData['line'] := cProductionLine
        oData['sensors'] := {}
        
        // Read sensors
        For nI := 1 To Len(aSensors)
            oSensorData := ReadSensor(aSensors[nI])
            aAdd(oData['sensors'], oSensorData)
        Next nI
        
        // Send data to IoT platform
        SendToIoT(oData:ToJson(), cEndpoint)
        
        // Process alerts
        ProcessAlerts(oData)
        
        // Wait for next reading
        Sleep(nRefresh * 1000)
    EndDo
Return

/*/{Protheus.doc} ReadSensor
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Read sensor data
    @param   oSensor, object, Sensor configuration
    @return  object, Sensor reading
*/
Static Function ReadSensor(oSensor)
    Local oReading := JsonObject():New()
    
    oReading['id'] := oSensor['id']
    oReading['type'] := oSensor['type']
    oReading['value'] := GetSensorValue(oSensor['type'])
    oReading['unit'] := oSensor['unit']
    oReading['timestamp'] := DtoC(Date()) + " " + Time()
    
    Return oReading
Return

/*/{Protheus.doc} GetSensorValue
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Get sensor reading value
    @param   cType, character, Sensor type
    @return  numeric, Sensor value
*/
Static Function GetSensorValue(cType)
    Local nValue := 0
    
    // Simulate sensor readings
    Do Case
        Case cType == "TEMPERATURE"
            nValue := Randomize(20, 30) // 20-30°C
        Case cType == "HUMIDITY"
            nValue := Randomize(40, 60) // 40-60%
        Case cType == "PRESSURE"
            nValue := Randomize(14, 15) // 14-15 PSI
        Case cType == "VIBRATION"
            nValue := Randomize(10, 100) // 10-100 Hz
    EndCase
    
    Return nValue
Return

/*/{Protheus.doc} SendToIoT
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Send data to IoT platform
    @param   cJson, character, JSON data
    @param   cEndpoint, character, IoT endpoint
    @return  logical, Success status
*/
Static Function SendToIoT(cJson, cEndpoint)
    Local oRest := FWRest():New(cEndpoint)
    Local lRet := .T.
    
    oRest:SetPath("/data")
    oRest:SetPostParams(cJson)
    
    If !oRest:Post()
        ConOut("IoT Error: " + oRest:GetLastError())
        lRet := .F.
    EndIf
    
    Return lRet
Return

/*/{Protheus.doc} ProcessAlerts
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Process sensor alerts
    @param   oData, object, Sensor data
    @return  logical, Success status
*/
Static Function ProcessAlerts(oData)
    Local lRet := .T.
    Local nI
    Local oSensor
    Local cMsg := ""
    
    For nI := 1 To Len(oData['sensors'])
        oSensor := oData['sensors'][nI]
        
        // Check for alert conditions
        Do Case
            Case oSensor['type'] == "TEMPERATURE" .And. oSensor['value'] > 28
                cMsg := "High temperature alert: " + cValToChar(oSensor['value']) + "°C"
            Case oSensor['type'] == "HUMIDITY" .And. oSensor['value'] > 55
                cMsg := "High humidity alert: " + cValToChar(oSensor['value']) + "%"
            Case oSensor['type'] == "PRESSURE" .And. oSensor['value'] > 14.5
                cMsg := "High pressure alert: " + cValToChar(oSensor['value']) + " PSI"
            Case oSensor['type'] == "VIBRATION" .And. oSensor['value'] > 90
                cMsg := "High vibration alert: " + cValToChar(oSensor['value']) + " Hz"
        EndCase
        
        // Send alert if needed
        If !Empty(cMsg)
            U_SendAlert(cMsg, oData['line'])
        EndIf
    Next nI
    
    Return lRet
Return

/*/{Protheus.doc} User Function SendAlert
    @type  Function
    @version  1.0
    @author  Guilherme
    @since   02/04/2025
    @obs     Send alert notification
    @param   cMessage, character, Alert message
    @param   cLine, character, Production line
    @return  logical, Success status
*/
User Function SendAlert(cMessage, cLine)
    Local lRet := .T.
    Local cSubject := "IoT Alert - Production Line " + cLine
    Local cBody := cMessage + CRLF + ;
                  "Timestamp: " + DtoC(Date()) + " " + Time() + CRLF + ;
                  "Line: " + cLine
    
    // Send email alert
    U_SendMail(cSubject, cBody)
    
    // Log alert
    ConOut("[IoT Alert] " + cBody)
    
    Return lRet
Return 

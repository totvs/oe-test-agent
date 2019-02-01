
/*------------------------------------------------------------------------
    File        : OEUtils.p
    Purpose     : Utilities for "OE Test Agent" application. 

    Syntax      :

    Description : "OE Test Agent" Utils

    Author(s)   : Rubens Dos Santos Filho
    Created     : Thu Nov 08 17:19:27 BRST 2018
    Notes       :
  ----------------------------------------------------------------------*/

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING Progress.Json.ObjectModel.ObjectModelParser FROM PROPATH.

/* **********************  Internal Procedures  *********************** */
/*------------------------------------------------------------------------------
 Purpose: Extract the commands sent from client by the socket communication.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE GetSocketCommands:
    DEFINE INPUT  PARAMETER cInput   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER lWait    AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER cCommand AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER aParams  AS CHARACTER NO-UNDO EXTENT.
    
    DEFINE VARIABLE nCount  AS INTEGER NO-UNDO.
    DEFINE VARIABLE nParam  AS INTEGER NO-UNDO.
    DEFINE VARIABLE nOffset AS INTEGER NO-UNDO INITIAL 2.
    
    nCount = NUM-ENTRIES(cInput,"|") - nOffset.
    
    IF  nCount > 0 THEN
        EXTENT(aParams) = nCount.
        
    ASSIGN
        lWait    = LOGICAL(ENTRY(1,cInput,"|"))
        cCommand = ENTRY(2,cInput,"|").
    
    DO  nParam = 1 TO nCount:
        aParams[nParam] = ENTRY(nParam + nOffset,cInput,"|").
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Run a PROCEDURE or application.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE RunApplication:
    DEFINE INPUT PARAMETER cRun    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cParams AS CHARACTER NO-UNDO.
        
    DEFINE VARIABLE hCall  AS HANDLE  NO-UNDO.
    DEFINE VARIABLE nParam AS INTEGER NO-UNDO.
    
    CREATE CALL hCall.

    hCall:CALL-NAME = cRun.
    hCall:CALL-TYPE = PROCEDURE-CALL-TYPE.
    
    hCall:NUM-PARAMETERS = NUM-ENTRIES(cParams).
    
    /* Verify reserved words into the informed parameters */
    DO  nParam = 1 TO hCall:NUM-PARAMETERS:
        IF  ENTRY(nParam,cParams) = "THIS-PROCEDURE" THEN
            hCall:SET-PARAMETER(nParam, "HANDLE", "INPUT", THIS-PROCEDURE).
        ELSE
            hCall:SET-PARAMETER(nParam, "CHARACTER", "INPUT", ENTRY(nParam, cParams)).
    END.
    
    hCall:INVOKE.
    DELETE OBJECT hCall NO-ERROR.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Simulate a mouse click on the informed element.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE MouseClick:
    DEFINE INPUT PARAMETER hElement AS HANDLE NO-UNDO.
    DEFINE VARIABLE nReturn AS INTEGER NO-UNDO.
    
    RUN PostMessageA(INPUT hElement:HWND, INPUT 513, INPUT 1, INPUT 0, OUTPUT nReturn). /* MouseDown */
    RUN PostMessageA(INPUT hElement:HWND, INPUT 514, INPUT 1, INPUT 0, OUTPUT nReturn). /* MouseUp */
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Parse a character JSON to a JsonObject instance.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE ParseChar2JsonObject:
    DEFINE INPUT  PARAMETER cJson AS CHARACTER  NO-UNDO. 
    DEFINE OUTPUT PARAMETER oJson AS JsonObject NO-UNDO.

    DEFINE VARIABLE oParse AS ObjectModelParser NO-UNDO.
    
    ASSIGN
        oParse = NEW ObjectModelParser()
        oJson  = CAST(oParse:Parse(cJson), JsonObject).
      
    DELETE OBJECT oParse NO-ERROR.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Parse a character JSON to a JsonArray instance.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE ParseChar2JsonArray:
    DEFINE INPUT  PARAMETER cJson AS CHARACTER  NO-UNDO. 
    DEFINE OUTPUT PARAMETER oJson AS JsonArray  NO-UNDO.

    DEFINE VARIABLE oParse AS ObjectModelParser NO-UNDO.
    
    ASSIGN
        oParse = NEW ObjectModelParser()
        oJson  = CAST(oParse:Parse(cJson), JsonArray).
      
    DELETE OBJECT oParse NO-ERROR.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Emits info messages on client log.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE DoLog:
    DEFINE INPUT PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cMessage AS CHARACTER NO-UNDO.

    LOG-MANAGER:WRITE-MESSAGE("[" + TRIM(cName) + "] " + TRIM(cMessage), "OEAGENT") NO-ERROR.
    "1"="1" NO-ERROR. /* Clears ERROR-STATUS */
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: USER32 utility.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE PostMessageA EXTERNAL "user32.dll":
    DEFINE INPUT  PARAMETER hwnd    AS LONG.
    DEFINE INPUT  PARAMETER umsg    AS LONG.
    DEFINE INPUT  PARAMETER wparam  AS LONG.
    DEFINE INPUT  PARAMETER lparam  AS LONG.
    DEFINE RETURN PARAMETER lReturn AS LONG.
END PROCEDURE.

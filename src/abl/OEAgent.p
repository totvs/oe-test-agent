/*------------------------------------------------------------------------
    File        : OEAgent.p
    Purpose     : "OE Test Agent" main application.

    Syntax      :

    Description : OE Test Agent

    Author(s)   : Rubens Dos Santos Filho
    Notes       :
  ----------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

DEFINE INPUT PARAMETER cHost     AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER nPort     AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER cCodePage AS CHARACTER NO-UNDO.

DEFINE VARIABLE hWindow  AS HANDLE    NO-UNDO.
DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
DEFINE VARIABLE hUtils   AS HANDLE    NO-UNDO.

/* ***************************  Main Block  *************************** */

RUN OEUtils.p PERSISTENT SET hUtils.

/* -------------------------  USER INTERFACE  ------------------------- */
DEFINE FRAME hFrame
    cMessage AT ROW 1 COL 2 NO-LABELS FORMAT "x(50)"
    WITH NO-BOX OVERLAY SIZE 60 BY 01 BGCOLOR 14.

IF  SESSION:DISPLAY-TYPE = "GUI":U THEN
    CREATE WINDOW hWindow
        ASSIGN
        HIDDEN       = TRUE
        TITLE        = "OE TEST AGENT"
        HEIGHT       = 01
        WIDTH        = 60
        RESIZE       = FALSE
        SCROLL-BARS  = FALSE
        STATUS-AREA  = FALSE
        THREE-D      = TRUE
        MESSAGE-AREA = FALSE
        SENSITIVE    = TRUE.
ELSE
    hWindow = CURRENT-WINDOW.

IF  SESSION:DISPLAY-TYPE = "GUI" AND VALID-HANDLE(hWindow) THEN
    hWindow:HIDDEN = FALSE.

ASSIGN
    CURRENT-WINDOW = hWindow
    THIS-PROCEDURE:CURRENT-WINDOW = hWindow.

PAUSE 0 BEFORE-HIDE.

/* --------------------------  UI TRIGGERS  --------------------------- */
ON  "WINDOW-CLOSE" OF hWindow
DO:
    APPLY "CLOSE" TO THIS-PROCEDURE.
END.

ON  "CLOSE" OF THIS-PROCEDURE
DO:
    RUN DisableUI.
END.

/* ----------------------------  INCLUDES  ---------------------------- */
{includes/Socket.i cHost nPort cCodePage AgentConnected AgentIO}

{includes/FindElement.i}
{includes/Statement.i}

/* ---------------------------  MAIN BLOCK  --------------------------- */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN EnableUI.

    IF  NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

QUIT.

/* **********************  Internal Procedures  *********************** */

/*------------------------------------------------------------------------------
 Purpose: Enable the UI and start the agent.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE EnableUI PRIVATE:
    VIEW FRAME hFrame IN WINDOW hWindow.
    VIEW hWindow.

    cMessage:SCREEN-VALUE IN FRAME hFrame = "Waiting client connection...".
    RUN EnableSocket.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Disable the UI and quit the agent.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE DisableUI PRIVATE:
    RUN CloseSocket.
    DELETE WIDGET hWindow.

    IF  THIS-PROCEDURE:PERSISTENT THEN
        DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Event fired when a client connects the agent's server.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE AgentConnected PRIVATE:
    cMessage:SCREEN-VALUE IN FRAME hFrame = "Waiting commands...".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Event fired when a client sends data to the agent's server.
 Notes: This is where the communication happens and the commands are executed.
------------------------------------------------------------------------------*/
PROCEDURE AgentIO PRIVATE:
    DEFINE INPUT  PARAMETER cInput  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO INITIAL ?.

    DEFINE VARIABLE cCommand AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aParams  AS CHARACTER NO-UNDO EXTENT.
    DEFINE VARIABLE lWait    AS LOGICAL   NO-UNDO.

    RUN DoLog IN hUtils (INPUT "SOCKET-IO", INPUT "Received data: " + cInput).
    RUN GetSocketCommands IN hUtils (INPUT cInput, OUTPUT lWait, OUTPUT cCommand, OUTPUT aParams).

    cMessage:SCREEN-VALUE IN FRAME hFrame = "Executing command ~"" + cCommand + "~"".
    RUN DoLog IN hUtils (INPUT "SOCKET-IO", INPUT cMessage:SCREEN-VALUE).

    CASE cCommand:
        WHEN "FINDWINDOW" THEN
            RUN FindWindow(INPUT aParams[1], OUTPUT cOutput).

        WHEN "FINDELEMENT" THEN
            RUN FindElement(INPUT aParams[1], INPUT aParams[2], INPUT aParams[3], OUTPUT cOutput).

        WHEN "FINDELEMENTBYATTRIBUTE" THEN
            RUN FindElementByAttribute(INPUT aParams[1], INPUT aParams[2], INPUT aParams[3], INPUT aParams[4], OUTPUT cOutput).

        WHEN "GET" THEN
            RUN Get(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "SET" THEN
            RUN Set(INPUT aParams[1], INPUT aParams[2], INPUT aParams[3], OUTPUT cOutput).

        WHEN "CHOOSE" THEN
            RUN Choose(INPUT aParams[1], OUTPUT cOutput).

        WHEN "APPLY" THEN
            RUN Apply(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "CLEAR" THEN
            RUN Clear(INPUT aParams[1], OUTPUT cOutput).

        WHEN "SENDKEYS" THEN
            RUN SendKeys(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "SELECTROW" THEN
            RUN SelectRow(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "REPOSITIONTOROW" THEN
            RUN RepositionToRow(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "CHECK" THEN
            RUN Check(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "SELECT" THEN
            RUN Select(INPUT aParams[1], INPUT aParams[2], INPUT aParams[3], OUTPUT cOutput).

        WHEN "QUERY" THEN
            RUN Query(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "CREATE" THEN
            RUN Create(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "UPDATE" THEN
            RUN Update(INPUT aParams[1], INPUT aParams[2], INPUT aParams[3], OUTPUT cOutput).

        WHEN "DELETE" THEN
            RUN Delete(INPUT aParams[1], INPUT aParams[2], INPUT aParams[3], OUTPUT cOutput).

        WHEN "DELETEALL" THEN                                       
            RUN DeleteAll(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "RUN" THEN
            RUN Run(INPUT aParams[1], INPUT aParams[2], OUTPUT cOutput).

        WHEN "QUIT" THEN
            APPLY "CLOSE" TO THIS-PROCEDURE.

        OTHERWISE
            cOutput = "NOK|Command ~"" + cCommand + "~" not found!".
    END CASE.

    /* Set output to null if there's no wait for response */
    IF  NOT lWait THEN
        cOutput = ?.

    IF  cOutput <> ? THEN
        RUN DoLog IN hUtils (INPUT "SOCKET-IO", INPUT "Comand result: " + STRING(cOutput)).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Searches for an OE window with the informed title.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE FindWindow PRIVATE:
    DEFINE INPUT  PARAMETER cTitle  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hWindow AS HANDLE NO-UNDO.
    DEFINE VARIABLE hChild  AS HANDLE NO-UNDO.

    hWindow = SESSION:FIRST-CHILD.

    FINDWINDOW:
    DO  WHILE hWindow <> ?:
        IF  INDEX(hWindow:TITLE,cTitle) > 0 THEN
            LEAVE.

        hChild = hWindow:FIRST-CHILD.

        DO  WHILE hChild <> ?:
            IF  hChild:TYPE = "DIALOG-BOX" AND INDEX(hChild:TITLE,cTitle) > 0 THEN
            DO:
                hWindow = hChild.
                LEAVE FINDWINDOW.
            END.

            hChild = hChild:NEXT-SIBLING.
        END.

        hWindow = hWindow:NEXT-SIBLING.
    END.

    IF  hWindow <> ? THEN
        cOutput = "OK|" + STRING(hWindow:HANDLE).
    ELSE
        cOutput = "NOK|Window ~"" + cTitle + "~" not found!".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Searches for an OE widget with the informed name attribute.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE FindElement PRIVATE:
    DEFINE INPUT  PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible AS LOGICAL   NO-UNDO.
    DEFINE INPUT  PARAMETER cParent  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.
    DEFINE VARIABLE hParent  AS HANDLE NO-UNDO.

    IF  cParent = ? OR cParent = "" THEN
        RUN FindOEElement(INPUT ?, INPUT cName, INPUT lVisible, OUTPUT hElement).
    ELSE
    DO:
        RUN GetElementHandle(INPUT cParent, OUTPUT hParent, OUTPUT cOutput).

        IF  RETURN-VALUE = "NOK" THEN
            RETURN.

        RUN FindOEElement(INPUT hParent, INPUT cName, INPUT lVisible, OUTPUT hElement).
    END.

    IF  VALID-HANDLE(hElement) THEN
        cOutput = "OK|" + STRING(hElement:HANDLE).
    ELSE
        cOutput = "NOK|Element ~"" + cName + "~" not found!".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Search for an OE widget with the value of the informed attribute.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE FindElementByAttribute PRIVATE:
    DEFINE INPUT  PARAMETER cAttribute AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cValue     AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible   AS LOGICAL   NO-UNDO.
    DEFINE INPUT  PARAMETER cParent    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput    AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.
    DEFINE VARIABLE hParent  AS HANDLE NO-UNDO.

    IF  cParent <> ? AND cParent <> "" THEN
    DO:
        RUN GetElementHandle(INPUT cParent, OUTPUT hParent, OUTPUT cOutput).

        IF  RETURN-VALUE = "NOK" THEN
            RETURN.
    END.

    RUN FindOEElementByAttribute(INPUT hParent, INPUT cAttribute, INPUT cValue, INPUT lVisible, OUTPUT hElement).

    IF  VALID-HANDLE(hElement) THEN
        cOutput = "OK|" + STRING(hElement:HANDLE).
    ELSE
        cOutput = "NOK|Element with attribute ~"" + cAttribute + "~" and value ~"" + cValue + "~" not found!".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Clears the widget SCREEN-VALUE.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Clear PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    IF  hElement:DATA-TYPE = "CHARACTER" THEN
        hElement:SCREEN-VALUE = "".
    ELSE
        hElement:SCREEN-VALUE =  ?.

    cOutput = "OK".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Changes the widget SCREEN-VALUE.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE SendKeys PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cKeys    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE    NO-UNDO.
    DEFINE VARIABLE nKey     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cKey     AS CHARACTER NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    /* Can't fire SendKeys in an disabled WIDGET */
    IF  NOT hElement:SENSITIVE THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" is disabled!".
        RETURN.
    END.

    /* Force focus to the WIDGET so ENTRY and LEAVE events are fired */
    APPLY "ENTRY" TO hElement.

    IF  hElement:DATA-TYPE = "CHARACTER" AND (hElement:TYPE = "FILL-IN" OR hElement:TYPE = "EDITOR") THEN
    DO  nKey = 1 TO LENGTH(cKeys):
        cKey = SUBSTRING(cKeys,nKey,1).
        APPLY cKey TO hElement.
    END.
    ELSE
        hElement:SCREEN-VALUE = cKeys.

    cOutput = "OK".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Checks/Unchecks a TOGGLE-BOX widget.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Check PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lChecked AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    IF  hElement:TYPE <> "TOGGLE-BOX" THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" isn't a TOGGLE-BOX!".
        RETURN.
    END.

    IF  NOT hElement:SENSITIVE THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" is disabled!".
        RETURN.
    END.

    /* Force focus to the WIDGET so ENTRY and LEAVE events are fired */
    APPLY "ENTRY" TO hElement.
    
    hElement:CHECKED = lChecked NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        cOutput = "NOK|" + ERROR-STATUS:GET-MESSAGE(1).
    ELSE
        cOutput = "OK".

    APPLY "VALUE-CHANGED" TO hElement.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Selects a value in a COMBO-BOX or RADIO-SET widget.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Select PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cValue   AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lPartial AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE  NO-UNDO.
    DEFINE VARIABLE nItem    AS INTEGER NO-UNDO.
    DEFINE VARIABLE nItems   AS INTEGER NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    IF  hElement:TYPE <> "COMBO-BOX" AND hElement:TYPE <> "RADIO-SET" THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" isn't a COMBO-BOX nor a RADIO-SET!".
        RETURN.
    END.

    IF  NOT hElement:SENSITIVE THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" is disabled!".
        RETURN.
    END.
    
    /* Force focus to the WIDGET so ENTRY and LEAVE events are fired */
    APPLY "ENTRY" TO hElement.

    IF  lPartial THEN
    DO:
        nItems = NUM-ENTRIES(hElement:LIST-ITEMS).

        DO  nItem = 1 TO nItems:
            IF  ENTRY(nItem,hElement:LIST-ITEMS) MATCHES ("*" + cValue + "*") THEN
            DO:
                hElement:SCREEN-VALUE = ENTRY(nItem,hElement:LIST-ITEMS).
                cOutput = "OK".
                LEAVE.
            END.
        END.
    END.
    ELSE
    DO:
        hElement:SCREEN-VALUE = cValue.
        cOutput = "OK".
    END.

    IF  cOutput = ? OR cOutput = "" THEN
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" doesn't have an item with value ~"" + cValue + "~".".
    ELSE
        cOutput = "OK".

    APPLY "VALUE-CHANGED" TO hElement.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Selects a row in a BROWSE widget.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE SelectRow PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER nRow     AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    IF  hElement:TYPE <> "BROWSE" THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" isn't a BROWSE!".
        RETURN.
    END.

    /* Doesn't throw an error if the BROWSE doesn't have any row yet */
    hElement:SELECT-ROW(nRow) NO-ERROR.
    cOutput = "OK".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Moves a QUERY result pointer of a BROWSE widget to the specified row.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE RepositionToRow PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER nRow     AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    IF  hElement:TYPE <> "BROWSE" THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" isn't a BROWSE!".
        RETURN.
    END.

    hElement:QUERY:REPOSITION-TO-ROW(nRow) NO-ERROR.

    IF  NOT ERROR-STATUS:ERROR THEN
        cOutput = "OK".
    ELSE
        cOutput = "NOK|" + ERROR-STATUS:GET-MESSAGE(1).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Applies a CHOOSE event to the widget.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Choose PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO INITIAL ?.

    DEFINE VARIABLE hElement AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lWait    AS LOGICAL NO-UNDO INITIAL TRUE.

    IF  cElement <> ? AND cElement <> "" THEN
    DO:
        RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

        IF  RETURN-VALUE = "NOK" THEN
            RETURN.
    END.

    IF  NOT hElement:SENSITIVE THEN
    DO:
        cOutput = "NOK|Element ~"" + hElement:NAME + "~" is disabled!".
        RETURN.
    END.
    
    /* Force focus to the WIDGET */
    APPLY "ENTRY" TO hElement.

    RUN Apply(INPUT cElement, INPUT "CHOOSE", OUTPUT cOutput).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Applies an event to the widget.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Apply PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cEvent   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO INITIAL "OK".

    DEFINE VARIABLE hElement AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lWait    AS LOGICAL NO-UNDO INITIAL TRUE.

    IF  cElement <> ? AND cElement <> "" THEN
    DO:
        RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

        IF  RETURN-VALUE = "NOK" THEN
            RETURN.
    END.

    /**
     * For CHOOSE statements, the agent won't expect any response and will be
     * used a Mouse Click simulation using the "user32.dll".
     * That's because CHOOSE can open other application that will block the
     * execution.
     */
    IF  CAPS(cEvent) = "CHOOSE" THEN
    DO:
        lWait = FALSE.

        IF  hElement:TYPE <> "MENU-ITEM" THEN
            RUN MouseClick IN hUtils (INPUT hElement).
        ELSE
            APPLY "CHOOSE" TO hElement.
    END.
    ELSE
        APPLY cEvent TO hElement.

    cOutput = IF lWait THEN "OK" ELSE ?.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Gets the widget's informed attribute value.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Get PRIVATE:
    DEFINE INPUT  PARAMETER cElement   AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cAttribute AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput    AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE    NO-UNDO.
    DEFINE VARIABLE hCall    AS HANDLE    NO-UNDO.
    DEFINE VARIABLE cValue   AS CHARACTER NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    CREATE CALL hCall.
    hCall:IN-HANDLE = hElement.
    hCall:CALL-TYPE = GET-ATTR-CALL-TYPE.
    hCall:CALL-NAME = cAttribute.
    hCall:INVOKE NO-ERROR.

    cValue = STRING(hCall:RETURN-VALUE).

    IF  ERROR-STATUS:ERROR THEN
        cOutput = "NOK|" + ERROR-STATUS:GET-MESSAGE(1).
    ELSE
        cOutput = "OK|" + cValue.

    hCall:CLEAR.
    DELETE OBJECT hCall NO-ERROR.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Sets the widget's informed attribute value.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Set PRIVATE:
    DEFINE INPUT  PARAMETER cElement   AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cAttribute AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cValue     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput    AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hElement AS HANDLE NO-UNDO.
    DEFINE VARIABLE hCall    AS HANDLE NO-UNDO.

    RUN GetElementHandle(INPUT cElement, OUTPUT hElement, OUTPUT cOutput).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN.

    CREATE CALL hCall.
    hCall:IN-HANDLE = hElement.
    hCall:CALL-TYPE = SET-ATTR-CALL-TYPE.
    hCall:CALL-NAME = cAttribute.
    hCall:NUM-PARAMETERS = 1.
    hCall:SET-PARAMETER(1,"CHARACTER","INPUT",cValue).
    hCall:INVOKE NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        cOutput = "NOK|" + ERROR-STATUS:GET-MESSAGE(1).
    ELSE
        cOutput = "OK".

    hCall:CLEAR.
    DELETE OBJECT hCall NO-ERROR.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Selects one or more records of the informed table.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Query PRIVATE:
    DEFINE INPUT  PARAMETER cTable  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cWhere  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hBuffer AS HANDLE   NO-UNDO.
    DEFINE VARIABLE hQuery  AS HANDLE   NO-UNDO.
    DEFINE VARIABLE ttQuery AS HANDLE   NO-UNDO.
    DEFINE VARIABLE hTTable AS HANDLE   NO-UNDO.

    DEFINE VARIABLE nCount  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE nTotal  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE cJson   AS LONGCHAR NO-UNDO.

    CREATE BUFFER hBuffer FOR TABLE cTable.
    CREATE QUERY hQuery.
    hQuery:SET-BUFFERS(hBuffer).
    hQuery:QUERY-PREPARE("FOR EACH " + cTable + " WHERE " + cWhere + " NO-LOCK").
    hQuery:QUERY-OPEN().

    CREATE TEMP-TABLE ttQuery.
    ttQuery:ADD-FIELDS-FROM(hBuffer).
    ttQuery:TEMP-TABLE-PREPARE(cTable).
    hTTable = ttQuery:DEFAULT-BUFFER-HANDLE.

    DO  WHILE TRUE:
        hQuery:GET-NEXT().

        IF  hQuery:QUERY-OFF-END THEN
            LEAVE.

        hTTable:BUFFER-CREATE().
        hTTable:BUFFER-COPY(hBuffer).
        hTTable:BUFFER-RELEASE().
    END.

    hQuery:QUERY-CLOSE().
    ttQuery:WRITE-JSON("LONGCHAR", cJson, FALSE).

    cOutput = "OK|" + cJson.

    CATCH oError AS Progress.Lang.Error:
        cOutput = "NOK|" + oError:GetMessage(1).
    END CATCH.

    FINALLY:
        DELETE OBJECT hBuffer NO-ERROR.
        DELETE OBJECT hQuery  NO-ERROR.
        DELETE OBJECT ttQuery NO-ERROR.
        DELETE OBJECT hTTable NO-ERROR.
    END FINALLY.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Creates one or more records in the informed table.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Create PRIVATE:
    DEFINE INPUT  PARAMETER cTable  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cData   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO.

    DEFINE VARIABLE oData   AS JsonObject NO-UNDO.
    DEFINE VARIABLE oTable  AS JsonArray  NO-UNDO.

    DEFINE VARIABLE nData   AS INTEGER    NO-UNDO.
    DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lStatus AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE cError  AS CHARACTER  NO-UNDO.

    /* Convert the data to JsonObject */
    RUN ParseChar2JsonObject IN hUtils (INPUT cData, OUTPUT oData).

    /* Get the records from the informed table */
    oTable = oData:GetJsonArray(cTable).

    /* Creates table BUFFER for creating the informed data */
    CREATE BUFFER hBuffer FOR TABLE cTable.

    /* Clears ERROR-STATUS */
    RUN ClearErrorStatus.

    CREATERECORDS:
    DO  TRANSACTION:
        DO  nData = 1 TO oTable:Length:
            RUN DoLog IN hUtils (INPUT "CREATE", INPUT "Creating record at ~"" + cTable + "~"").
            lStatus = hBuffer:BUFFER-CREATE() NO-ERROR.

            IF  NOT lStatus THEN
            DO:
                cError = ERROR-STATUS:GET-MESSAGE(1).
                UNDO CREATERECORDS, LEAVE CREATERECORDS.
            END.

            RUN AssignStatementFields(INPUT hBuffer, INPUT oTable:GetJsonObject(nData), OUTPUT lStatus).

            IF  NOT lStatus THEN
            DO:
                cError = ERROR-STATUS:GET-MESSAGE(1).
                UNDO CREATERECORDS, LEAVE CREATERECORDS.
            END.

            lStatus = hBuffer:BUFFER-RELEASE() NO-ERROR.

            IF  NOT lStatus THEN
            DO:
                cError = ERROR-STATUS:GET-MESSAGE(1).
                UNDO CREATERECORDS, LEAVE CREATERECORDS.
            END.
        END.
    END.

    IF  lStatus THEN
        cOutput = "OK".
    ELSE
        cOutput = "NOK|" + cError.

    FINALLY:
        DELETE OBJECT hBuffer NO-ERROR.
        DELETE OBJECT oTable  NO-ERROR.
        DELETE OBJECT oData   NO-ERROR.
    END FINALLY.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Updates one or more records of the informed table.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Update PRIVATE:
    DEFINE INPUT  PARAMETER cTable  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cData   AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cIndex  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO.

    DEFINE VARIABLE oData   AS JsonObject NO-UNDO.
    DEFINE VARIABLE oIndex  AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oTable  AS JsonArray  NO-UNDO.

    DEFINE VARIABLE nData   AS INTEGER    NO-UNDO.
    DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
    DEFINE VARIABLE cWhere  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lStatus AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE cError  AS CHARACTER  NO-UNDO.

    /* Convert the data to JsonObject */
    RUN ParseChar2JsonObject IN hUtils (INPUT cData, OUTPUT oData).

    /* Convert the index columns to JsonArray */
    RUN ParseChar2JsonArray IN hUtils (INPUT cIndex, OUTPUT oIndex).

    /* Get the records from the informed table */
    oTable = oData:GetJsonArray(cTable).

    /* Creates table BUFFER for creating the informed data */
    CREATE BUFFER hBuffer FOR TABLE cTable.

    /* Clears ERROR-STATUS */
    RUN ClearErrorStatus.

    UPDATERECORDS:
    DO  TRANSACTION:
        DO  nData = 1 TO oTable:Length:
            /* Generate a WHERE clause for the DELETE command */
            RUN GetStatementWhereClause(INPUT hBuffer, INPUT oTable:GetJsonObject(nData), INPUT oIndex, OUTPUT cWhere).

            lStatus = hBuffer:FIND-FIRST(cWhere, EXCLUSIVE-LOCK) NO-ERROR.

            IF  NOT lStatus THEN
            DO:
                cError = ERROR-STATUS:GET-MESSAGE(1).
                UNDO UPDATERECORDS, LEAVE UPDATERECORDS.
            END.

            IF  hBuffer:AVAILABLE THEN
            DO:
                RUN AssignStatementFields(INPUT hBuffer, INPUT oTable:GetJsonObject(nData), OUTPUT lStatus).

                IF  NOT lStatus THEN
                DO:
                    cError = ERROR-STATUS:GET-MESSAGE(1).
                    UNDO UPDATERECORDS, LEAVE UPDATERECORDS.
                END.
            END.
            ELSE
            DO:
                lStatus = FALSE.
                cError = "Record (" + STRING(nData) + ") not available!".
                UNDO UPDATERECORDS, LEAVE UPDATERECORDS.
            END.

            lStatus = hBuffer:BUFFER-RELEASE() NO-ERROR.

            IF  NOT lStatus THEN
            DO:
                cError = ERROR-STATUS:GET-MESSAGE(1).
                UNDO UPDATERECORDS, LEAVE UPDATERECORDS.
            END.
        END.
    END.

    IF  lStatus THEN
        cOutput = "OK".
    ELSE
        cOutput = "NOK|" + cError.

    FINALLY:
        DELETE OBJECT hBuffer NO-ERROR.
        DELETE OBJECT oTable  NO-ERROR.
        DELETE OBJECT oIndex  NO-ERROR.
        DELETE OBJECT oData   NO-ERROR.
    END FINALLY.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Deletes one or more records of the informed table.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Delete PRIVATE:
    DEFINE INPUT  PARAMETER cTable  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cData   AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cIndex  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO.

    DEFINE VARIABLE oData   AS JsonObject NO-UNDO.
    DEFINE VARIABLE oIndex  AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oTable  AS JsonArray  NO-UNDO.

    DEFINE VARIABLE nData   AS INTEGER    NO-UNDO.
    DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
    DEFINE VARIABLE cWhere  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lStatus AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE cError  AS CHARACTER  NO-UNDO.

    /* Convert the data to JsonObject */
    RUN ParseChar2JsonObject IN hUtils (INPUT cData, OUTPUT oData).

    /* Convert the index columns to JsonArray */
    RUN ParseChar2JsonArray IN hUtils (INPUT cIndex, OUTPUT oIndex).

    /* Get the records from the informed table */
    oTable = oData:GetJsonArray(cTable).

    /* Creates table BUFFER for creating the informed data */
    CREATE BUFFER hBuffer FOR TABLE cTable.

    /* Clears ERROR-STATUS */
    RUN ClearErrorStatus.

    DELETERECORDS:
    DO  TRANSACTION:
        DO  nData = 1 TO oTable:Length:                                                                                                                      
            /* Generate a WHERE clause for the DELETE command */
            RUN GetStatementWhereClause(INPUT hBuffer, INPUT oTable:GetJsonObject(nData), INPUT oIndex, OUTPUT cWhere).

            hBuffer:FIND-FIRST(cWhere, EXCLUSIVE-LOCK, NO-WAIT) NO-ERROR.

            /* If the record was already deleted, don't throw an error */
            IF  hBuffer:AVAILABLE THEN
            DO:
                RUN DoLog IN hUtils (INPUT "DELETE", INPUT "Deleting record at ~"" + cTable + "~" using WHERE clause ~"" + cWhere + "~"").
                lStatus = hBuffer:BUFFER-DELETE() NO-ERROR.

                IF  NOT lStatus THEN
                DO:
                    cError = ERROR-STATUS:GET-MESSAGE(1).
                    UNDO DELETERECORDS, LEAVE DELETERECORDS.
                END.
            END.

            lStatus = hBuffer:BUFFER-RELEASE() NO-ERROR.

            IF  NOT lStatus THEN
            DO:
                cError = ERROR-STATUS:GET-MESSAGE(1).
                UNDO DELETERECORDS, LEAVE DELETERECORDS.
            END.
        END.
    END.

    IF  lStatus THEN
        cOutput = "OK".
    ELSE
        cOutput = "NOK|" + cError.

    FINALLY:
        DELETE OBJECT hBuffer NO-ERROR.
        DELETE OBJECT oTable  NO-ERROR.
        DELETE OBJECT oIndex  NO-ERROR.
        DELETE OBJECT oData   NO-ERROR.
    END FINALLY.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Deletes all the records of the informed table.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE DeleteAll PRIVATE:
    DEFINE INPUT  PARAMETER cTable  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cWhere  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hBuffer AS HANDLE   NO-UNDO.
    DEFINE VARIABLE hQuery  AS HANDLE   NO-UNDO.
    DEFINE VARIABLE lStatus AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE cError  AS CHARACTER  NO-UNDO.
        
    CREATE BUFFER hBuffer FOR TABLE cTable.
    
    CREATE QUERY hQuery.
    hQuery:SET-BUFFERS(hBuffer).

    IF cWhere = "" THEN DO:
        hQuery:QUERY-PREPARE("FOR EACH " + cTable + " NO-LOCK").
    END.    
    ELSE DO:
        hQuery:QUERY-PREPARE("FOR EACH " + cTable + " WHERE " + cWhere + " NO-LOCK").
    END.
    
    hQuery:QUERY-OPEN().
    
    /* Clears ERROR-STATUS */
    RUN ClearErrorStatus.

    DELETEALLRECORDS:
    DO  TRANSACTION:                                                                                                                    

        hQuery:GET-FIRST(EXCLUSIVE-LOCK, NO-WAIT).

        REPEAT WHILE NOT hQuery:QUERY-OFF-END:                          

            IF  hBuffer:AVAILABLE THEN
            DO:
                RUN DoLog IN hUtils (INPUT "DELETEALL", INPUT "Deleting all the records at ~"" + cTable + "~" using WHERE clause ~"" + cWhere + "~"").
                lStatus = hBuffer:BUFFER-DELETE() NO-ERROR.

                IF  NOT lStatus THEN
                DO:
                    cError = ERROR-STATUS:GET-MESSAGE(1).
                    UNDO DELETEALLRECORDS, LEAVE DELETEALLRECORDS.
                END.

                hQuery:GET-NEXT(EXCLUSIVE-LOCK, NO-WAIT).
            END.
        END.

        lStatus = hBuffer:BUFFER-RELEASE() NO-ERROR.

        IF  NOT lStatus THEN
        DO:
            cError = ERROR-STATUS:GET-MESSAGE(1).
            UNDO DELETEALLRECORDS, LEAVE DELETEALLRECORDS.
        END.
    END.

    IF  lStatus THEN
        cOutput = "OK".
    ELSE
        cOutput = "NOK|" + cError.

    FINALLY:
        DELETE OBJECT hQuery NO-ERROR.
        DELETE OBJECT hBuffer NO-ERROR.
    END FINALLY.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Runs a PROCEDURE command or open an OE application.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE Run PRIVATE:
    DEFINE INPUT  PARAMETER cRun    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cParams AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput AS CHARACTER NO-UNDO INITIAL ?.

    /* Connect Runner SOCKET client */
    IF  SEARCH(cRun) = ? THEN
        cOutput = "NOK|OE application ~"" + cRun + "~" not found!".
    ELSE
        RUN RunApplication IN hUtils (INPUT cRun, INPUT cParams).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Return the handle of the informed element.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE GetElementHandle PRIVATE:
    DEFINE INPUT  PARAMETER cElement AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement AS HANDLE    NO-UNDO.
    DEFINE OUTPUT PARAMETER cOutput  AS CHARACTER NO-UNDO.

    hElement = HANDLE(cElement) NO-ERROR.

    IF  NOT VALID-HANDLE(hElement) THEN
    DO:
        cOutput = "NOK|Element ~"" + cElement + "~" not found!.".
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Utility to clear ERROR-STATUS.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE ClearErrorStatus PRIVATE:
    "1"="1" NO-ERROR.
END PROCEDURE.

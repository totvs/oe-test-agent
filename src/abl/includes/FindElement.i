
/*------------------------------------------------------------------------
    File        : FindElement.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Rubens Dos Santos Filho
    Created     : Sat Nov 03 12:23:03 BRST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


/* **********************  Internal Procedures  *********************** */

/*------------------------------------------------------------------------------
 Purpose: Find an WIDGET element with the informed NAME attribute.
 Notes: The search will consider all opened OE applications.
------------------------------------------------------------------------------*/
PROCEDURE FindOEElement PRIVATE:
    DEFINE INPUT  PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement AS HANDLE    NO-UNDO.

    DEFINE VARIABLE hWindow AS HANDLE NO-UNDO.

    hWindow = SESSION:FIRST-CHILD.

    DO  WHILE VALID-HANDLE(hWindow):
        RUN FindOEChildElement(INPUT hWindow, INPUT cName, INPUT lVisible, OUTPUT hElement).
        
        IF  VALID-HANDLE(hElement) <> ? THEN
            LEAVE.
        
        hWindow = hWindow:NEXT-SIBLING.
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Find an WIDGET component with the informed NAME attribute.
 Notes: The search will consider only components inside the informed parent.
------------------------------------------------------------------------------*/
PROCEDURE FindOEChildElement PRIVATE:
    DEFINE INPUT  PARAMETER hParent  AS HANDLE    NO-UNDO.
    DEFINE INPUT  PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement AS HANDLE    NO-UNDO.

    DEFINE VARIABLE hChild AS HANDLE NO-UNDO.

    IF  hParent:NAME = cName AND ((lVisible AND hParent:VISIBLE) OR NOT lVisible) THEN
        hElement = hParent.
    ELSE 
    DO:
        IF  LOOKUP(hParent:TYPE, "WINDOW,FRAME,FIELD-GROUP,DIALOG-BOX") > 0 THEN
        DO:
            hChild = hParent:FIRST-CHILD.

            DO  WHILE VALID-HANDLE(hChild):
                RUN FindOEChildElement(INPUT hChild, INPUT cName, INPUT lVisible, OUTPUT hElement).
                
                IF  VALID-HANDLE(hElement) THEN
                    LEAVE.

                hChild = hChild:NEXT-SIBLING.
            END.
        END.
        ELSE
        DO:
            IF  LOOKUP(hParent:TYPE, "BROWSE") > 0 THEN
            DO:
                hElement = hParent:FIRST-COLUMN.

                DO  WHILE VALID-HANDLE(hElement):
                    IF  hElement:NAME = cName THEN
                        LEAVE.
                    
                    hElement = hElement:NEXT-COLUMN.
                END.
            END.
        END.
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Find an WIDGET element with the informed attribute value.
 Notes: The search will consider all opened OE applications.
------------------------------------------------------------------------------*/
PROCEDURE FindOEElementByAttribute PRIVATE:
    DEFINE INPUT  PARAMETER hParent    AS HANDLE    NO-UNDO.
    DEFINE INPUT  PARAMETER cAttribute AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER cValue     AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible   AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement   AS HANDLE    NO-UNDO.

    DEFINE VARIABLE hChild  AS HANDLE    NO-UNDO.
    DEFINE VARIABLE hCall   AS HANDLE    NO-UNDO.
    DEFINE VARIABLE cAttVal AS CHARACTER NO-UNDO.

    IF  NOT VALID-HANDLE(hParent) THEN
        hChild = SESSION:FIRST-CHILD.
    ELSE
        hChild = hParent:FIRST-CHILD.

    DO  WHILE VALID-HANDLE(hChild):
        CREATE CALL hCall.
        
        hCall:IN-HANDLE = hChild.
        hCall:CALL-TYPE = GET-ATTR-CALL-TYPE.
        hCall:CALL-NAME = cAttribute.
        hCall:INVOKE() NO-ERROR.
        
        cAttVal = hCall:RETURN-VALUE.
        
        hCall:CLEAR().
        DELETE OBJECT hCall NO-ERROR.
        
        IF  cAttVal <> ? AND TRIM(cAttVal) = TRIM(cValue) AND ((lVisible AND hChild:VISIBLE) OR NOT lVisible) THEN
        DO:
            hElement = hChild.
            LEAVE.
        END.
        ELSE
        DO:
            IF  CAN-QUERY(hChild,"FIRST-CHILD") THEN
            DO:
                RUN FindOEElementByAttribute(INPUT hChild, INPUT cAttribute, INPUT cValue, INPUT lVisible, OUTPUT hElement).
    
                IF  VALID-HANDLE(hElement) THEN
                    LEAVE.
            END.
        END.

        hChild = hChild:NEXT-SIBLING.
    END.
END PROCEDURE.


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
    DEFINE INPUT  PARAMETER hParent  AS HANDLE    NO-UNDO.
    DEFINE INPUT  PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement AS HANDLE    NO-UNDO.

    DEFINE VARIABLE hChild AS HANDLE NO-UNDO.

    IF  hParent = ? THEN
        hParent = SESSION:FIRST-CHILD.
    
    RUN FindOEChildElement(INPUT hParent, INPUT cName, INPUT lVisible, OUTPUT hElement).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Find an WIDGET element with the informed NAME attribute.
 Notes: The search will consider all opened OE applications.
------------------------------------------------------------------------------*/
PROCEDURE FindOEMenuElement PRIVATE:
    DEFINE INPUT  PARAMETER hParent  AS HANDLE    NO-UNDO.
    DEFINE INPUT  PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement AS HANDLE    NO-UNDO.

    IF  CAN-QUERY(hParent,"MENU-BAR") AND hParent:MENU-BAR <> ? THEN
        RUN FindOEChildElement(INPUT hParent:MENU-BAR, INPUT cName, INPUT FALSE, OUTPUT hElement).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Find an WIDGET element with the informed NAME attribute.
 Notes: The search will consider all opened OE applications.
------------------------------------------------------------------------------*/
PROCEDURE FindOEChildElement PRIVATE:
    DEFINE INPUT  PARAMETER hChild   AS HANDLE    NO-UNDO.
    DEFINE INPUT  PARAMETER cName    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER lVisible AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER hElement AS HANDLE    NO-UNDO.

    DEFINE VARIABLE hColumn AS HANDLE NO-UNDO.
    
    FindElementLoop:
    DO  WHILE VALID-HANDLE(hChild):
        IF  hChild:NAME = cName AND ((lVisible AND hChild:VISIBLE) OR NOT lVisible) THEN
        DO:
            hElement = hChild.
            LEAVE FindElementLoop.
        END.
        ELSE
        DO:
            RUN FindOEMenuElement(INPUT hChild, INPUT cName, OUTPUT hElement).
        
            IF  VALID-HANDLE(hElement) THEN
                LEAVE FindElementLoop.
            ELSE
            DO:
                IF  hChild:TYPE = "BROWSE" THEN
                DO:
                    hColumn = hChild:FIRST-COLUMN.

                    DO  WHILE VALID-HANDLE(hColumn):
                        IF  hColumn:NAME = cName THEN
                        DO:
                            hElement = hColumn.
                            LEAVE FindElementLoop.
                        END.
                        
                        hColumn = hColumn:NEXT-COLUMN.
                    END.
                END.
                ELSE
                IF  CAN-QUERY(hChild,"FIRST-CHILD") THEN
                DO:
                    RUN FindOEChildElement(INPUT hChild:FIRST-CHILD, INPUT cName, INPUT lVisible, OUTPUT hElement).
        
                    IF  VALID-HANDLE(hElement) THEN
                        LEAVE FindElementLoop.
                END.
            END.
        END.
        
        IF  CAN-QUERY(hChild,"NEXT-SIBLING") THEN
            hChild = hChild:NEXT-SIBLING.
        ELSE
            LEAVE FindElementLoop.
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

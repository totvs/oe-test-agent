
/*------------------------------------------------------------------------
    File        : Statement.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Rubens Dos Santos Filho
    Created     : Mon Nov 05 16:17:06 BRST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* **********************  Internal Procedures  *********************** */

/*------------------------------------------------------------------------------
 Purpose: 
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE AssignStatementFields PRIVATE:
    DEFINE INPUT  PARAMETER hBuffer AS HANDLE     NO-UNDO.
    DEFINE INPUT  PARAMETER oRecord AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER lStatus AS LOGICAL    NO-UNDO. 

    DEFINE VARIABLE hField  AS HANDLE    NO-UNDO.
    DEFINE VARIABLE cFields AS CHARACTER NO-UNDO EXTENT.
    DEFINE VARIABLE nField  AS INTEGER   NO-UNDO.

    cFields = oRecord:GetNames().
    lStatus = TRUE.

    DO  nField = 1 TO EXTENT(cFields):
        hField = hBuffer:BUFFER-FIELD(cFields[nField]).

        CASE hField:DATA-TYPE:
            WHEN "LOGICAL" THEN
                hField:BUFFER-VALUE = oRecord:GetLogical(cFields[nField]) NO-ERROR.
            WHEN "INTEGER" THEN
                hField:BUFFER-VALUE = oRecord:GetInteger(cFields[nField]) NO-ERROR.
            WHEN "CHARACTER" THEN
                hField:BUFFER-VALUE = oRecord:GetCharacter(cFields[nField]) NO-ERROR.
        END CASE.
        
        IF  ERROR-STATUS:ERROR THEN
        DO:
            lStatus = FALSE.
            LEAVE.
        END.
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: 
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE GetStatementWhereClause PRIVATE:
    DEFINE INPUT  PARAMETER hBuffer AS HANDLE     NO-UNDO.
    DEFINE INPUT  PARAMETER oRecord AS JsonObject NO-UNDO.
    DEFINE INPUT  PARAMETER oIndex  AS JsonArray  NO-UNDO.
    DEFINE OUTPUT PARAMETER cWhere  AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE hField AS HANDLE    NO-UNDO.
    DEFINE VARIABLE cField AS CHARACTER NO-UNDO.
    DEFINE VARIABLE nCount AS INTEGER   NO-UNDO.

    DO  nCount = 1 TO oIndex:Length:
        ASSIGN
            cField = oIndex:GetCharacter(nCount)
            hField = hBuffer:BUFFER-FIELD(cField)
            cWhere = cWhere + " AND " + cField + " = ".

        CASE hField:DATA-TYPE:
            WHEN "LOGICAL"   THEN
                cWhere = cWhere + STRING(oRecord:GetLogical(cField)).
            WHEN "INTEGER"   THEN
                cWhere = cWhere + STRING(oRecord:GetInteger(cField)).
            WHEN "CHARACTER" THEN
                cWhere = cWhere + QUOTER(oRecord:GetCharacter(cField)).
        END CASE.
    END.

    cWhere = "WHERE 1=1 " + TRIM(cWhere).
END PROCEDURE.

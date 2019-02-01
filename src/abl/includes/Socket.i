/*------------------------------------------------------------------------
    File        : Socket.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Rubens Dos Santos Filho
    Created     : Thu Nov 01 16:05:26 BRST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE hSrvSkt AS HANDLE NO-UNDO.
DEFINE VARIABLE mData   AS MEMPTR NO-UNDO.

/* **********************  Internal Procedures  *********************** */

/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE EnableSocket:
    DEFINE VARIABLE lStatus AS LOGICAL NO-UNDO.
    
    CREATE SERVER-SOCKET hSrvSkt.
    
    lStatus = hSrvSkt:ENABLE-CONNECTIONS("-H " + {1} + " -S " + STRING({2})).
    IF  NOT lStatus THEN QUIT.

    lStatus = hSrvSkt:SET-CONNECT-PROCEDURE("SocketConnect").
    IF  NOT lStatus THEN QUIT.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE CloseSocket:
    SET-SIZE(mData) = 0.
    
    hSrvSkt:DISABLE-CONNECTIONS().
    DELETE OBJECT hSrvSkt NO-ERROR.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE SocketConnect:
    DEFINE INPUT PARAMETER hSocket AS HANDLE NO-UNDO.
    DEFINE VARIABLE lStatus AS LOGICAL NO-UNDO.
    
    lStatus = hSocket:SET-READ-RESPONSE-PROCEDURE("SocketIO").
    IF NOT lStatus THEN QUIT.
    
    RUN VALUE("{4}").
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE SocketIO:
    DEFINE VARIABLE nSize   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lStatus AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE cData   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cOutput AS CHARACTER NO-UNDO.
    
    IF  SELF:CONNECTED() THEN
    DO:
        nSize = SELF:GET-BYTES-AVAILABLE().
        
        SET-SIZE(mData) = 0.
        SET-SIZE(mData) = nSize.
        
        lStatus = SELF:READ(mData,1,nSize,2) NO-ERROR.
        
        IF  NOT lStatus OR ERROR-STATUS:GET-MESSAGE(1) <> '' THEN
            cOutput = "NOK|" + ERROR-STATUS:GET-MESSAGE(1).
        ELSE
        DO:
            ASSIGN 
                cData = GET-STRING(mData,1)
                cData = TRIM(cData)
                cData = REPLACE(cData,CHR(01),"")
                cData = REPLACE(cData,CHR(10),"")
                cData = REPLACE(cData,CHR(13),"")
                cData = CODEPAGE-CONVERT(cData, {3}, "UTF-8").
            
            RUN VALUE("{5}") (INPUT cData, OUTPUT cOutput).
        END.
        
        /* Only send a response if the output is not empty */
        IF  cOutput <> ? THEN
        DO:
            cOutput = CODEPAGE-CONVERT(cOutput, "UTF-8", {3}).
            nSize = LENGTH(cOutput).
            
            SET-SIZE(mData) = 0.
            SET-SIZE(mData) = nSize.
            PUT-STRING(mData,1,nSize) = cOutput.
            
            lStatus = SELF:WRITE(mData,1,nSize) NO-ERROR.
        END.
        
        SET-SIZE(mData) = 0.
    END.
END PROCEDURE.

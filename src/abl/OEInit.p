/*------------------------------------------------------------------------
    File        : OEInit.p
    Purpose     : OE Test Agent application initialization

    Syntax      :

    Description : Initialize the OE Test Agent application

    Author(s)   : Rubens Dos Santos Filho
    Created     : Fri Nov 02 11:03:33 BRST 2018
    Notes       : This source is necessary to change the session's
                  PROPATH that will be used by the OE runner application.
  ----------------------------------------------------------------------*/

USING com.oetestagent.OEConfig FROM PROPATH.

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER oConfig AS OEConfig NO-UNDO.
DEFINE VARIABLE hUtils AS HANDLE NO-UNDO.

/* ***************************  Main Block  *************************** */
RUN OEUtils.p PERSISTENT SET hUtils.

RUN EnableCoverage(INPUT oConfig:GetOutDir()).
RUN SetPropath(INPUT oConfig:GetPropath()).
RUN RunStartup(INPUT oConfig:GetStartup(), INPUT oConfig:GetStartupParams()).

/* Execute Runner application */
RUN OEAgent.p (INPUT oConfig:GetHost(), INPUT oConfig:GetPort(), INPUT oConfig:GetInputCodepage()).

/* **********************  Internal Procedures  *********************** */

/*------------------------------------------------------------------------------
 Purpose: Enable Coverage output for this ABL session.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE EnableCoverage PRIVATE:
    DEFINE INPUT PARAMETER cOutDir AS CHARACTER NO-UNDO.
    DEFINE VARIABLE nPid AS INTEGER NO-UNDO.
    
    RUN GetCurrentProcessId(OUTPUT nPid).

    SESSION:DEBUG-ALERT = YES.
    PROFILER:ENABLED = YES.
    PROFILER:FILE-NAME = cOutDir + "/cov" + STRING(nPid) + ".out".
    PROFILER:COVERAGE = YES.
    PROFILER:PROFILING = YES.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Set session's PROPATH with the informed PROPATH.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE SetPropath PRIVATE:
    DEFINE INPUT PARAMETER cPropath AS CHARACTER NO-UNDO.
    
    IF  cPropath <> ? AND cPropath <> "" THEN
        PROPATH = PROPATH + "," + cPropath.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Run the defined startup program.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE RunStartup PRIVATE:
    DEFINE INPUT PARAMETER cStartup    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cParameters AS CHARACTER NO-UNDO.

    IF  cStartup <> ? AND SEARCH(cStartup) <> ? THEN
        RUN RunApplication IN hUtils (INPUT cStartup, INPUT cParameters).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Return the PID number of this application.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll":
    DEFINE RETURN PARAMETER nProcessId AS LONG NO-UNDO.
END PROCEDURE.

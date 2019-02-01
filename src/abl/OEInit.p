/*------------------------------------------------------------------------
    File        : OEInit.p
    Purpose     : Initialize the "OE Test Agent" application.

    Syntax      :

    Description : "OE Test Agent" Initializer

    Author(s)   : Rubens Dos Santos Filho
    Created     : Fri Nov 02 11:03:33 BRST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING com.oetestagent.OEConfig FROM PROPATH.

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER cConfig AS CHARACTER NO-UNDO.

DEFINE VARIABLE oConfig AS OEConfig NO-UNDO. 
DEFINE VARIABLE hUtils  AS HANDLE   NO-UNDO.

/* ***************************  Main Block  *************************** */

RUN OEUtils.p PERSISTENT SET hUtils.

/* Load configuration */
RUN OEConfig.p (INPUT cConfig, OUTPUT oConfig).

RUN EnableCoverage(INPUT oConfig:GetOutDir()).
RUN SetPropath(INPUT oConfig:GetPropath()).
RUN RunStartup(INPUT oConfig:GetStartup(), INPUT oConfig:GetStartupParams()).

/* Execute main application */
RUN OEAgent.p (INPUT oConfig:GetHost(), INPUT oConfig:GetPort(), INPUT oConfig:GetInputCodepage()).

/* **********************  Internal Procedures  *********************** */

/*------------------------------------------------------------------------------
 Purpose: Enable coverage output for this ABL session.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE EnableCoverage PRIVATE:
    DEFINE INPUT PARAMETER cOutDir AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE cFile  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dToday AS DATE      NO-UNDO.
    
    PROFILER:ENABLED   = YES.
    PROFILER:COVERAGE  = YES.
    PROFILER:PROFILING = YES.
    
    IF  NOT PROFILER:ENABLED
    OR  PROFILER:FILE-NAME = ?
    OR  PROFILER:FILE-NAME = "" THEN
    DO:
        ASSIGN
            dToday = TODAY
            cFile  = cOutDir + "/cov-"
            cFile  = cFile + STRING(YEAR(dToday),"9999") + "-"
            cFile  = cFile + STRING(MONTH(dToday),"99") + "-"
            cFile  = cFile + STRING(DAY(dToday),"99") + "-"
            cFile  = cFile + REPLACE(STRING(TIME, "HH:MM:SS"),":","-") + ".out".
        PROFILER:FILE-NAME = cFile.
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Set session's PROPATH with the informed PROPATH.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE SetPropath PRIVATE:
    DEFINE INPUT PARAMETER cPropath AS CHARACTER NO-UNDO.
    
    IF  cPropath <> ? AND cPropath <> "" THEN
    DO:
        PROPATH = PROPATH + "," + cPropath.
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Run the defined startup program.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE RunStartup PRIVATE:
    DEFINE INPUT PARAMETER cRun   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cParam AS CHARACTER NO-UNDO.

    IF  cRun <> ? AND SEARCH(cRun) <> ? THEN
    DO:
        RUN RunApplication IN hUtils (INPUT cRun, INPUT cParam).
    END.
END PROCEDURE.

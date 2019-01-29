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
    
    DEFINE VARIABLE cFile  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dToday AS DATE      NO-UNDO.
    
    IF  NOT PROFILER:ENABLED OR PROFILER:FILE-NAME = ? OR PROFILER:FILE-NAME = "" THEN
    DO:
        dToday = TODAY.
        cFile = cOutDir + "/cov-".
        cFile = cFile + STRING(YEAR(dToday),"9999") + "-".
        cFile = cFile + STRING(MONTH(dToday),"99") + "-".
        cFile = cFile + STRING(DAY(dToday),"99") + "-".
        cFile = cFile + REPLACE(STRING(TIME, "HH:MM:SS"),":","-") + ".out".
        
        PROFILER:ENABLED = YES.
        PROFILER:FILE-NAME = cFile.
    END.
    
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


/*------------------------------------------------------------------------
    File        : OEStart.p
    Purpose     : Start the OE Test Agent application

    Syntax      :

    Description : OE Test Agent start

    Author(s)   : Rubens Dos Santos Filho
    Created     : Fri Nov 02 11:03:33 BRST 2018
    Notes       : This source is necessary to change the session's
                  PROPATH that will be used by the OE Test Agent.
  ----------------------------------------------------------------------*/

USING com.oetestagent.OEConfig FROM PROPATH.

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE oConfig AS OEConfig NO-UNDO.
DEFINE VARIABLE hUtils  AS HANDLE   NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
RUN OEUtils.p PERSISTENT SET hUtils.

/* Change the session's PROPATH with the current directory */
FILE-INFO:FILE-NAME = ".".
PROPATH = FILE-INFO:FULL-PATHNAME + "," + PROPATH.

RUN LoadConfig.
RUN OEInit.p (INPUT oConfig).

/*------------------------------------------------------------------------------
 Purpose: Load all configuration passed as session parameters.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE LoadConfig PRIVATE:
    DEFINE VARIABLE nCount   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cPropath AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cParam   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cParams  AS CHARACTER NO-UNDO.
    
    oConfig = NEW OEConfig().
    
    RUN DoLog IN hUtils (INPUT "START", INPUT "Loading OE agent configuration from OE SESSION:PARAMETER").
    RUN DoLog IN hUtils (INPUT "START", INPUT "SESSION:PARAMETER value: " + SESSION:PARAMETER).
    
    /**
     * Parameter 1: Host
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 1 THEN
    DO:
        oConfig:SetHost(ENTRY(1,SESSION:PARAMETER)).
        RUN DoLog IN hUtils (INPUT "START", INPUT "Host...................: " + oConfig:GetHost()).
    END.
    
    /**
     * Parameter 2: Port
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 2 THEN
    DO:
        oConfig:SetPort(INTEGER(ENTRY(2,SESSION:PARAMETER))).
        RUN DoLog IN hUtils (INPUT "START", INPUT "Port...................: " + STRING(oConfig:GetPort())).
    END.
    
    /**
     * Parameter 3: Output file directory
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 3 THEN
    DO:
        oConfig:SetOutDir(ENTRY(3,SESSION:PARAMETER)).
        RUN DoLog IN hUtils (INPUT "START", INPUT "Output Directory.......: " + STRING(oConfig:GetOutDir())).
    END.
    
    /**
     * Parameter 4: PROPATH
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 4 THEN
    DO:
        cParam = ENTRY(4,SESSION:PARAMETER).
        
        DO  nCount = 1 TO NUM-ENTRIES(cParam,"|"):
            IF  cPropath = "" THEN
                cPropath = ENTRY(nCount,cParam,"|").
            ELSE
                cPropath = cPropath + "," + ENTRY(nCount,cParam,"|").
        END.
        
        oConfig:SetPropath(cPropath).
        RUN DoLog IN hUtils (INPUT "START", INPUT "PROPATH................: " + oConfig:GetPropath()).
    END.
    
    /**
     * Parameter 5: Startup Program
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 5 THEN
    DO:
        oConfig:SetStartup(ENTRY(5,SESSION:PARAMETER)).
        RUN DoLog IN hUtils (INPUT "START", INPUT "Startup Program........: " + oConfig:GetStartup()).
    END.
        
    /**
     * Parameter 6: Startup Parameters
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 6 THEN
    DO:
        cParam = ENTRY(6,SESSION:PARAMETER).
        
        DO  nCount = 1 TO NUM-ENTRIES(cParam,"|"):
            IF  cParams = "" THEN
                cParams = ENTRY(nCount,cParam,"|").
            ELSE
                cParams = cParams + "," + ENTRY(nCount,cParam,"|").
        END.
        
        oConfig:SetStartupParams(cParams).
        RUN DoLog IN hUtils (INPUT "START", INPUT "Startup Parameters.....: " + oConfig:GetStartupParams()).
    END.
    
    /**
     * Parameter 7: Input Codepage
     */
    IF  NUM-ENTRIES(SESSION:PARAMETER) >= 7 THEN
    DO:
        oConfig:SetInputCodepage(ENTRY(7,SESSION:PARAMETER)).
        RUN DoLog IN hUtils (INPUT "START", INPUT "Input Codepage.........: " + oConfig:GetInputCodepage()).
    END.
    
    RUN DoLog IN hUtils (INPUT "START", INPUT "Finish loading OE agent configuration").
END PROCEDURE.

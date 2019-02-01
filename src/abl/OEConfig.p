
/*------------------------------------------------------------------------
    File        : OEConfig.p
    Purpose     : Configuration loader for "OE Test Agent" application.

    Syntax      :

    Description : Configuration Loader

    Author(s)   : Rubens Dos Santos Filho
    Created     : Fri Feb 01 13:32:51 BRST 2019
    Notes       :
  ----------------------------------------------------------------------*/

USING com.oetestagent.OEConfig FROM PROPATH.

/* ***************************  Definitions  ************************** */
DEFINE INPUT  PARAMETER cConfig AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER oConfig AS OEConfig  NO-UNDO.

DEFINE VARIABLE hUtils   AS HANDLE    NO-UNDO.
DEFINE VARIABLE nCount   AS INTEGER   NO-UNDO.
DEFINE VARIABLE cPropath AS CHARACTER NO-UNDO.
DEFINE VARIABLE cParam   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cParams  AS CHARACTER NO-UNDO.

/* ***************************  Main Block  *************************** */
RUN OEUtils.p PERSISTENT SET hUtils.
oConfig = NEW OEConfig().
    
RUN DoLog IN hUtils (INPUT "START", INPUT "Loading OE agent configuration from OE cConfig").
RUN DoLog IN hUtils (INPUT "START", INPUT "cConfig value: " + cConfig).
    
/**
 * Parameter 1: Host
 */
IF  NUM-ENTRIES(cConfig) >= 1 THEN
DO:
    oConfig:SetHost(ENTRY(1,cConfig)).
    RUN DoLog IN hUtils (INPUT "START", INPUT "Host...................: " + oConfig:GetHost()).
END.
    
/**
 * Parameter 2: Port
 */
IF  NUM-ENTRIES(cConfig) >= 2 THEN
DO:
    oConfig:SetPort(INTEGER(ENTRY(2,cConfig))).
    RUN DoLog IN hUtils (INPUT "START", INPUT "Port...................: " + STRING(oConfig:GetPort())).
END.
    
/**
 * Parameter 3: Output file directory
 */
IF  NUM-ENTRIES(cConfig) >= 3 THEN
DO:
    oConfig:SetOutDir(ENTRY(3,cConfig)).
    RUN DoLog IN hUtils (INPUT "START", INPUT "Output Directory.......: " + STRING(oConfig:GetOutDir())).
END.
    
/**
 * Parameter 4: PROPATH
 */
IF  NUM-ENTRIES(cConfig) >= 4 THEN
DO:
    cParam = ENTRY(4,cConfig).
        
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
IF  NUM-ENTRIES(cConfig) >= 5 THEN
DO:
    oConfig:SetStartup(ENTRY(5,cConfig)).
    RUN DoLog IN hUtils (INPUT "START", INPUT "Startup Program........: " + oConfig:GetStartup()).
END.
        
/**
 * Parameter 6: Startup Parameters
 */
IF  NUM-ENTRIES(cConfig) >= 6 THEN
DO:
    cParam = ENTRY(6,cConfig).
        
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
IF  NUM-ENTRIES(cConfig) >= 7 THEN
DO:
    oConfig:SetInputCodepage(ENTRY(7,cConfig)).
    RUN DoLog IN hUtils (INPUT "START", INPUT "Input Codepage.........: " + oConfig:GetInputCodepage()).
END.
    
RUN DoLog IN hUtils (INPUT "START", INPUT "Finish loading OE agent configuration").

DELETE PROCEDURE hUtils NO-ERROR.

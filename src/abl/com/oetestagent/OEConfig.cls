/*------------------------------------------------------------------------
   File        : Config
   Purpose     : 
   Syntax      : 
   Description : OE Test Agent configuration class
   Author(s)   : Rubens Dos Santos Filho
   Created     : Thu Nov 08 18:14:00 BRST 2018
   Notes       : 
 ----------------------------------------------------------------------*/

CLASS com.oetestagent.OEConfig FINAL: 
    DEFINE PRIVATE PROPERTY host AS CHARACTER INITIAL 'localhost' NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE PROPERTY port AS INTEGER INITIAL 2901 NO-UNDO 
        GET.
        SET. 
    
    DEFINE PRIVATE PROPERTY outDir AS CHARACTER INITIAL 'C:/tmp' NO-UNDO 
        GET.
        SET.
        
    DEFINE PRIVATE PROPERTY propath AS CHARACTER NO-UNDO 
        GET.
        SET. 

    DEFINE PRIVATE PROPERTY startup AS CHARACTER NO-UNDO 
        GET.
        SET.

    DEFINE PRIVATE PROPERTY startupParams AS CHARACTER NO-UNDO 
        GET.
        SET.
    
    DEFINE PRIVATE PROPERTY inputCodepage AS CHARACTER NO-UNDO INITIAL 'UTF-8' 
        GET.
        SET.
        
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetHost():
        RETURN THIS-OBJECT:host.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetHost(cHost AS CHARACTER):
        THIS-OBJECT:host = cHost.
    END METHOD.    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC INTEGER GetPort():
        RETURN THIS-OBJECT:port.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetPort(nPort AS INTEGER):
        THIS-OBJECT:port = nPort.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetOutDir():
        RETURN THIS-OBJECT:outDir.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetOutDir(cOutDir AS CHARACTER):
        THIS-OBJECT:outDir = cOutDir.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetPropath():
        RETURN THIS-OBJECT:propath.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetPropath(cPropath AS CHARACTER):
        THIS-OBJECT:propath = cPropath.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetStartup():
        RETURN THIS-OBJECT:startup.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetStartup(cStartup AS CHARACTER):
        THIS-OBJECT:startup = cStartup.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetStartupParams():
        RETURN THIS-OBJECT:startupParams.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetStartupParams(cStartupParams AS CHARACTER):
        THIS-OBJECT:startupParams = cStartupParams.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetInputCodepage():
        RETURN THIS-OBJECT:inputCodepage.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SetInputCodepage(cInputCodepage AS CHARACTER):
        THIS-OBJECT:inputCodepage = cInputCodepage.
    END METHOD.
END CLASS.

DEFINE VARIABLE hWindow  AS HANDLE    NO-UNDO.
DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

DEFINE FRAME hFrame
    cMessage AT ROW 1 COL 2 NO-LABELS FORMAT "x(50)"
    WITH NO-BOX OVERLAY SIZE 60 BY 01.

CREATE WINDOW hWindow
    ASSIGN
        TITLE        = "Hello World"
        HEIGHT       = 01
        WIDTH        = 60
        RESIZE       = FALSE
        SCROLL-BARS  = FALSE
        STATUS-AREA  = FALSE
        THREE-D      = TRUE
        MESSAGE-AREA = FALSE
        SENSITIVE    = TRUE
        HIDDEN       = FALSE.

ON  "WINDOW-CLOSE" OF hWindow
DO:
    APPLY "CLOSE" TO THIS-PROCEDURE.
END.

VIEW FRAME hFrame IN WINDOW hWindow.
cMessage:SCREEN-VALUE IN FRAME hFrame = "Hello World".
    
IF  NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.

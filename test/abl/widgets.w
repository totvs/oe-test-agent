
BLOCK-LEVEL ON ERROR UNDO, THROW.

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

DEFINE VARIABLE hWindow AS HANDLE NO-UNDO.

/* ***************************  Main Block  *************************** */

/* -------------------------  USER INTERFACE  ------------------------- */
DEFINE VARIABLE cComboList AS CHARACTER NO-UNDO FORMAT "x(50)" LABEL "List Items"
    VIEW-AS COMBO-BOX LIST-ITEMS "Option 1", "Option 2", "Option 3".

DEFINE VARIABLE cComboPair AS INTEGER   NO-UNDO FORMAT ">>>>>>>>>9" LABEL "List Pairs"
    VIEW-AS COMBO-BOX LIST-ITEM-PAIRS "Option 1", 1, "Option 2", 2, "Option 3", 3.

DEFINE VARIABLE cRadioList AS INTEGER   NO-UNDO FORMAT ">>>>>>>>>9" LABEL "Radio List"
    VIEW-AS RADIO-SET RADIO-BUTTONS "Option 1", 1, "Option 2", 2, "Option 3", 3.

DEFINE FRAME hFrame
    cComboList AT ROW 02 COL 02
    cComboPair AT ROW 04 COL 02
    cRadioList AT ROW 06 COL 02
    WITH 1 DOWN SIDE-LABELS NO-VALIDATE KEEP-TAB-ORDER THREE-D
    SIZE-CHARS 100 BY 15 AT ROW 01 COL 01
    FONT 0.

IF  SESSION:DISPLAY-TYPE = "GUI":U THEN
    CREATE WINDOW hWindow
    ASSIGN
        HIDDEN       = TRUE
        TITLE        = "Widgets"
        HEIGHT       = 15
        WIDTH        = 100
        RESIZE       = FALSE
        SCROLL-BARS  = FALSE
        STATUS-AREA  = FALSE
        THREE-D      = TRUE
        MESSAGE-AREA = FALSE
        SENSITIVE    = TRUE.
ELSE
    hWindow = CURRENT-WINDOW.

IF  SESSION:DISPLAY-TYPE = "GUI" AND VALID-HANDLE(hWindow) THEN
    hWindow:HIDDEN = FALSE.

ASSIGN
    CURRENT-WINDOW = hWindow
    THIS-PROCEDURE:CURRENT-WINDOW = hWindow.

PAUSE 0 BEFORE-HIDE.

/* --------------------------  UI TRIGGERS  --------------------------- */
ON  "WINDOW-CLOSE" OF hWindow
DO:
    APPLY "CLOSE" TO THIS-PROCEDURE.
END.

ON  "CLOSE" OF THIS-PROCEDURE
DO:
    RUN DisableUI.
END.

/* ----------------------------  INCLUDES  ---------------------------- */

/* ---------------------------  MAIN BLOCK  --------------------------- */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN EnableUI.

    IF  NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* **********************  Internal Procedures  *********************** */

PROCEDURE EnableUI PRIVATE:
    ENABLE cComboList cComboPair cRadioList WITH FRAME hFrame IN WINDOW hWindow.
    
    VIEW FRAME hFrame IN WINDOW hWindow.
    VIEW hWindow.
END PROCEDURE.

PROCEDURE DisableUI PRIVATE:
    DELETE WIDGET hWindow.

    IF  THIS-PROCEDURE:PERSISTENT THEN
        DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

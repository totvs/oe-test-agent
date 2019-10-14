DEFINE VARIABLE procname AS CHARACTER NO-UNDO.

SYSTEM-DIALOG GET-FILE procname
    TITLE "Choose Procedure to run..." 
    FILTERS "Source Files (*.p)" "*.p", "R-code Files (*.r)" "*.r" 
    USE-FILENAME.

MESSAGE "FILE: " + procname VIEW-AS ALERT-BOX INFORMATION TITLE procname.

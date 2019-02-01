/*------------------------------------------------------------------------
    File        : OEStart.p
    Purpose     : Start the "OE Test Agent" initialization.

    Syntax      :

    Description : "OE Test Agent" Starter

    Author(s)   : Rubens Dos Santos Filho
    Created     : Fri Nov 02 11:03:33 BRST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */

/* Change the session's PROPATH with the current directory */
FILE-INFO:FILE-NAME = ".".
PROPATH = FILE-INFO:FULL-PATHNAME + "," + PROPATH.

RUN OEInit.p (INPUT SESSION:PARAMETER).

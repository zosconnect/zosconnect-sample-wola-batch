       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZCONCBL.
      ******************************************************************
      *                                                                *
      * Licensed Materials - Property of IBM                           *
      *                                                                *
      * SAMPLE                                                         *
      *                                                                *
      * (c) Copyright IBM Corp. 2016 All Rights Reserved               *
      *                                                                *
      * US Government Users Restricted Rights - Use, duplication or    *
      * disclosure restricted by GSA ADP Schedule Contract with IBM    *
      * Corp                                                           *
      *                                                                *
      ******************************************************************
      * Sample Program Description                                     *
      *                                                                *
      * This sample program uses the WebSphere Optimized Local         *
      * Adapters (WOLA) APIs to interact with a z/OS Connect EE        *
      * server. It supports REST HTTP verbs POST, GET, PUT and DELETE. *
      * The JSON payload is mapped into a COBOL Copybook containing    *
      * an Employee's contact information that is stored in memory.    *
      *                                                                *
      * The WOLA APIs used by the sample program for outbound calls    *
      * are described below:                                           *
      *                                                                *
      *   BBOA1REG - Register program with local Liberty Server        *
      *   BBOA1SRV - Setup program as a server and target for          *
      *              optimized local adapter calls                     *
      *   BBOA1SRP - Send the response to a request back to the local  *
      *              Liberty Server                                    *
      *   BBOA1CNR - Release connection back to the pool and made      *
      *              available for another requester                   *
      *   BBOA1URG - Unregister from the local optimized local adapter *
      *              group and Liberty Server                          *
      *                                                                *
      * WOLA API Flow:                                                 *
      *                                                                *
      *   BBOA1REG                                                     *
      *      |  <------+                                               *
      *   BBOA1SRV     |                                               *
      *      |         |                                               *
      *   BBOA1SRP     | Loop stops if action specified was not        *
      *      |         |  recognized (not 'P', 'G', 'U' or 'D')        *
      *   BBOA1CNR     |                                               *
      *      |  -------+                                               *
      *   BBOA1URG                                                     *
      *                                                                *
      * Actions Supported:                                             *
      *                                                                *
      *   POST   'P' - Adds an employee's contact information          *
      *   GET    'G' - Retrieves the employee's contact information    *
      *   PUT    'U' - Updates the employee's contact information      *
      *   DELETE 'D' - Remove the employees' contact information       *
      *                                                                *
      ******************************************************************
       ENVIRONMENT DIVISION.
      ***********************
       DATA DIVISION.
      ****************
       WORKING-STORAGE SECTION.
      **************************
      *
      * INCLUDE THE COPYBOOK FOR REQUEST AND RESPONSE DATA STRUCTURE
      *
       COPY ZCONREQ.
       COPY ZCONRESP.
      *
      * DECLARE WORKING STORAGE VARIABLES USED IN THIS PROGRAM.
      *
      *---------------------------------------------------------------
      *   DATA-NAME                    DATA-TYPE
      *---------------------------------------------------------------
      *
      * REGISTRATION VARIABLES
      *
       01 REG-VARIABLES.
          05 REG-GRPNAME1             PIC X(8) VALUE LOW-VALUES.
          05 REG-GRPNAME2                  PIC X(8).
          05 REG-GRPNAME3               PIC X(8).
          05 REG-REGNAME               PIC X(12) VALUE SPACES.
          05 REG-MINCONN               PIC 9(8) COMP VALUE 1.
          05 REG-MAXCONN               PIC 9(8) COMP VALUE 10.
          05 REG-FLAGS                 PIC 9(8) COMP VALUE 0.
          05 REG-URG-FLAGS             PIC 9(8) COMP VALUE 0.
      *
      * SERVICE VARIABLES
      *
       01 SVC-VARIABLES.
          05 SVC-SERVICE-NAME          PIC X(255).
          05 SVC-SERVICE-NAME-LENGTH   PIC 9(8) COMP.
          05 SVC-RQST-DATA-ADDR        USAGE POINTER.
          05 SVC-RQST-DATA-LENGTH      PIC 9(8) COMP.
          05 SVC-RESP-DATA-ADDR        USAGE POINTER.
          05 SVC-RESP-DATA-LENGTH      PIC 9(8) COMP.
          05 SVC-CONNECT-HANDLE        PIC X(12).
          05 SVC-WAIT-TIME             PIC 9(8) USAGE BINARY.
      *
      * WOLA APIS RESPONSE VARIABLES
      *
       01 RSP-VARIABLES.
          05 RSP-RC                    PIC 9(8) COMP VALUE 0.
          05 RSP-RSN                   PIC 9(8) COMP VALUE 0.
          05 RSP-RV                    PIC 9(8) COMP VALUE 0.
      *
      * VARIABLES FOR STORING THE DATA
      *
       01 STOR-DATA.
          05 STOR-EMPID                PIC X(05).
          05 STOR-EMPNAME              PIC X(25).
          05 STOR-EMAIL                PIC X(30).
          05 STOR-PHONE                PIC X(20).
          05 STOR-REMARKS              PIC X(40).
      *
      * WORKING VARIABLES
      *
       01 HTTP-VERB                    PIC X(01).
       01 STOP-FLAG                    PIC 9(1) COMP VALUE 0.
       01 CLEAR-WITH-LOW               PIC X(255) VALUE LOW-VALUES.

       PROCEDURE DIVISION.
      *********************
       MAIN-CONTROL SECTION.
      *
      *
      * SET THE VALUES FOR USE WITH WOLA REGISTRATION
      *
           MOVE 'COBOLZCON'                    TO REG-REGNAME.
           MOVE 'GRPNAME1'                     TO REG-GRPNAME1.
           MOVE 'GRPNAME2'                     TO REG-GRPNAME2.
           MOVE 'GRPNAME3'                     TO REG-GRPNAME3.
           MOVE 'ZCONCBL'                      TO SVC-SERVICE-NAME.

           INSPECT REG-GRPNAME1 CONVERTING ' ' to LOW-VALUES.
      *
      * INITIALIZE THE LOCAL VARIABLES USED IN THIS PROGRAM.
      *
           INITIALIZE SVC-RQST-VARIABLES
                      SVC-RQST-DATA-LENGTH
                      SVC-RESP-VARIABLES
                      SVC-RESP-DATA-LENGTH
           EXIT.
      *
      * Register to a Local Liberty server
      * ==================================
      *
           CALL 'BBOA1REG' USING
                 REG-GRPNAME1,
                 REG-GRPNAME2,
                 REG-GRPNAME3,
                 REG-REGNAME,
                 REG-MINCONN,
                 REG-MAXCONN,
                 REG-FLAGS,
                 RSP-RC,
                 RSP-RSN.

           IF RSP-RC > 0 THEN
             DISPLAY "ERROR: Call to BBOA1REG failed"
             GO TO Bad-RC
           ELSE
             DISPLAY "========================================"
             DISPLAY "  *****  ******   ***   ****  **    **  "
             DISPLAY "  ** *** **      ** **  ** **  **  **   "
             DISPLAY "  *****  ****** ******* **  **  ****    "
             DISPLAY "  ** **  **     **   ** ** **    **     "
             DISPLAY "  **  ** ****** **   ** ****     **     "
             DISPLAY "========================================"
             DISPLAY " Register Name : " REG-REGNAME
             DISPLAY "========================================"
             DISPLAY " Successfully registered into: "
             DISPLAY " " REG-GRPNAME1 " " REG-GRPNAME2 " " REG-GRPNAME3
             DISPLAY "========================================"
           END-IF.

           MOVE LENGTH OF SVC-RQST-VARIABLES TO SVC-RQST-DATA-LENGTH.
           SET SVC-RQST-DATA-ADDR TO ADDRESS OF SVC-RQST-VARIABLES.
           INSPECT SVC-SERVICE-NAME CONVERTING ' ' to LOW-VALUES.

           PERFORM UNTIL STOP-FLAG EQUAL 1

             PERFORM Clear-Fields
      *
      * Setup host service
      * ==================
      *
             CALL 'BBOA1SRV' USING
                 REG-REGNAME,
                 SVC-SERVICE-NAME,
                 SVC-SERVICE-NAME-LENGTH,
                 SVC-RQST-DATA-ADDR,
                 SVC-RQST-DATA-LENGTH,
                 SVC-CONNECT-HANDLE,
                 SVC-WAIT-TIME,
                 RSP-RC,
                 RSP-RSN,
                 RSP-RV

             DISPLAY " "
             DISPLAY " Service Name        : " SVC-SERVICE-NAME
             DISPLAY " Data length         : " SVC-RQST-DATA-LENGTH
             DISPLAY " Return value length : " RSP-RV
             DISPLAY " "

             IF RSP-RC > 0 THEN
               DISPLAY "ERROR: Call to BBOA1SRV failed"
               GO TO Bad-RC
             END-IF
      *
      * Setup the response for the requested service
      * ============================================
      *
             DISPLAY "Service request processed"
             MOVE SVC-RQST-TYPE TO HTTP-VERB

             EVALUATE HTTP-VERB
               WHEN 'P'
                 MOVE "POST"             TO SVC-RESP-TYPE
                 MOVE SVC-RQST-DATA      TO SVC-RESP-DATA
                 MOVE SVC-RQST-DATA      TO STOR-DATA
                 MOVE "Record was added" TO SVC-RESP-MESSAGE
                 DISPLAY "-> POST action processed"
                 DISPLAY "   " SVC-RESP-MESSAGE
                 DISPLAY " "
                 DISPLAY "   - ID      : " SVC-RESP-EMPID
                 DISPLAY "   - Name    : " SVC-RESP-EMPNAME
                 DISPLAY "   - Email   : " SVC-RESP-EMAIL
                 DISPLAY "   - Phone   : " SVC-RESP-PHONE
                 DISPLAY "   - Remarks : " SVC-RESP-REMARKS
               WHEN 'G'
                 MOVE "GET"                  TO SVC-RESP-TYPE
                 MOVE "Record was retrieved" TO SVC-RESP-MESSAGE
                 MOVE STOR-DATA              TO SVC-RESP-DATA
                 DISPLAY "-> GET action processed"
                 DISPLAY "   " SVC-RESP-MESSAGE
                 DISPLAY " "
                 DISPLAY "   - ID      : " SVC-RESP-EMPID
                 DISPLAY "   - Name    : " SVC-RESP-EMPNAME
                 DISPLAY "   - Email   : " SVC-RESP-EMAIL
                 DISPLAY "   - Phone   : " SVC-RESP-PHONE
                 DISPLAY "   - Remarks : " SVC-RESP-REMARKS
               WHEN 'U'
                 MOVE SVC-RQST-DATA        TO SVC-RESP-DATA
                 MOVE SVC-RQST-DATA        TO STOR-DATA
                 MOVE "PUT"                TO SVC-RESP-TYPE
                 MOVE "Record was updated" TO SVC-RESP-MESSAGE
                 DISPLAY "-> UPDATE action processed"
                 DISPLAY "   " SVC-RESP-MESSAGE
                 DISPLAY " "
                 DISPLAY "   - ID      : " SVC-RESP-EMPID
                 DISPLAY "   - Name    : " SVC-RESP-EMPNAME
                 DISPLAY "   - Email   : " SVC-RESP-EMAIL
                 DISPLAY "   - Phone   : " SVC-RESP-PHONE
                 DISPLAY "   - Remarks : " SVC-RESP-REMARKS
               WHEN 'D'
                 MOVE "DELETE"             TO SVC-RESP-TYPE
                 MOVE "Record was deleted" TO SVC-RESP-MESSAGE
                 MOVE STOR-DATA            TO SVC-RESP-DATA
                 DISPLAY "-> DELETE action processed"
                 DISPLAY "   " SVC-RESP-MESSAGE
                 DISPLAY " "
                 DISPLAY "   - ID      : " SVC-RESP-EMPID
                 DISPLAY "   - Name    : " SVC-RESP-EMPNAME
                 DISPLAY "   - Email   : " SVC-RESP-EMAIL
                 DISPLAY "   - Phone   : " SVC-RESP-PHONE
                 DISPLAY "   - Remarks : " SVC-RESP-REMARKS
                 MOVE '11111'          TO STOR-EMPID
                 MOVE 'Deleted'        TO STOR-EMPNAME
                 MOVE 'Deleted'        TO STOR-EMAIL
                 MOVE '555-555-5555'   TO STOR-PHONE
                 MOVE 'Deleted'        TO STOR-REMARKS
               WHEN OTHER
                 MOVE "UNKNOWN" TO SVC-RESP-TYPE
                 MOVE "Program terminated." TO SVC-RESP-MESSAGE
                 DISPLAY "-> Unknown action was specified"
                 DISPLAY "   " SVC-RESP-MESSAGE
                 DISPLAY "   Program will terminate ..."
                 MOVE 1 TO STOP-FLAG
             END-EVALUATE

             MOVE LENGTH OF SVC-RESP-VARIABLES TO SVC-RESP-DATA-LENGTH
             SET SVC-RESP-DATA-ADDR TO ADDRESS OF SVC-RESP-VARIABLES
      *
      *  Send response to the service request
      *  ====================================
      *
             CALL 'BBOA1SRP' USING
                 SVC-CONNECT-HANDLE,
                 SVC-RESP-DATA-ADDR,
                 SVC-RESP-DATA-LENGTH,
                 RSP-RC,
                 RSP-RSN

             IF RSP-RC > 0 THEN
               DISPLAY "ERROR: Call to BBOA1RP failed"
               GO TO Bad-RC
             END-IF
      *
      *  Release WOLA connect
      *  ====================
      *
             CALL 'BBOA1CNR' USING
                   SVC-CONNECT-HANDLE,
                   RSP-RC,
                   RSP-RSN

             IF RSP-RC > 0 THEN
               DISPLAY "ERROR: Call to BBOA1CNR failed"
               GO TO Bad-RC
             END-IF

             MOVE STOR-DATA TO SVC-RESP-DATA

           END-PERFORM.
      *
      *  Unregister service
      *  ==================
      *
           CALL 'BBOA1URG' USING
               REG-REGNAME,
               REG-URG-FLAGS,
               RSP-RC,
               RSP-RSN

           IF RSP-RC > 0 THEN
             DISPLAY "ERROR: Call to BBOA1URG failed"
             GO TO Bad-RC
           ELSE
             DISPLAY " "
             DISPLAY " Successfully unregistered from "
             DISPLAY " " REG-GRPNAME1 " " REG-GRPNAME2 " " REG-GRPNAME3
             DISPLAY " "
           END-IF.

           GOBACK.
      *
      *  Clear the fields and save a copy of data
      *  ========================================
      *
       Clear-Fields.
           MOVE CLEAR-WITH-LOW TO STOR-DATA
           MOVE SVC-RESP-DATA  TO STOR-DATA
           MOVE CLEAR-WITH-LOW TO SVC-RQST-VARIABLES.
           MOVE CLEAR-WITH-LOW TO SVC-RESP-VARIABLES.
      *
      *  Section used to exit batch if any API returned RC>0
      *  ===================================================
      *
       Bad-RC.
           DISPLAY "                          "
           DISPLAY " Return Code = " RSP-RC
           DISPLAY " Reason Code = " RSP-RSN
           DISPLAY "                          "
           DISPLAY " Program ended with Error "
           GOBACK.

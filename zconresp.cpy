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
       01 SVC-RESP-VARIABLES.
          05 SVC-RESP-STATUS.
             10 SVC-RESP-TYPE                   PIC X(10).
             10 SVC-RESP-MESSAGE                PIC X(50).
          05 SVC-RESP-DATA.
             10 SVC-RESP-EMPID                  PIC X(05).
             10 SVC-RESP-EMPNAME                PIC X(25).
             10 SVC-RESP-EMAIL                  PIC X(30).
             10 SVC-RESP-PHONE                  PIC X(20).
             10 SVC-RESP-REMARKS                PIC X(40).

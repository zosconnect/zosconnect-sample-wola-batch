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
       01 SVC-RQST-VARIABLES.
          05 SVC-RQST-TYPE                      PIC X(01).
          05 SVC-RQST-DATA.
             10 SVC-RQST-EMPID                  PIC X(05).
             10 SVC-RQST-EMPNAME                PIC X(25).
             10 SVC-RQST-EMAIL                  PIC X(30).
             10 SVC-RQST-PHONE                  PIC X(20).
             10 SVC-RQST-REMARKS                PIC X(40).
          05 SVC-RQST-FILLER                    PIC X(59).

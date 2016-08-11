//********************************************************************
//*                                                                  *
//* Licensed Materials - Property of IBM                             *
//*                                                                  *
//* SAMPLE JCL                                                       *
//*                                                                  *
//* (c) Copyright IBM Corp. 2016 All Rights Reserved                 *
//*                                                                  *
//* US Government Users Restricted Rights - Use, duplication or      *
//* disclosure restricted by GSA ADP Schedule Contract with IBM      *
//* Corp                                                             *
//*                                                                  *
//********************************************************************
//*                                                                  *
//* NOTES:                                                           *
//*                                                                  *
//* Sample JCL to execute the COBOL batch program                    *
//*                                                                  *
//* 1. Add Job card                                                  *
//* 2. Replace <USER.LOAD.LIB> to the actual library containing      *
//*    the load module                                               *
//*                                                                  *
//********************************************************************
//*
//STEP1    EXEC PGM=ZCONCBL
//STEPLIB  DD   DSN=<USER.LOAD.LIB>,DISP=SHR
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   DUMMY
/*

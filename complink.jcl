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
//* Sample JCL to compile and link edit the sample COBOL batch       *
//* program that will be used with z/OS Connect. The sample JCL was  *
//* based on a COBOL 5.1 Compiler.                                   *
//*                                                                  *                                                      
//* 1. Add Job card                                                  *
//* 2. Update <LNGPRFX> with the HLQ for COBOL compiler data set,    *
//*    for example IGY.V5R1M0                                        *
//* 3. Update <LIBPRFX> with the HLQ for Library data set, for       *
//*    example CEE                                                   *
//* 4. Update <COPYBOOK.PDS.LIB> with the name of the PDS data set   *
//*    containing the ZCONREQ and ZCONRESP                           *
//* 5. Update <SOURCE.PDS.LIB> with the name of the PDS data set     *
//*    containing the source member ZCONCBL                          *
//* 6. Update <WOLA.LOAD.LIB> with the name of the library that      *
//*    contains the WOLA modules                                     *
//* 7. Update <USER.LOAD.LIB> with the name of the library where     *
//*    you want to store the load module                             *
//*                                                                  *
//********************************************************************
//*                 
//* COMPILE STEP
//*                                                    
//COBOL  EXEC PGM=IGYCRCTL,REGION=0M,PARM=('RENT')                      
//STEPLIB  DD  DSNAME=<LNGPRFX>.SIGYCOMP,DISP=SHR                      
//         DD  DSNAME=<LIBPRFX>.SCEERUN,DISP=SHR                              
//         DD  DSNAME=<LIBPRFX>.SCEERUN2,DISP=SHR                             
//SYSPRINT DD  SYSOUT=*                                                 
//SYSLIN   DD  DSNAME=&&LOADSET,UNIT=SYSALLDA,                          
//             DISP=(MOD,PASS),SPACE=(CYL,(1,1))                        
//SYSLIB   DD  DSN=<COPYBOOK.PDS.LIB>,DISP=SHR
//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT2   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT3   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT4   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT5   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT6   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT7   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT8   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT9   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT10  DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT11  DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT12  DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT13  DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT14  DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSUT15  DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSMDECK DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          
//SYSIN    DD  DSN=<SOURCE.PDS.LIB>(ZCONCBL),DISP=SHR
//*
//* LINK EDIT STEP
//*
//LKED   EXEC PGM=IEWBLINK,COND=(8,LT,COBOL),REGION=0M,                 
//            PARM=('LIST,XREF,LET,MAP')
//SYSLIB   DD  DSNAME=<LIBPRFX>.SCEELKED,DISP=SHR                             
//         DD  DSNAME=<LIBPRFX>.SCEELKEX,DISP=SHR                             
//         DD  DSNAME=<WOLA.LOAD.LIB>,DISP=SHR
//SYSPRINT DD  SYSOUT=*                                                 
//SYSLIN   DD  DSNAME=&&LOADSET,DISP=(OLD,DELETE)                       
//         DD  DDNAME=SYSIN                                             
//SYSLMOD  DD  DSNAME=<USER.LOAD.LIB>(ZCONCBL),DISP=SHR             
//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))                          

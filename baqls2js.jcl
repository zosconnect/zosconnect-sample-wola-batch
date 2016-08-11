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
//* Sample JCL to run the BAQLS2JS utility to convert the language   *
//* structures used by the COBOL batch program to JSON schemas       *
//*                                                                  *
//* 1. Add Job card                                                  *
//* 2. Update <install-path> using the actual z/OS Connect EE        *
//*    installation path, for example: /usr/lpp/zosconnect           *
//* 3. Update <log-path> to the directory where you want the log     *
//*    file 	written and <filename> to the name of the log file      *
//* 4. Update <COPYBOOK.PDS.LIB> to the name of the PDS data set     *
//*    containing the COPYBOOK members ZCONREQ and ZCONRESP          *
//* 5. Update <json-path> to the directory where you want the JSON   *
//*    files written                                                 *
//* 6. Update <bind-path> to the directory where you want the bind   *
//*    file written                                                  *
//* 7. Update <sar-path> to the directory where you want the service *
//*    archive file written                                          *
//* 8. Update <java-path> to the directory where the version of Java *
//*    you want to use is installed, for example:                    *
//*    /usr/lpp/java/J7.0_64                                         *
//*                                                                  *
//********************************************************************
//ASSIST   EXEC PGM=BPXBATCH                                            
//STDPARM  DD *                                                         
PGM /<install-path>/v2r0/bin/baqls2js                               
LOGFILE=/<log-path>/<filename>.log                            
LANG=COBOL                                                              
MAPPING-LEVEL=4.0                                                       
PDSLIB=<COPYBOOK.PDS.LIB>                                             
REQMEM=ZCONREQ                                                       
RESPMEM=ZCONRESP                                                        
JSON-SCHEMA-REQUEST=/<json-path>/CobolService_request.json    
JSON-SCHEMA-RESPONSE=/<json-path>/CobolService_response.json  
WSBIND=/<bind-path>/CobolService.wsbind                     
PGMNAME=ZCONCBL                                                         
PGMINT=COMMAREA                                                         
SERVICE-ARCHIVE=/<sar-path>/CobolService.sar                      
SERVICE-NAME=CobolService                                           
/*
//STDOUT   DD SYSOUT=*
//STDERR   DD SYSOUT=*
//STDENV   DD *
JAVA_HOME=<java-path>

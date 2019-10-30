# Sample z/OS application for z/OS Connect Enterprise Edition (EE)

A COBOL application which demonstrate how to use the WebSphere Optimized Local Adapters (WOLA) native
APIs to register to a z/OS Connect Enterprise Edition (EE) server and host a service.

## Prerequisites

* z/OS Connect Enterprise Edition is installed and a z/OS Connect EE instance has been created and configured with WOLA. Refer to the [z/OS Connect EE documentation](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/com.ibm.zosconnect.doc/configuring/configuring.html) in the IBM Knowledge Center for further information on how to create a new z/OS Connect Enterprise Edition Server and using the WOLA service provider. The steps to configure batch for WOLA is similar to configuring CICS to use WOLA.
* Enterprise COBOL Compiler

## Installing

* Clone this repository `git clone git@github.com:zosconnect/zosconnect-sample-wola-batch.git`
* Allocate a PDS with 30 tracks for the jobs and source files

```text
Average record unit
Primary quantity  . . 30
Secondary quantity    5
Directory blocks  . . 10
Record format . . . . FB
Record length . . . . 80
Block size  . . . . . 27920
Data set name type    PDS
```

* Allocate a PDSE with 15 tracks for the load module

```text
Average record unit
Primary quantity  . . 10
Secondary quantity    5
Directory blocks  . . 10
Record format . . . . U
Record length . . . . 0
Block size  . . . . . 32760
Data set name type    LIBRARY
```

* Upload the following source and sample JCLs to your z/OS system and store on the PDS that was allocated

```text
runcobol.jcl
complink.jcl
zconresp.cpy
zconreq.cpy
zconcbl.cbl
```

* Customize the uploaded copy of **complink.jcl** for your environment and submit. Additional instructions are provided in the sample JCL. The expected return code is **0**.

* Create the SAR file using the z/OS Connect Enterprise Edition build toolkit.
  ```sh
  zconbt -p CobolService.properties -f CobolService.sar
  ```

![Diagram 1](https://github.com/zosconnect/zosconnect-sample-wola-batch/blob/master/media/Diag1.png)

**NOTE:** The name of the program in the properties file should match the service name in the Cobol program.

## Configuring

* Create a directory (if not done yet) called **resources/zosconnect/services** under your server path.
  ```text
  /var/zosconnect/servers/<server-name>/resources/zosconnect/services
  ```
* Recursively chown and chmod the output directories so your Liberty z/OS server ID has access to them.
  ```sh
  cd /var/zosconnect/servers/<server-name>
  chown -R <serverID>:<serverGroup> ./resources
  chmod -R 750 ./resources
  ```
* Copy the SAR file into the **resources/zosconnect/services** directory. If transferring the file via ftp, ensure the file is transferred as binary.
* Setup definitions for the WOLA connection in server.xml. The server.xml should have the following entries added:
  ```xml
  <zosconnect_zosConnectAPIs location="">
      <zosConnectAPI name=“CobolService”/>
  </zosconnect_zosConnectAPIs>

  <zosconnect_services location="">
      <service name="CobolService"/>
  </zosconnect_services>

  <zosLocalAdapters wolaGroup=“GRPNAME1”
      wolaName2=“GRPNAME2”
      wolaName3=“GRPNAME3”/>

  <connectionFactory id="wolaCF" jndiName="eis/ola">
      <properties.ola/>
  </connectionFactory>
  ```

**NOTE:** Change the server-name to the actual name of the z/OS Connect instance you created. A sample server.xml is included in the package. If you want to use the sample server.xml file then upload it to z/OS in binary mode to keep the contents in ASCII format.

At this point you have service definitions to match the COBOL service sample provided but do not yet have an API created and deployed.

## Deploying the sample API

Before deploying the sample API, import the sample project provided. A sample API archive **CobolService.aar** is included in the project.

* On your IBM Explorer for z/OS (or any of the supported Eclipse environment), click on **File -> Import** then click on **General -> Existing Projects into Workspace**. Select the CobolService.zip file included in the package (confirm that the CobolService project is selected under the Projects field) and click **Finish**.

* To deploy the sample API, follow the steps described in the [Automated API management](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/com.ibm.zosconnect.doc/administering/auto_api_mgmnt.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center.

## Testing the sample API

At this point, you are ready to test the sample APIs provided to call the COBOL batch service using z/OS Connect EE.

* Customize the uploaded copy of **runcobol.jcl** for your environment and submit. Additional instructions are provided in the sample JCL. The job is a long-running batch job and is expected to run until it is cancelled, stopped or an unexpected error occured that forces the job to terminate.
* The following output is displayed on the job log to indicate that the COBOL batch program is ready to accept requests:
  ```text
  ========================================
    *****  ******   ***   ****  **    **
    ** *** **      ** **  ** **  **  **
    *****  ****** ******* **  **  ****
    ** **  **     **   ** ** **    **
    **  ** ****** **   ** ****     **
  ========================================
   Register Name : COBOLZCON
  ========================================
   Successfully registered into:
   GRPNAME1 GRPNAME2 GRPNAME3
  ========================================
  ```

* To test the API using the z/OS Connect EE API Editor, refer to the section on [Examining, testing, starting and stopping an API](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/com.ibm.zosconnect.doc/designing/api_edit_view_start_stop.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center.

* To test the POST method using a REST client, use the following:
  ```json
  Method: POST
  URL: http://<host>:<port>/CobolService/employee
  JSON:
  {
    "ZCONCBLOperation": {
      "svc_rqst_variables": {
        "svc_rqst_data": {
          "svc_rqst_email": "john.doe@email.com",
          "svc_rqst_empid": "12345",
          "svc_rqst_remarks": "Sample",
          "svc_rqst_empname": "John Doe",
          "svc_rqst_phone": "123-456-7890"
        }
      }
    }
  }
  ```
* To test the GET method using a REST client, use the following:
  ```json
  Method: GET
  URL: http://<host>:<port>/CobolService/employee
  JSON: No JSON and parameter is used. Only one record is kept by the batch program.
  ```
* To test the PUT method using a REST client, use the following:
  ```json
  Method: PUT
  URL: http://<host>:<port>/CobolService/employee
  JSON:
  {
    "ZCONCBLOperation": {
      "svc_rqst_variables": {
        "svc_rqst_data": {
          "svc_rqst_email": "michael.doe@email.com",
          "svc_rqst_empid": "54321",
          "svc_rqst_remarks": "Sample Update",
          "svc_rqst_empname": "Michael Doe",
          "svc_rqst_phone": "111-222-3333"
        }
      }
    }
  }
  ```

* To test the DELETE method using a REST client, use the following:
  ```json
  Method: DELETE
  URL: http://<host>:<port>/CobolService/employee
  JSON: No JSON and parameter is used. Only one record is kept by the batch program.
  ```

## Notice

&copy; Copyright IBM Corporation 2016, 2017

## License

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

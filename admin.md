# HRI Administration

HRI Administration tasks can be split up into two categories: 
  1. [Creation of new HRI Tenants](#create-a-new-tenant)
      1. [Set Up Curl with ElasticSearch](#set-up-curl-with-elasticsearch)
      2. [Set the Default Index Template](#set-the-default-index-template)
      3. [Create a new Tenant in ElasticSearch](#create-a-new-tenant-in-elasticsearch)
  2. [Onboarding Data Integrators](#onboarding-new-data-integrators)
      1. [Using the Management API Stream Endpoints](#using-the-management-api-stream-endpoints)
  3. [HRI Management API Keys](#hri-management-api-keys)
   
## Create a new Tenant

#### Set Up Curl with ElasticSearch
  1. Note: this requires the use of the [command-line cURL](https://github.com/curl/curl) tool
  2. In your IBM Cloud [ElasticSearch (Document Store)](glossary.md#elasticsearch) account, you will need to have either:
      * an existing Service Credential you can access  OR
      * create a new Service Credential that you will use below for the `$USERNAME` and  `$PASSWORD` needed to run the ElasticSearch REST commands
    
To create a new Service Credential:

 Navigate to the ElasticSearch service instance in your [IBM Cloud account](https://cloud.ibm.com/login). In the example below, the ElasticSearch Service is named `HRI-DocumentStore`.

 Click on the "Service Credentials" link on the left-hand side ElasticSearch service menu. 
  
   ![doc-store-svc-creds](assets/img/doc_store_svc_creds.jpg)
  
 On the Service Credentials page click the New Credential button:
  
   ![doc-store-new-cred](assets/img/doc_store_new_cred.jpg)
    
 You will name your new credential and click the "Add" button. After that, your credential will be generated for you and you will be able to click on the "View Credentials" link (circled in Red below):
 
   ![view-new-credential](assets/img/view_new_credential.jpg)
   
   + From the expanded service credentials window, retrieve your newly created ElasticSearch Username and Password needed for the ElasticSearch REST commands using cURL. Capture the string that contains both the username and password by copying the `-u` "argument" from the JSON string (within the "connection" and "cli" sections). 
   
   For example, in the screen cap above, the new credential is named `test-cred-1`, and, in the circled section after the word "arguments\" :[", there is a long string (after the line with "-u\") starting with the characters `ibm_cloud_40cfdf40`. The section of this string before the ":" (colon) is the UserName you will need; while the section after the ":" is the Password, as in:
    
       UserName: ibm_cloud_40cfdf40_e075_44aa_8bc1_04a247619e4f
       Password: 79d9379ee59771fdf544c84538879f5ef6446e73c0707a768d031cd86e1e2020
    
Next, you will need to download the certificate and export it, so cURL can authenticate with the IBM Cloud ElasticSearch instance. To do this:
  
  Navigate to the Management screen for your ElasticSearch instance, which will look something like this (id field obscured in the ScreenCap for security):
  
  ![doc-store-manage](assets/img/doc_store_manage.jpg)
  
  Scroll down your screen, and in the "Connections" panel, click on the "CLI" toggle. You will be using cURL to run commands from your local environment on the IBM Cloud ElasticSearch instance. See this page in the IBM Cloud Documentation for more info on [Connecting to Elasticsearch with cURL](https://cloud.ibm.com/docs/services/databases-for-elasticsearch?topic=databases-for-elasticsearch-connecting-curl).
  
  In the "Connections" panel, there is a section for _TLS Certificate_. You will want to save the text from the "Contents" panel in that TLS Certificate section to a local file such as 
      
      /Users/[yourLocalUserName]/certs/hri-documentstore.crt 
  
  Use the contents of this file with cURL by exporting it to `CURL_CA_BUNDLE`. 
      
      $ export CURL_CA_BUNDLE=/local-path/to/file/hri-documentstore.crt
          
  Find the base url in the "Public CLI endpoint" textbox. In this example it starts with `https://8165307`:
  
  ![doc-store-conns-2](assets/img/doc_store_conns_2.jpg)
  
      https://8165307e-6130-4581-942d-20fcfc4e795d.bkvfvtld0lmh0umkfi70.databases.appdomain.cloud:30600
      
  You can now interact with the ElasticSearch REST API using cURL. For example, you can get the status of the cluster by performing a `GET` on the `_cluster/health?pretty` endpoint.
      
      $ curl -X GET -u ibm_cloud_40cfdf40_e075_44aa_8bc1_04a247619e4f:79d9379ee59771fdf544c84538879f5ef6446e73c0707a768d031cd86e1e2020 \
      https://8165307e-6130-4581-942d-20fcfc4e795d.bkvfvtld0lmh0umkfi70.databases.appdomain.cloud:30600/_cluster/health?pretty
  
***
#### Set the Default Index Template
An index template needs to be loaded into ElasticSearch, so newly created indexes are configured properly. This only has to be done once.
  
  First download the index template from [github](https://github.com/Alvearie/hri-mgmt-api/blob/master/document-store/index-templates/batches.json). Make sure you switch to the version of the file that matches the release tag you are deploying.
  
  Next, `POST` to the `_template/batches` endpoint to upload the template. 
      
      $ curl -X POST -u ibm_cloud_40cfdf40_e075_44aa_8bc1_04a247619e4f:79d9379ee59771fdf544c84538879f5ef6446e73c0707a768d031cd86e1e2020 \
      https://8165307e-6130-4581-942d-20fcfc4e795d.bkvfvtld0lmh0umkfi70.databases.appdomain.cloud:30600/_template/batches \
      -H 'Content-Type: application/json' \
      -d '@batches.json'
  
### Create a new Tenant in ElasticSearch
  Every [Tenant](glossary.md#tenant) has a separate index in ElasticSearch. Indexes are named `<tenantId>-batches`. For example, if the tenant id is `24`, the new index name will be `24-batches`. Some solutions may include a `tenant` prefix, e.g. `tenant24-batches`. The tenant id _may contain_ any lowercase alpha numeric strings, -, and _. The pattern you use will determine the tenant id path parameter required in most of the Management API [endpoints](apispec.md), and will need to be communicated to Data Integrators for that tenant. 

There are four Management API endpoints that support Tenant Management in ElasticSearch for HRI: Create, Get (all tenants), Get (specific tenant) and Delete. Please note that all four of these endpoints require an API key and IAM Authentication - you will need to pass in an IAM Bearer token as part of the Authorization header in the requests.

#### Create Tenant
Use the Management API Create Tenant endpoint to create new Tenants. This will create a new index for the Tenant in ElasticSearch. The `Create` Tenant endpoint takes in one path parameter `tenantId`, which may only contain lowercase alpha numeric characters, -, and _. For example, for the `tenantId` "tenant24" you would use the following curl command:

      $ curl -X POST \
          <hri_base_url>/tenants/tenant24 \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json' 
    
#### Get Tenants
The `Get` endpoint takes in no parameters and returns a list of all tenantIds that have an elastic index. Assuming the above Create was run, then the following the following cURL command (HTTP/Get operation) would return a list containing the single tenantId "tenant24":

      $ curl -X GET \
          <hri_base_url>/tenants \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json'
             
#### Get (single) Tenant
The `GetTenant` endpoint can also take in a `tenantId` and will return a list of information on the associated index. Assuming the above Create was run, then the following the following cURL command (HTTP/Get operation) would return a list of information on the index for "tenant24":

      $ curl -X GET \
          <hri_base_url>/tenants/tenant24 \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json'

#### Delete Tenant
Like `Create`, the `Delete` Tenant endpoint takes in `tenantId`. The following curl command will delete the elastic index for `tenant24`:
      
      $ curl -X DELETE \
          <hri_base_url>/tenants/tenant24 \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json' 

## Onboarding New Data Integrators
HRI has been designed with HIPAA-compliance in mind. In order to satisfy HIPAA data isolation requirements, there must be two Event Streams (Kafka) topics for every unique combination of Tenant and [Data Integrator](glossary.md#data-integrator). See [Multi-tenancy](multitenancy.md) for more details. 

These topics can be added automatically through the Management API (see below: [Using the Management API Stream Endpoints](#using-the-management-api-stream-endpoints)).

### Topic Naming Conventions: 
Please note that HRI uses the following naming conventions for the 2 new topics you will create:
  1. `ingest.<tenantId>.<dataIntegratorId>[.optionalMetadataTag].in`
  2. `ingest.<tenantId>.<dataIntegratorId>[.optionalMetadataTag].notification`

where `optionalMetadataTag` is Data Integrator defined. And, since it is optional, it can be blank. For example, with tenant id `24` and Data Integrator id `producer` the two topics would be `ingest.24.producer.in` and `ingest.24.producer.notification`. The tenant id may also include a `tenant` prefix, e.g. `ingest.tenant24.producer.in` and `ingest.tenant24.producer.notification`, but it must be consistent with the ElasticSearch [index tenant id](#create-a-new-tenant-in-elasticsearch). NOTE: Only use lowercase alpha numeric characters, -, and _.

### Using the Management API stream endpoints

Setting up HRI for a new Data Integrator also requires creating a [Stream](glossary.md#stream). The Management API contains three `Stream` endpoints to help you manage Streams: `Create`, `Get`, and `Delete`. Please note that all three of these endpoints require an API key and IAM Authentication - you will need to pass in an IAM Bearer token as part of the Authorization header in the requests. 

In the case of `Create` and `Delete`, the IAM bearer token must be associated with a user who has Manager role permissions. For `Get`, the bearer token must be associated with a user who has at least Reader role permissions. See [Event Streams documentation](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security#assign_access) for details on permissions.

#### Create Stream
You can use the Management API Create Stream endpoint to create the `in` and `notification` topics for the Tenant and Data Integrator pairing.

The `Create` Stream endpoint takes in two path parameters, `tenantId` and `streamId`, where `streamId` is made up of the Data Integrator Id and an optional qualifier, delimited by '.'. 

Both `tenantId` and `streamdId` **may only contain lowercase alpha numeric characters, -, and _**. `streamdId` may also contain one '.'. For example, for the `tenantId` "tenant24", Data Integrator Id "data-int-1" and optional qualifier "qualifier1", you could use the following curl command:

      $ curl -X POST \
          <hri_base_url>/tenants/tenant24/streams/data-int-1.qualifier1 \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json' \
          -d '{
        	"numPartitions":1,
        	"retentionMs":86400000
          }'

This will create the following topics for you, both with 1 partition and a retention time of 1 day:
  1. `ingest.tenant24.data-int-1.qualifier1.in`
  2. `ingest.tenant24.data-int-1.qualifier1.notification`
  
Note that the `numPartitions` and `retentionMs` topic configurations are required. There are other optional configurations that can also be passed in, see the [Stream Api Spec](apispec.md) for more details on these optional fields.

#### Get Streams
The `Get` Streams endpoint takes in `tenantId` as a path parameter, and returns a list of all streamIds associated with that tenant. Assuming the above Create was run, then the following the following cURL command (HTTP/Get operation) would return a list containing the single streamId `data-int-1.qualifier1`:

      $ curl -X GET \
          <hri_base_url>/tenants/tenant24/streams \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json'
             
#### Delete Stream
Like `Create`, the `Delete` Stream endpoint takes in two path parameters, `tenantId` and `streamId`. The following curl command will delete both the `ingest.tenant24.data-int-1.qualifier1.in` and `ingest.tenant24.data-int-1.qualifier1.notification` topics:

      $ curl -X DELETE \
          <hri_base_url>/tenants/tenant24/streams/data-int-1.qualifier1 \
          -H 'Accept: application/json' \
          -H 'Authorization: Bearer <token>' \
          -H 'X-IBM-Client-Id: <apikey>' \
          -H 'Content-Type: application/json' 

Note that HRI topic naming conventions require topics to start with the prefix "ingest" and end with the suffix "in" or "notification". **Both the Get and Delete endpoints will ignore any topics that don't follow this convention**.

#### Creating Service Credentials for Kafka Permissions
An Event Streams (Kafka) Service Credential needs to be created for every client that will need to read from or write to one or more topics. Typically, every Data Integrator and [Data Consumer](glossary.md#data-consumer) will need their own service credential. A service credential can be configured with IAM policies to grant read and/or write access to specific topics and consumer groups, so only one service credential is needed for each entity. You do **_not_** need to create a service credential for every topic.

Each service credential will initially have read or write access to all topics when created depending on whether the 'Reader' or 'Writer' role is selected respectively. But they can be configured with IAM policies to just grant read and or write access to specific topics and consumer groups regardless of which role is selected. It's good practice to select 'Writer' for Data Integrators and 'Reader' for downstream consumers.
    
To restrict access to particular topics, you have to modify the existing policy in IAM and create several new ones. Below are rules about what policies to create for specific access.

1. Create a policy with 'Reader' service access and 'Resource type' set to `cluster`. This will allow the Service ID to access the Event Streams brokers.
1. To allow read & write permissions to a particular topic, create a policy with 'Reader' and 'Writer' service access, 'Resource type' set to `topic`, and 'Resource ID' set to the topic name.
1. To allow just read permissions to a particular topic, create a policy with 'Reader' service access, 'Resource type' set to `topic`, and 'Resource ID' set to the topic name.
1. Additionally, to allow read access to any topic, the Service ID must be given permissions to a particular consumer group. Create a policy with 'Reader' service access, 'Resource type' set to `group`, and 'Resource ID' set to the client's ID followed by a `*` using 'string matches', e.g. `integrator*`. The client **must** use a consumer group that begins with this ID when connecting to Event Streams, which also prevents clients from interfering with each other. 

Also, policies support wildcards at the beginning and/or end of the 'Resource ID' field when using the 'string matches' qualifier. This enables _a single policy to allow access to multiple topics_ when they share a common substring. For example, `ingest.24.integrator1.*` could be used to allow access to both the `ingest.24.integrator1.in` and `ingest.24.integrator1.notification` topics.

The Data Integrator will need read & write access to the input topic, but only read access to the notification topic. This requires four IAM policies total. 

The downstream Consumer will need just read access to the input and notification topics. This requires three IAM policies total. 

More detailed documentation on how to configure IAM policies for Event Streams [can be found here](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-security). 

## HRI Management API Keys
Any user of the Management API, such as Data Integrators or Consumers, will need an API key. The HRI Management API uses [IBM Functions'](glossary.md#ibm-cloud-functions) built in API key management. To manage API keys, go to IBM Functions [APIs](https://cloud.ibm.com/functions/apimanagement) and select the correct namespace from the top right drop down. For example, if the correct namespace is `HRI-API`, you will go to your IBM Cloud Functions screen in the APIs sub-menu, and note the name of your Functions namespace:
 
![functions_apis](assets/img/ibm_functions_apis_namespace.jpg)

Then click on the `hri` API. This will bring up a new window with detailed information about the API. Go to 'Sharing and Keys' to view, create, or delete API keys. Note there is also an 'API Explorer' section where you can view the API endpoints and try calling them interactively. 

# Troubleshooting

## HRI Management API Issues

### Authentication is possible but has failed or not yet been provided
_**NOTE:** Only valid for versions prior to `v3.0.0`_

**Issue:** the Management API responds with this error: 
```json
{
  "code": "2cde977c23b3ab78befed56a6aac3820",
  "error": "Authentication is possible but has failed or not yet been provided."
}
```

**Cause:** the IBM Functions API Gateway is unable to authenticate with the backend IBM Function Actions. Actions have an API key and the API Gateway must be configured to use that API key. Typically, this is due to the API Gateway missing or having the wrong API key.

**Fix:** <br>
**Option 1**. Try redeploying the Management API. This will generate a new API key and set it on the Actions and the API Gateway endpoints.

**Option 2**. Manually update the API endpoints.

1. You will need the IBM Cloud CLI and Functions plugin. See these [instructions](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-cli_install) for installing them.
2. Set the CLI resource group to where the Management API is deployed. 

        ibmcloud target -g <resource_group>

3. Set the CLI Functions namespace to where the Management API is deployed.

        ibmcloud fn namespace target <namespace>

4. Recreate all the API methods. Below is an example of the create batch endpoint. Reference `mgmt-api-manifest.yml` for a complete list of the endpoints and their associated actions.

        ibmcloud fn api create /hri /tenants/{tenantId}/batches post hri_mgmt_api/create_batch --response-type http


**Option 3**. Manually update the API gateway JSON configuration.

1. Follow steps 1-3 above to set up the IBM CLI.
2. Download the API json configuration.

        ibmcloud fn api get hri-batches > api.json

3. Get the API key set for the Actions. Run 

        ibmcloud fn package get hri_mgmt_api

    and the output should have a `"require-whisk-auth"` entry for each action. It should be the same value for every action. E.g:

        {
            "key": "require-whisk-auth",
            "value": "hIadvQ8w4nkJeWa3i7OPDb9WqTAUV9d6"
        },

4. Edit the `api.json` file and add or replace the API key. There will be a `x-ibm-configuration` element, and a couple of layers inside, an array of `execute` elements, one for each endpoint. Each of these needs to have a `set-variable.actions` element that sets `message.headers.X-Require-Whisk-Auth` to the API key. Make sure there is one for every endpoint and that they match the API key from step 3. 
```json
{
		"execute": [
		    {
		        "invoke": {
		            "target-url": "https://us-south.functions.cloud.ibm.com/api/v1/web/a98e053a-4a77-46b3-9791-53d4dfa370fb/hri_mgmt_api/get_batches.http$(request.path)",
		            "verb": "keep"
		        }
		    },
		    {
		        "set-variable": {
		            "actions": [
		                {
		                    "set": "message.headers.X-Require-Whisk-Auth",
		                    "value": "hIadvQ8w4nkJeWa3i7OPDb9WqTAUV9d6"
		                }
		            ]
		        }
		    }
		],
		"operations": [
		    "getTenantsTenantidBatches"
		]
}
```

## Event Streams Issues

### SSL Certificate Issues
**Issue:** when attempting to connect to [Event Streams](glossary.md#event-streams) you receive SSL errors. In Java, you might get this exception `sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target`. With curl, you get this error `SSL Certificate: Invalid certificate chain`.  

**Cause:** the Enterprise Event Streams brokers use a certificate signed by` issuer=C = US, O = Let’s Encrypt, CN = Let’s Encrypt Authority X3`  which is different from Standard versions. Whatever client is connecting to Event Streams is missing the Let's Encrypt public certificate. For Java, this certificate was added in version `8u101`.  

**Fix:** add the Let's Encrypt public certificate to your trusted root certificates. This varies depending on what technology you are using. Java comes with its own 'truststore' with root certificates and all operating systems also store root certificates. The Let's Encrypt certificates can be downloaded [here](https://letsencrypt.org/certificates/). There are several guides online for adding certificates to the Java trust store. Here's [one](https://docs.oracle.com/javase/tutorial/security/toolsign/rstep2.html) from Oracle. Here is a [guide](https://bounca.org/tutorials/install_root_certificate.html) for several operating systems.

## Elasticsearch

### Setup Curl with IBM Elasticsearch
Below are instructions for setting up Curl to interact with the Elasticsearch API directly. This can be useful when investigating issues or in some update scenarios like modifying existing index templates.

  1. Note: this requires the use of the [command-line cURL](https://github.com/curl/curl) tool
  2. In your IBM Cloud [Elasticsearch (Document Store)](glossary.md#elasticsearch) account, you will need to have either:
      * an existing Service Credential you can access  OR
      * create a new Service Credential that you will use below for the `$USERNAME` and  `$PASSWORD` needed to run the Elasticsearch REST commands
    
To create a new Service Credential:

 Navigate to the Elasticsearch service instance in your [IBM Cloud account](https://cloud.ibm.com/login). Then click on the "Service Credentials" link on the left-hand side Elasticsearch service menu:
  
   ![doc-store-svc-creds](images/doc_store_svc_creds.jpg)
  
 On the Service Credentials page click the New Credential button:
  
   ![doc-store-new-cred](images/doc_store_new_cred.jpg)
    
 You will name your new credential and click the "Add" button. After that, your credential will be generated for you and you will be able to click on the "View Credentials" link. From this expanded service credentials window, you may retrieve your newly created Elasticsearch Username and Password that you will need for the Elasticsearch REST commands using cURL.  
    
Next, you will need to download the certificate and export it, so cURL can authenticate with the IBM Cloud Elasticsearch instance. To do this:
  
  Navigate to the Management screen for your Elasticsearch instance, which will look something like this (ID field obscured in the ScreenCap for security):
  
  ![doc-store-manage](images/doc_store_manage.jpg)
  
  Scroll down your screen, and in the "Connections" panel, click on the "CLI" toggle. You will be using cURL to run commands from your local environment on the IBM Cloud Elasticsearch instance. See this page in the IBM Cloud Documentation for more info on [Connecting to Elasticsearch with cURL](https://cloud.ibm.com/docs/services/databases-for-elasticsearch?topic=databases-for-elasticsearch-connecting-curl).
  
  ![doc-store-conns-1](images/doc_store_conns_1.png) 
  
  In the "Connections" panel, there is a section for _TLS Certificate_. You will want to save the text from the "Contents" panel in that TLS Certificate section to a local file such as: 
      
    /Users/[yourLocalUserName]/certs/hri-documentstore.crt 
  
  Use the contents of this file with cURL by exporting it to `CURL_CA_BUNDLE`. 
      
    export CURL_CA_BUNDLE=/local-path/to/file/hri-documentstore.crt
          
  Find the base url in the "Public CLI endpoint" textbox. In this example it starts with `https://8165307`:
  
  ![doc-store-conns-2](images/doc_store_conns_2.jpg)
  
  You can now interact with the Elasticsearch REST API using cURL. For example, you can get the status of the cluster by performing a `GET` on the `_cluster/health?pretty` endpoint.
      
    curl -X GET -u <username>:<password> \
      https://8165307e-6130-4581-942d-20fcfc4e795d.bkvfvtld0lmh0umkfi70.databases.appdomain.cloud:30600/_cluster/health?pretty
  
  You can get the default index template by performing a `GET` to the `_index_template/batches` endpoint. 
      
    curl -X GET -u <username>:<password> \
      https://8165307e-6130-4581-942d-20fcfc4e795d.bkvfvtld0lmh0umkfi70.databases.appdomain.cloud:30600/_index_template/batches

  You can also get the mapping for existing indexes (one per tenant) at `<index>/_mapping`.
        
    curl -X GET -u <username>:<password> \
      https://8165307e-6130-4581-942d-20fcfc4e795d.bkvfvtld0lmh0umkfi70.databases.appdomain.cloud:30600/test-batches/_mapping

### Upgrade Existing Elasticsearch Indices
Follow the steps to [setup curl with IBM Elasticsearch](#setup-curl-with-ibm-elasticsearch). You will also need a set of credentials, Elasticsearch host and port, and the Elasticsearch certificate. These will be referenced in the following steps using `$USERNAME`, `$PASSWORD`, `$ELASTIC_HOST`, and `$ELASTIC_PORT`.

Download the `batches.json` index template from GitHub. The latest version can be found [here](https://github.com/Alvearie/hri-mgmt-api/blob/main/document-store/index-templates/batches.json). Make sure you switch the 'Branch' to the release tag for the version you are upgrading to. For example, [here](https://github.com/Alvearie/hri-mgmt-api/blob/v2.1-2.1.5/document-store/index-templates/batches.json) is the template for the `v2.1-2.1.5` release. 

The downloaded `batches.json` index template needs to be updated to only include the mapping properties. Remove lines 2-7 of the file which should include the `index_patterns`, `settings`, `mapping`, and `batch` fields. Next remove the 2nd and 3rd to last `}`'s at the end of the file. The file should now just contain a the `properties` field with a list of field names. It should look like:
	
```json
{
	"properties" : {
		"name": {
		 	"type": "keyword"
		},
		...
		"metadata": {
			"type": "object",
			"enabled": "false"
		}
	}    
}
```
	
List all the Elasticsearch indices

```sh
curl -u $USERNAME:$PASSWORD https://$ELASTIC_HOST:$ELASTIC_PORT/_cat/indices/*-batches
```
        
For each index listed above, update its mapping using the command below replacing `<index>` with the name of the index.
	
```sh
curl -X POST -u $USERNAME:$PASSWORD \
https://$ELASTIC_HOST:$ELASTIC_PORT/<index>/_mapping \
-H 'Content-Type: application/json' \
-d '@batches.json'
```

### Upgrading Elasticsearch Versions
The process for upgrading Elasticsearch versions on the IBM Cloud is fairly straightforward. Below are the high level steps:

1. Create a new, higher version of Elasticsearch from an existing backup. See the IBM Cloud [documentation](https://cloud.ibm.com/docs/databases-for-elasticsearch?topic=databases-for-elasticsearch-upgrading) for more details. This will copy all your existing tenants and batches.
1. Enable firewall access to the new Elasticsearch instance from your Kubernetes cluster if using the public endpoint.
1. Deploy the new HRI version that supports the upgraded Elasticsearch. See deployment [documentation](deployment.md) for more details.

NOTE: During the upgrade process, the HRI Management API should not be used. Any changes after the Elasticsearch backup is created in step 1, will be lost.

This process may be prohibitively long for some solutions due to the amount of time required to change Kubernetes firewall rules. **Pre `v3.x`**, Elasticsearch can be _configured manually_ in order to temporarily skip the Kubernetes firewall changes _when validation is not enabled_. Replace step 2 above with the following:

1. Download the Elasticsearch template and setup script from GitHub. Ensure you select the release tag that matches your HRI version before downloading. The links below default to `support-2.x` branch versions.
    - [batches.json](https://github.com/Alvearie/hri-mgmt-api/blob/support-2.x/document-store/index-templates/batches.json) index template
    - [elastic.sh](https://github.com/Alvearie/hri-mgmt-api/blob/support-2.x/docker/elastic.sh) setup script
1. Open a IBM Cloud shell: [https://cloud.ibm.com/shell](https://cloud.ibm.com/shell)
1. Upload the index template and setup script downloaded from step 1
1. Change `elastic.sh` to be executable: `chmod +x elastic.sh`
1. Set `ELASTIC_INSTANCE` to the name of your new Elasticsearch instance: `export ELASTIC_INSTANCE=<instance name>`
1. Set `ELASTIC_SVC_ACCOUNT` to the name of your Elasticsearch service credential: `export ELASTIC_SVC_ACCOUNT=<service credential name>`
1. Run the `elastic.sh` script. Below is an example:

        $ ./elastic.sh 
        Looking up Elasticsearch connection information and credentials
        
        ES id: "crn:v1:bluemix:public:databases-for-elasticsearch:us-south:a/49f48a067ac4433a911740653049e83d:81ce8a78-d119-4ef0-a65a-9b4ba741d52d::"
        
        ES baseUrl: https://81ce8a78-d119-4ef0-a65a-9b4ba741d52d.c00no9sd0hobi6kj68i0.databases.appdomain.cloud:31798
        
        Setting Elasticsearch auto index creation to false
        {"acknowledged":true,"persistent":{"action":{"auto_create_index":"false"}},"transient":{}}
        Setting Elasticsearch Batches index template
        {"acknowledged":true}
        Elasticsearch configuration complete

Then proceed with deploying the new HRI version. The deployment scripts will still try to configure Elasticsearch and report a failure for the smoke test, but the new Management API will still be deployed and function correctly. You can verify this by ensuring the `/hri/healthcheck` endpoint returns a `200`. You should still enable firewall access to the new Elasticsearch instance for future deploys.

### Migrating to another Elasticsearch Instance
The IBM Cloud does not provide an automated process for migrating an Elasticsearch instance to another account, but it can be done manually using Elasticsearch's snapshot and restore functionality with the S3 plugin. These enable creating a snapshot of an Elasticsearch instance, storing it in a COS bucket, and then restoring the snapshot to a different Elasticsearch instance. The migration should be performed after installing the HRI in the target account. 

**Note**: this does require _downtime for the HRI application_. The steps are detailed below. 

1. In the new account, create a COS bucket to store the Elasticsearch snapshots and a set of HMAC credentials with read and write access. Use the standard storage class, and if the destination Elasticsearch instance is in a different region than the source Elasticsearch instance, _ensure you select_ '**Cross Region**' resiliency.

1. Create the new Elasticsearch instance that you want to migrate to. This will be referred to as the "destination instance". If desired, you can also upgrade to the next major Elasticsearch version. You _cannot upgrade_ more than one major version.

1. Setup curl to communicate with the source Elasticsearch instance. See the [instructions](#setup-curl-with-ibm-elasticsearch) above for more details. The examples below will use `SRC` and `DEST` prefixes on environment variables to differentiate between the source and destination Elasticsearch connection parameters, e.g. `$SRC_USERNAME`, `$SRC_PASSWORD`, `$SRC_HOST`, and `$SRC_PORT`.

1. Register the COS bucket from step 1 with the source Elasticsearch instance using the curl statement below. You will need to fill in the bucket name, endpoint, and HMAC credentials. We recommend using the private endpoint.

        curl -X POST -u $SRC_USERNAME:$SRC_PASSWORD https://$SRC_HOST:$SRC_PORT/_snapshot/migration \
        -H 'Content-Type: application/json' -d'
        {
          "type": "s3",
          "settings": {
            "endpoint": "s3.private.us.cloud-object-storage.appdomain.cloud",
            "bucket": "bucket_name",
            "access_key": "xxxxx",
            "secret_key": "xxxxx"
          }
        }'

1. Repeat the prior two steps with the destination Elasticsearch instance. You may want to setup curl in a different terminal as you will need to run commands against both instances. When registering the COS bucket, add `"readonly": true`. Below is an example.

        curl -X POST -u $DEST_USERNAME:$DEST_PASSWORD https://$DEST_HOST:$DEST_PORT/_snapshot/migration \
        -H 'Content-Type: application/json' -d'
        {
          "type": "s3",
          "settings": {
            "readonly": true,
            "endpoint": "s3.private.us.cloud-object-storage.appdomain.cloud",
            "bucket": "bucket_name",
            "access_key": "xxxxx",
            "secret_key": "xxxxx"
          }
        }'

1. Get a list of the indices that need to be migrated. 

        curl -X GET -u $SRC_USERNAME:$SRC_PASSWORD https://$SRC_HOST:$SRC_PORT/_cat/indices/*-batches

1. At this point you **must stop** operational use of the source HRI/Elasticsearch instance. Create a snapshot using the curl statement below. The example below uses `backup-2021-04-23`, but you can use any name for the snapshot. 

        curl -X PUT -u $SRC_USERNAME:$SRC_PASSWORD "https://$SRC_HOST:$SRC_PORT/_snapshot/migration/backup-2021-04-23?wait_for_completion=true" \
        -H 'Content-Type: application/json' -d '{"include_global_state": false}'

1. Restore the snapshot on the destination Elasticsearch instance. You must list the indices that need to be restored (see step 6), because the snapshot includes an authorization index that cannot be overwritten. 

        curl -X POST -u $DEST_USERNAME:$DEST_PASSWORD "https://$DEST_HOST:$DEST_PORT/_snapshot/migration/backup-2021-04-23/_restore?wait_for_completion=true" \
        -H 'Content-Type: application/json' -d '{"include_global_state": false, "indices": "1234-batches,5678-batches"}'

1. You can list the indices to verify they were restored. They will be in a 'yellow' state until all the shards have been replicated.

        curl -X GET -u $DEST_USERNAME:$DEST_PASSWORD https://$DEST_HOST:$DEST_PORT/_cat/indices/*-batches

    In addition, each index has a `_recovery` endpoint that will list additional details about an ongoing restore. 

        curl -X GET -u $DEST_USERNAME:$DEST_PASSWORD https://$DEST_HOST:$DEST_PORT/1234-batches/_recovery?pretty

You can now begin using the HRI instance in the new account. If you also migrated to a new OIDC server (e.g. AppID), and want to preserve Data Integrators access to historical batches, see the next [section](#migrating-oidc-or-appid-instances) for additional steps required.

Additional resources:

* Here is an example [script](files/es-migration.sh) that can be a starting place for automating the Elasticsearch commands.
* Elasticsearch [snapshot and restore](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshot-restore.html) documentation

### Migrating OIDC or AppID instances
When migrating to a new OIDC server such as AppID steps are required to preserve Data Integrator access to historical batches.

The HRI prevents Data Integrators from accessing batches that they did not create. This prevents them from accessing information about other Data Integrator's batches or making modifications to them. This is implemented by taking the `sub` (subject) claim from the JWT OAuth access token and storing it in the `integratorId` field of each batch. When Data Integrators access the Management API, the data is filtered to batches where their `sub` claim matches the `integratorId` field. If the OIDC instance is changed, the `sub` claim will also likely change, which means they will not be able to access any of the batches they created using the prior OIDC instance. In AppID, the `sub` claim is equal to their client ID. Data Consumers are not affected by this, because their access is not filtered.

To fix this, the `integratorId` field will need to be updated on all batches from the source OIDC `sub` field to the new destination OIDC `sub` for all Data Integrators. This processes can be rather involved, so please reach out to the HRI development team if you need help creating the necessary Elasticsearch scripts for this update.

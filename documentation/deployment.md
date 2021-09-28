# HRI Dependencies Configuration/Setup

This section is intended to help guide you to configure the dependent services that HRI uses in your own (public/private) IBM Cloud account.

## Create Elasticsearch cloud resource

 HRI Requires an [Elasticsearch](glossary.md#elasticsearch) service deployment in your IBM Cloud account. Navigate to the **Resource List** in your Cloud account. Click the **Create resource** button in the top right corner. Enter "Elasticsearch" in the catalog search bar and then select the **Databases for Elasticsearch** tile.

 Select the appropriate **region** and then configure the resource by providing a **service name** and **resource group**  (Note: for all configuration examples below, the Resource Group is "YOUR_Resource_GRP"). 

 You will also need to specify the desired resource allocations for Elasticsearch. Depending on your expected usage, your values may differ, but the values shown below will be sufficient in most cases. Then click the **Create** button.

   ![elastic-configure](images/elastic_configure.png)

 Once the Elasticsearch instance becomes active, you will need to set an "admin" password. This is done from the **Settings** page of the Elasticsearch instance.

   ![elastic-admin-password](images/elastic_admin_password.png)

 Click the **Service credentials** link, and then click the **New credential** button. Provide a name for the service credential and then add it. This will be needed by the HRI Management API deployment.

   ![elastic-create-cred](images/elastic_create_cred.png)

## Create Event Streams cloud resource
 HRI also Requires an [Event Streams(Kafka)](glossary.md#event-streams) service deployment in your IBM Cloud account.

 Navigate to the Resource List in your Cloud account. If an instance of Event Streams already exists in your Cloud account, then the HRI may be able to share that existing instance. If an Event Streams instance does not already exist, then create one by clicking the **Create resource** button in the top right corner. Enter "Event Streams" in the catalog search bar and then select the **Event Streams** tile.

 Fill in an appropriate **region**, **service name**, and **resource group**. The **Enterprise** pricing plan (with custom key management via Key Protect) is required for HIPAA data processing. After creating an **Enterprise** instance of Event Streams, custom key management via Key Protect will need to be explicitly enabled (See [Event Streams documentation](https://cloud.ibm.com/docs/services/EventStreams?topic=eventstreams-managing_encryption#enabling_encryption)).

NOTE: The Event Streams Enterprise plan is expensive, which is why we recommend sharing an instance, if possible. In non-Production environments, a **Standard** plan may be used for testing with non-HIPAA data if your organization's security team approves.

   ![event-streams-configure](images/event_streams_configure.png)

 Click the **Service credentials** link, and then click the **New credential** button to create a service credential with **writer** permissions. Provide a name for the service credential. This will be needed by the HRI Management API deployment.

   ![event-streams-create-cred](images/event_streams_create_cred.png)

## Create Authorization Service
The HRI Management API requires an authorization service. Integration testing has been performed with [IBM Cloud App ID](https://www.ibm.com/cloud/app-id), but any compliant service can be used. See [Authorization](auth.md) for more details about the requirements and how to set up an App ID cloud service.

## Deploy the HRI Management API to IBM Functions
The Management API is designed to run on [IBM Functions](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-about) and can be deployed using the IBM Cloud CLI Functions plug-in. The [deploy.sh](https://github.com/Alvearie/hri-mgmt-api/blob/support-2.x/deploy.sh) script automates the process by creating an IBM Functions namespace, deploying the code and API, setting configuration values, and binding Elasticsearch and Event Streams service credentials. There are also scripts for configuring Elasticsearch, [elastic.sh](https://github.com/Alvearie/hri-mgmt-api/blob/support-2.x/docker/elastic.sh), and performing initial configurations of App ID, [appid.sh](https://github.com/Alvearie/hri-mgmt-api/blob/support-2.x/docker/appid.sh). These scripts are packaged into a docker container with the compiled code to support automated deployments and are available on [GitHub](https://github.com/Alvearie/hri-mgmt-api/pkgs/container/hri-mgmt-api%2Fmgmt-api-deploy). Below is a table of the environment variables used by the scripts.

|  Name     | Description         |
|-----------|---------------------|
| IBM_CLOUD_API_KEY   | The API key for IBM Cloud |
| IBM_CLOUD_REGION    | Target IBM Cloud Region, e.g. 'ibm:yp:us-south' |
| RESOURCE_GROUP      | Target IBM Cloud Resource Group |
| NAMESPACE           | Target IBM Functions namespace |
| ELASTIC_INSTANCE    | Name of Elasticsearch instance |
| ELASTIC_SVC_ACCOUNT | Name of Elasticsearch service ID |
| KAFKA_INSTANCE      | Name of Event Streams (Kafka) instance |
| KAFKA_SVC_ACCOUNT   | Name of Event Streams (Kafka) service ID |
| VALIDATION          | Whether to deploy the Management API with Validation, e.g. 'true', 'false' |
| OIDC_ISSUER         | The base URL of the OIDC issuer to use for OAuth authentication (e.g. `https://us-south.appid.cloud.ibm.com/oauth/v4/<tenantId>`)               |
| APPID_PREFIX        | (Optional) Prefix string to append to the AppId applications and roles created during deployment                                                |
| SET_UP_APPID        | (Optional) defaults to true. Set to false if you do not want the App ID set-up enabled. |

## Validation Processing
Validation processing is an optional feature that validates the data as it flows through the HRI. See [Validation](validation.md) for details on the validation performed and customization options. See [Processing Flows](processflow.md) for details on how it fits into the overall architecture. 

Validation processing is built on [Apache Flink](https://flink.apache.org/), a highly available stateful stream processing framework, and requires a 'Session' cluster when enabled. See their deployment [documentation](https://ci.apache.org/projects/flink/flink-docs-release-1.10/ops/deployment/kubernetes.html) for details on how to deploy a cluster. See the [Administration](admin.md) page for details about how to deploy validation jobs.

***

## What's Next
To set up your first [Tenant](glossary.md#tenant) and [Data Integrator](glossary.md#data-integrator) go to the [Administration](admin.md) page. 

For detailed info on how the concept of Tenants and the Data Integrator role underpin the HRI Multitenancy approach, see the [Multitenancy](multitenancy.md) page.

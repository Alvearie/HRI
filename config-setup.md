# HRI Dependencies Configuration/Setup

This section is intended to help guide you to configure the dependent services that HRI uses in your own (public/private) IBM Cloud account.

HRI Dependency Configuration consists of the following tasks:
  1. [Create Elasticsearch cloud resource](#create-elasticsearch-cloud-resource)
  2. [Create Event Streams cloud resource](#create-event-streams-cloud-resource)

## Create Elasticsearch cloud resource

 HRI Requires an [Elasticsearch](glossary.md#elasticsearch) service deployment in your IBM Cloud account. Navigate to the **Resource List** in your Cloud account. Click the **Create resource** button in the top right corner. Enter "Elasticsearch" in the catalog search bar and then select the **Databases for Elasticsearch** tile.

 Select the appropriate **region** and then configure the resource by providing a **service name** and **resource group**  (Note: for all configuration examples below, the Resource Group is "YOUR_Resource_GRP"). 

 You will also need to specify the desired resource allocations for Elasticsearch. Depending on your expected usage, your values may differ, but the values shown below will be sufficient in most cases. Make note of the **service name** since you may need to use the *ELASTIC_INSTANCE* parameter in your deployment process. Then click the **Create** button.

   ![elastic-configure](assets/img/elastic_configure.png)

 Once the Elasticsearch instance becomes active, you will need to set an "admin" password. This is done from the **Settings** page of the Elasticsearch instance.

   ![elastic-admin-password](assets/img/elastic_admin_password.png)

 Click the **Service credentials** link, and then click the **New credential** button. Provide a name for the service credential and then add it. Make note of this name because you may need to use the *ELASTIC_SVC_ACCOUNT* parameter as part of your deployment process.

   ![elastic-create-cred](assets/img/elastic_create_cred.png)

## Create Event Streams cloud resource
 HRI also Requires an [Event Streams(Kafka)](glossary.md#event-streams) service deployment in your IBM Cloud account.

 Navigate to the Resource List in your Cloud account. If an instance of Event Streams already exists in your Cloud account, then the HRI may be able to share that existing instance. If an Event Streams instance does not already exist, then create one by clicking the **Create resource** button in the top right corner. Enter "Event Streams" in the catalog search bar and then select the **Event Streams** tile.

 Fill in an approriate **region**, **service name**, and **resource group**. The **Enterprise** pricing plan (with custom key management via Key Protect) is required for HIPAA data processing. After creating an **Enterprise** instance of Event Streams, custom key management via Key Protect will need to be explicitly enabled (See [Event Streams documentation](https://cloud.ibm.com/docs/services/EventStreams?topic=eventstreams-managing_encryption#enabling_encryption)).

Make note of the **service name** because you may need to use this *EVENT_STREAMS_INSTANCE* parameter as part of your deployment process. Then click the **Create** button.

   ![event-streams-configure](assets/img/event_streams_configure.png)

 Click the **Service credentials** link, and then click the **New credential** button to create a service credential with **writer** permissions. Provide a name for the service credential and then add it. Make note of this name because you may need this *EVENT_STREAMS_SVC_ACCOUNT* parameter as part of your deployment process.

   ![event-streams-create-cred](assets/img/event_streams_create_cred.png)


***
Please **Note**: you will need to create and develop your own deployment process/scripts for the Management API that deploys it successfully to your [IBM Cloud Functions](glossary.md#ibm-cloud-functions) instance. The IBM Watson Health team created a custom Travis CI job to enable their deployments. 

---
## What's Next
To set up your first [Tenant](glossary.md#tenant) and [Data Integrator](glossary.md#data-integrator) go to the [Administration](admin.md) page. 

For detailed info on how the concept of Tenants and the Data Integrator role underpin the HRI Multitenancy approach, see the [Multitenancy](multitenancy.md) page.

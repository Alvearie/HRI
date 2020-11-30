# Multi-tenancy

The Health Record Ingestion service supports the concept of [**multi-tenancy**](glossary.md#multitenancy), for multiple [tenants](glossary.md#tenant). 

In the Health Record Ingestion service, data is isolated between [**Data Integrators**](glossary.md#data-integrator), that is, the organizations that supply health data on behalf of one or more tenants. 

Customer organizations create **Data Consumers**, which are downstream processes that read data from the Health Record Ingestion service. The latter is designed so that a single data consumer reads data for a single tenant. However, this does not prevent a consumer from reading data for multiple tenants. Data Consumers **can see data provided by all Data Integrators**. 

**Figure 1: Core architecture, multi-tenancy and the Health Record Ingestion service**

![core-architecture](assets/img/multitenancy.png)

Figure 1 shows the color-coded flow of two different tenants through the Health Record Ingestion service: 

- The **red color** indicates Tenant 1's data. 
- The **blue color** indicates Tenant 2's data. 
- Data Integrator B is both red and blue, because it processes data for both tenants.

**Note:** Currently, the Management API uses IBM&reg; Functions API keys for authentication. For more information, see [Setting up Management API keys](admin.md#hri-management-api-keys). 

#### Event Streams topics
In Event Streams, there must be at least one topic for every tenant and Data Integrator. To facilitate this, topics are named using the tenant and Data Integrator's name. Example: **ingest.tenant.data-integrator**

In Figure 1, Integrator B is processing data from two tenants and writes data to two topics, separating them by tenant. Event Streams credentials provided to Data Integrators are restricted to specific topics. For more information, see [Creating service credentials for Kafka permissions](admin.md#creating-service-credentials-for-kafka-permissions).

#### Data types
The Health Record Ingestion service is agnostic to the type of data being written to Kafka. In practice, a Data Integrator often provides a specific type of data, for example, claims data, clinical data, and imagery data, to the Health Record Ingestion service. Users and consumers of the Health Record Ingestion service might also want separate provided data by type. To do this, create additional topics and include another (data type) identifier at the end of the topic name before `.in`. Example: **ingest.t1.di1.claims.in**

**Note:** Inbound topics must end with **.in**.

#### Management API
In the Health Record Ingestion service, the Management API also stores metadata about batches in separate indexes, in its Elasticsearch data store. All API endpoints include a tenant ID to support data segregation by tenant. 
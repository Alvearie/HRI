# Multi-Tenancy

### Tenants
The HRI supports the concept of multiple tenants. See the respective glossary page entries for more details on [Tenants](glossary.md#tenant) and [Multi-Tenancy](glossary.md#multitenancy). 

### Data Integrators
Additionally, data is isolated between Data Integrators. A [**Data Integrator** is the organization](glossary.md#data-integrator) supplying the Health data on behalf of one or more tenants. 

### Data Consumers
**Data Consumers** are downstream processes (created by some "customer" org) that read data from the HRI. The HRI is designed so that a single data consumer would read data for a single tenant, but it does not prevent a consumer from reading data for multiple tenants. Data Consumers _can see data provided by all Data Integrators_. 

---
![core-architecture](assets/img/multitenancy.png)

**Note:** currently the Management API uses IBM Functions API keys for authentication, see [HRI Management API Keys](admin.md#hri-management-api-keys) for more details. 

This diagrams shows the flow of two different tenant's through the HRI via coloring. Red indicates Tenant 1's data and blue indicates Tenant 2's data. Data Integrator B is both red and blue, because it's processing data for both tenants.

#### Event Streams Topics
In Event Streams, there must be at least one topic for every tenant and and Data Integrator. To facilitate this, topics are named using the tenant and Data Integrator's name, e.g. `ingest.tenant.data-integrator.*`. 

In the example above, Integrator B is processing data from two tenants and writes data to two topics, separating them by tenant. Event Streams credentials provided to Data Integrators are restricted to specific topics. See [Creating Service Credentials for Kafka Permissions](admin.md#creating-service-credentials-for-kafka-permissions) for more details.

##### Data Types
HRI is agnostic to the type of data being written to Kafka. In practice, a Data Integrator often provides a specific type of data (claims, clinical, imagery, etc.) to the HRI. Users/Consumers of HRI also may want separate provided data by type. This can be done by creating additional topics and including another (data type) identifier at the end of the topic name before `.in`.  For example, `ingest.t1.di1.claims.in`. Note that _Inbound topics must end with `.in`_.

#### Managment API
The Management API also stores metadata about batches in separate indexes (in its ElasticSearch data store). All API endpoints include a tenant id to support data segregation by tenant. 
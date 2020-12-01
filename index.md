# Introduction

The **[Health Record Ingestion service](glossary.md#health-record-ingestion-hri)** is a deployment-ready service for streaming healthcare-related data into the cloud. It provides a "front door" for [Data Integrators](glossary.md#data-integrator) to send data into the IBM&reg; Cloud, while supporting both batch processing and data streaming workflows. It provides features to initiate and track the movement of a dataset into the IBM Cloud for both Data Integrators and [Data Consumers](glossary.md#data-consumer). 

## Key features

- **Streaming:** All data is streamed.
- **Batch support:** A collection of health data records can be streamed and processed together.
- **Multi-tenancy:** Supports segregation of data by [tenant](glossary.md#tenant) and Data Integrator

## Key technologies

- [**Event Streams**](glossary.md#event-streams): This is an IBM Cloud-based [Apache Kafka](https://kafka.apache.org/) managed service, the technology used for producing and consuming the data streams.
- [**IBM Cloud Functions**](glossary.md#ibm-cloud-functions): Using these, the Health Record Ingestion service exposes a serverless RESTful Management API that is used to control and configure the system. 
- [**Elasticsearch**](glossary.md#elasticsearch): This is the distributed NoSQL data store that is used to store information about batches.

## IBM Cloud dependencies

The Health Record Ingestion service was developed on the IBM Cloud and currently does not support running on other public or private clouds. However, as part of Project Alvearie, the Health Record Ingestion service is being transitioned into an open source project, with a goal of supporting public and private cloud deployments. The latest version has been pushed to GitHub. The team continues to work on moving all development activities into the open, and making the Health Record Ingestion service support other clouds. For more information about future plans, see the [Roadmap](roadmap.md).   

## Core architecture


**Figure: Components of the Health Record Ingestion service**



![core-architecture](assets/img/architecture-core.png)




### Topics

Kafka (IBM Event Streams) stores streams of records in [topics](glossary.md#topic). Health data can include [Protected Health Information (PHI)](glossary.md#protected-health-information-phi). To meet data separability requirements, **there must be separate topics for each tenant and Data Integrator**. 

Additional topics may be created as desired. But, in general, Kafka performs better with a small number of large topics. For each (upstream) input topic, there is an associated (downstream) notification topic for [batch status notifications](https://github.com/Alvearie/hri-api-spec/tree/master/notifications/batchNotification.json)

### Batches

The data often has organizational requirements to be processed together as a dataset called a [batch](glossary.md#batch). Processing can occur with either a partial batch or an entire batch. For these reasons, the Health Record Ingestion service has been built with to support batch dataset processing. 

The Data Integrator determines how much data goes into a batch. The Management API provides support for starting, completing, terminating, and searching for batches. Any change to a batch results in a message being written to the associated notification topic in Kafka. 

### Data format

The Health Record Ingestion service does not impose any requirements on the format of the Health Data records written to Kafka. Note that there is a separate effort to define a common FHIR model for [Protected Health Information (PHI)](glossary.md#protected-health-information-phi) data. 

However, the Health Record Ingestion service **does require** that the `batch Id` be included in the record header. Data Integrators can include any number of additional custom header values that they want to pass to Data Consumers. For example, a custom header value might be something like `originating_producer_id`, an originating data producer (or org) ID value that might need to be communicated to the Data Consumers. 

## Learn more

Continue learning about the Health Record Ingestion service:

- [Processing flows](processflow.md)
- [API specification](apispec.md)
- [Multi-tenancy](multitenancy.md)
- [Dependencies](config-setup.md)
- [Administration](admin.md)
- [Monitoring, logging](monitorlog.md)
- [Troubleshooting](troubleshooting.md)
- [Glossary](glossary.md)
- [Roadmap](roadmap.md)

## Got questions?

Contact maintainers for the Health Record Ingestion service: 

- **David N. Perkins, Team Lead** [david.n.perkins@ibm.com](mailto:david.n.perkins@ibm.com)
- **Aram S. Openden, Maintainer** [aram.openden1@ibm.com](mailto:aram.openden1@ibm.com)

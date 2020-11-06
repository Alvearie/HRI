# Health Record Ingestion service

The HRI is a deployment ready service for streaming Health-related data into the cloud. It provides a "front door" for "Data Integrators" to send data into the IBM Cloud, while supporting both batch-processing and data streaming workflows. It provides features to initiate and track the movement of a dataset into the IBM cloud for both ["Data Integrators"](glossary.md#data-integrator) and ["Data Consumers"](glossary.md#data-consumer). 

The key features are:
- Streaming - all data is streamed
- Batch support - a collection of health data records can be streamed and processed together
- Multitenancy - supports segregation of data by tenant and Data Integrator

## Key Technologies
- [Event Streams](https://www.ibm.com/cloud/event-streams), an IBM Cloud-based [Apache Kafka](https://kafka.apache.org/) managed service, is the technology used for producing and consuming the data streams
- Using [IBM Cloud Functions](https://cloud.ibm.com/functions/learn/concepts), HRI exposes a Serverless RESTful Management API that is used to control and configure the system
- [ElasticSearch](https://github.com/elastic/elasticsearch) is the distributed NoSQL data store that is used to store information about batches

## IBM Cloud Dependencies  
The HRI was developed on the IBM cloud and currently does not support running on other public or private clouds. However, as a part of Alvearie, the HRI is being transitioned into an open source project, and the goal is to support public and private cloud deployments. The latest version has been pushed to GitHub, and the team continues to work on moving all development activities into the open and making the HRI support other clouds. Please see the [Roadmap](roadmap.md) for additional details.   

## Core Architecture
![core-architecture](assets/img/architecture-core.png)

### Topics
Health data, which may include [PHI](glossary.md#phi), is written to and read from the Kafka (IBM Event Streams) topics. There **_must be_** _separate topics for each tenant and Data Integrator_ in order to meet data separability requirements. 

Additional topics may be created as desired. But, in general, Kafka performs better with a small number of large topics. For each (upstream) input topic, there is an associated (downstream) notification topic for [batch status notifications](https://github.com/Alvearie/hri-api-spec/tree/master/notifications/batchNotification.json). 

### Batches
Health Record Datasets often have organizational requirements to be processed together "as a set" (partially or in their entirety) when moving the data into a new cloud instance. Hence, HRI has been built with support to process a dataset as a _Batch_. See [Batch](glossary.md#batch) for a detailed definition.  

How much data goes in a batch is really up to the Data Integrator. The Management API provides support for starting, completing, terminating, and searching for batches. Any change to a batch results in a message being written to the associated notification topic in Kafka. 

### Data Format
HRI does not impose any requirements on the format of the Health Data records written to Kafka. There is a separate effort to define a common FHIR model for PHI data. 

However, The HRI **does require** the `batch Id` to be in the record header. Data Integrators may include any number of additional custom header values that they wish to pass onto data consumers. An example of a custom header value might be something like `originating_producer_id`, an originating data producer (or org) id value that may need to be communicated to the data consumers. 

## Additional Reading
- [Processing Flows](processflow.md)
- [API specification](apispec.md)
- [Multi-tenancy](multitenancy.md)
- [Dependency Config](config-setup.md)
- [Administration](admin.md)
- Estimating Cost
- [Monitoring & Logging](monitorlog.md)
- [Troubleshooting](troubleshooting.md)
- [Glossary](glossary.md)
- [Roadmap](roadmap.md)

## Questions
Please contact our Maintainers for further questions: 
  * David N. Perkins, Team Lead: david.n.perkins@ibm.com
  * Aram S. Openden, Maintainer: aram.openden1@ibm.com

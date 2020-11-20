# Glossary

Learn these key terms and better understand the Health Record Ingestion service.

#### batch

A collection of Health Data records that must be processed **together** for that dataset to be ingested correctly into an IBM&reg; Cloud instance. Processing partial data causes problems. Similarly, if a processing error occurs with part of the data, the entire batch might need to be rejected.

#### batch ID

A unique identifier in Health Record Ingestion, referring to one specific batch

#### Data Consumer

A downstream service, process, or application receiving and further processing data passing through Health Record Ingestion. An example is an HRI Pipeline Adapter, based on NiFi, that persists data to Cloud Object Storage (COS). 

#### Data Integrator

An upstream service, process, or application that sends data into Health Record Ingestion for processing

#### Elasticsearch

Distributed, open-source document storage used to store various types of data. Health Record Ingestion uses Elasticsearch as its primary data store for metadata about batches. For more information, see [What is Elasticsearch?](https//www.elastic.co/what-is/elasticsearch)

#### Event Streams

On IBM Cloud, the [IBM Event Streams service](https://www.ibm.com/cloud/event-streams) is a managed service instance of [Apache Kafka](https://kafka.apache.org), customized to work with the IBM Cloud.

#### Health Record Ingestion, HRI

This service provides a "front door" for Data Integrators to send data into the IBM Cloud. By doing so, Data Integrators allow that data to be used by authorized applications that are part of that Cloud account. 

#### IBM Cloud Functions

A serverless, automatically-scaling RESTful application service framework in the IBM Cloud. For information, see [Getting started with IBM Cloud Functions](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-getting-started). 

#### Management API

Health Record Ingestion is designed as a RESTful service layer with an [OpenAPI 3.0](http://spec.openapis.org/oas/v3.0.3)-compliant REST API. The Management API is the external API layer for accessing all public Health Record Ingestion operations that handle batch, streams, and tenant management. 

#### multi-tenancy

With Health Record Ingestion, multi-tenancy is a software architecture pattern that allows multiple users or customers to use a single instance of a specific service. The service shares computing resources across those customers. For more information, see [Multi-Tenant](https://www.ibm.com/cloud/learn/multi-tenant) on IBM Cloud.  

#### Protected Health Information, PHI

A term defined by the Health Insurance Portability and Accountability Act (HIPAA) Law and Privacy Rule which provides that "covered entities" must protect certain sensitive personal information of patients and that patients have certain rights to that information. For more information, see [What is PHI?](https://www.hhs.gov/answers/hipaa/what-is-phi/index.html) and [Summary of the HIPAA Privacy Rule](https://www.hhs.gov/hipaa/for-professionals/privacy/laws-regulations/index.html) on [hhs.gov](https://www.hhs.gov/).

#### stream

A Health Record Ingestion stream represents the entire flow through the Health Record Ingestion service for a given tenant. A stream always has two Kafka topics associated with it: an \*\.in topic and a \*\.notification topic.

#### tenant

A tenant represents one customer or organization that is a "user" of the Health Record Ingestion service, on whose behalf a set of health data is processed. A tenant can be internal or external to the organization deploying Health Record Ingestion (for example, IBM® Watson Health&trade;). All data is isolated between tenants. 













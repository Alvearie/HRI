# HRI Glossary of Terms

A listing of key terms and phrases to help one's understanding of the Health Record Ingestion service.

#### Batch: 
  * A __Batch__ in an HRI context represents a **_collection of Health Data records that must be processed together_** in order for that dataset to be ingested correctly into a cloud-based solution. Only processing some of the data would result in a bad state for the data consumer. Likewise, if there is an error with processing part of the data, the entire **batch** may need to be rejected.
  
#### Batch ID: 
  * A unique identifier in HRI, referring to one specific batch. 

#### Data Consumer: 
  * A "downstream" service, process, or application receiving and further processing the data passing through the HRI. One such example might be an HRI Pipeline Adapter (based on NiFi) that persists data to COS (Cloud Object Storage). 

#### Data Integrator: 
  * An "upstream" service, process or application that "sends" data into the HRI for processing. 

#### Elasticsearch: 
  * A [distributed, open-source document store](https://www.elastic.co/what-is/elasticsearch) used to store various types of data. HRI uses Elasticsearch as its primary data store for metadata about batches. 
  
#### Event Streams: 
  * The IBM Cloud [Event Streams service](https://www.ibm.com/cloud/event-streams) is a "Managed" service instance of [Apache Kafka](https://kafka.apache.org) customized to work with the IBM Cloud.
  
#### HRI: 
  * The Health Record Ingestion service provides a "front door" for Data Integrators to send data into the cloud, thereby allowing that data to be used by authorized applications that are part of that cloud account.
  
#### HRI Management API: 
  * A RESTful service layer with an [OpenAPI 3.0](http://spec.openapis.org/oas/v3.0.3) compliant REST API. The "Management API" is the external API layer for accessing all public HRI operations that handle Batch, Streams, and Tenant management. 

#### Multitenancy: 
  * In the context of HRI, multitenancy is a software architecture pattern that allows multiple users or customers to use a single instance of a specific service, sharing computing resources across those customers. For reference, [see this link](https://www.ibm.com/cloud/learn/multi-tenant).  
  
#### PHI: 
  * Protected Health Information is a term defined by the HIPAA Law and Privacy Rule which provides that "covered entities" must protect certain sensitive personal information of patients and that patients have certain rights to that information. See [this page for HIPAA definition](https://www.hhs.gov/answers/hipaa/what-is-phi/index.html) and [this page](https://www.hhs.gov/hipaa/for-professionals/privacy/laws-regulations/index.html) for more in-depth info on HIPAA Privacy Rule and Protected Health Information.

#### Stream: 
  * An HRI Stream represents the entire flow through the HRI for a given tenant and Data Integrator. A Stream always has two kafka topics associated with it: an *.in* topic and a *.notification* topic.

#### Tenant: 
  * A tenant represents one customer or organization that is a "user" of HRI, on whose behalf a set of Health data is being processed. A tenant can be internal or external to the organization deploying HRI (e.g. IBM Watson Health). All data is isolated between tenants. 

#### Terraform:
 * [Terraform](https://www.terraform.io) is an infrastructure as code tool that can be used to set up a cloud environment for an HRI deployment.

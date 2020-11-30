# Roadmap
This topic lists additional Health Record Ingestion service features that are scheduled for development. 

## Planned features by priority

Note that plans and priorities are subject to change.

### 1. Management API authorization
Currently, the [batch](glossary.md#batch) endpoints for the Health Record Ingestion service [Management API](glossary.md#management-api) support authentication using [IBM&reg; Cloud Functions](glossary.md#ibm-cloud-functions) API keys, but do not support authorization. In other words, all clients can call any of the batch endpoints once they have an API key. This allows [Data Integrators](glossary.md#data-integrator) to see each others' batches, and even interfere with them. An example of such interference includes terminating another Data Integrator's batch.

**Goals for this planned feature**
<br>To provide a more secure solution, the Health Record Ingestion service team is developing role-based authorization. With this feature, Data Integrators will not be able to access any batches created by another Data Integrator. Data Integrators would be essentially invisible to each other. While [Data Consumers](glossary.md#data-consumer) will be able to access all batches, they cannot change the batches' state. The Consumers would essentially have read-only access. 

Development is in progress, using the [OAuth 2.0](https://oauth.net/2/), [OpenID Connect](https://openid.net/connect/), and [JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519) standards. Clients authenticate with the OAuth 2.0 authorization service using one of the standard flows to get a JWT access token. Then, clients include the access token in calls to the Management API, which will validate the token and use the standard scopes claim to determine if the client is authorized to perform the requested action. Additionally, the `sub` claim would be used to uniquely identify Data Integrators and filter results. 

### 2. Batch and record validation
Currently, data written to the `*.in` Kafka topics by [Data Integrators](glossary.md#data-integrator) is not validated in any way, requiring [Data Consumers](glossary.md#data-consumer) to handle many kinds of error scenarios, from malformed data to missing records. 

**Goals for this planned feature**
<br>We plan to develop a validation mechanism that would perform checks on every [batch](glossary.md#batch) and record. Every record's contents would be validated. Batches would be required to have the correct number of records and no malformed records. Since the Health Record Ingestion service does not stipulate the record format, the record validation will be modular, with a base implementation that can be extended for different types of data. 

Development is in progress, using [Apache Flink&reg;](https://flink.apache.org/). Every [stream](glossary.md#stream) will have a Flink job that reads from the `*.in` topic, validates the data, and writes to a new `*.out` topic. Data Consumers will read the result. Additionally, the Flink job will keep track of batches and mark each complete or failed based on validation results.

### 3. Cloud portability
The Health Record Ingestion service was developed on the IBM&reg; Cloud, and uses many of its features and services. As a result, the Health Record Ingestion service was not originally designed to be deployed to other public or private clouds. 

**Goals for this planned feature**
<br>This new feature would make the Health Record Ingestion service dependencies more generic, with the goal of making it deployable to any major public and private cloud. The Health Record Ingestion service team will use [Red Hat&reg; OpenShift&reg;](https://www.openshift.com/) as a standard platform, to which the Health Record Ingestion internal services will be ported. External service dependencies will be made more generic. For example, you will be able to use any [Apache Kafka](https://kafka.apache.org) service, instead of only the IBM [Event Streams](glossary.md#event-streams). 

### 4. Open source development
As a part of Project Alvearie, the Health Record Ingestion service is being transitioned into an open source project. An initial publish of `v0.3.0` has been completed, but development work continues using internal IBM resources. 

**Goals for this planned feature**
<br>The plan is to move all development processes into the open. This requires that the team rewrite continuous integration and continuous delivery (CI/CD) processes.

### 5. Archive and replay
Because the Health Record Ingestion service leverages [Apache Kafka](https://kafka.apache.org) through [Event Streams](glossary.md#event-streams), it has the capability to store and replay data over a short period of time. The amount of time is configurable, but it is not designed for longterm storage and replay. In addition, it does not support [batch](glossary.md#batch) semantics.

**Goals for this planned feature**
<br>The plan is to develop a longterm storage (archive) mechanism for batches. This mechanism could be selectively replayed at any time in the future. Replaying the data would stream it back through the Health Record Ingestion service, as if it were sent by a Data Integrator. By doing this, downstream services will be able to recover from processing errors, without requiring the Data Integrator to resend the data through the Health Record Ingestion service. In addition, it can serve as a record of the original data sent to the cloud for data lineage purposes. 

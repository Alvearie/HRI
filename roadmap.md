# Roadmap
Below are the additional features that are scheduled for development. They are ordered by priority, but the ordering may change in the future.

## 1. Management API Authorization
The HRI [Management API](glossary.md#management-api)'s [Batch](glossary.md#batch) endpoints currently support authentication using [IBM Cloud Functions](glossary.md#ibm-cloud-functions) API keys, but do not support authorization. In other words, all clients can call any of the Batch endpoints once they have an API key. This allows [Data Integrators](glossary.md#data-integrator) to see each other's batches and even interfere with them, for example terminating another Data Integrator's Batch.

In order to provide a more secure solution, the HRI team is developing role-based authorization. Once this feature is in place, Data Integrators would not be able to access any batches created by another Data Integrator. Data Integrators would be virtually invisible to each other. [Data Consumers](glossary.md#data-consumer) would be able to access all batches, but not change their state. They would essentially have read-only access. 

Development is in progress and the [OAuth 2.0](https://oauth.net/2/), [OIDC](https://openid.net/connect/), and [JWT](https://tools.ietf.org/html/rfc7519) standards are being used to implement this feature. Clients authenticate with the OAuth 2.0 authorization service using one of the standard flows to get a JWT access token. Clients then include the access token in calls to the Management API, which will validate the token and use the standard scopes claim to determine if the client is authorized to perform the requested action. Additionally, the `sub` claim would be used to uniquely identify Data Integrators and filter results. 

## 2. Batch and Record Validation
The data written to the `*.in` Kafka topics by [Data Integrators](glossary.md#data-integrator) is not validated in any way, requiring [Data Consumers](glossary.md#data-consumer) to handle many kinds of error scenarios from malformed data to missing records. 

The plan is to develop a validation mechanism that would perform checks on every [Batch](glossary.md#batch) and record. Every record's contents would be validated, and Batches would be required to have the correct number of records and no malformed records. Since the HRI does not stipulate the format of the records, the record validation will be modular with a base implementation that could be extended for different types of data. 

Development is in progress and [Apache Flink](https://flink.apache.org/) is being used to implement this feature. Every [Stream](glossary.md#stream) will have a Flink job that reads from the `*.in` topic, validates the data, and writes to a new `*.out` topic, from which Data Consumers will read. Additionally, the Flink job will keep track of batches and 'complete' or 'fail' them based on the validation results.

## 3. Cloud Portability
The HRI was developed on the IBM cloud and uses many of its features and services. It was not originally designed to be deployed to other public or private clouds. This new feature would make HRI's dependencies more generic, with the goal of making it deployable to any major public and private cloud. Red Hat [OpenShift](https://www.openshift.com/) will be used as a standard platform, to which HRI's internal services will be ported. External service dependencies will be made more generic; for example, being able to use any [Apache Kafka](https://kafka.apache.org) service instead of just IBM's [Event Streams](glossary.md#event-streams). 

## 4. Open Development
As a part of Alvearie, the HRI is being transitioned into an open source project. An initial publish of `v0.3.0` has been completed, but development continues to be done using internal IBM resources. The plan is to move all development processes into the open, which requires rewriting our CI/CD processes.

## 5. Archive & Replay
Because the HRI leverages [Apache Kafka](https://kafka.apache.org) through [Event Streams](glossary.md#event-streams), it has the capability to store and replay data over a short period of time. The amount of time is configurable, but it is not designed for long term storage and replay, and it does not support [Batch](glossary.md#batch) semantics.

The plan is to develop a long-term storage (archive) mechanism for batches, which could then be selectively replayed at any time in the future. Replaying the data would stream it back through the HRI as if it were sent by a Data Integrator. This would enable down stream services to recover from processing errors without requiring the Data Integrator to resend the data through the HRI. It can also serve as a record of the original data sent to the cloud for data lineage purposes. 

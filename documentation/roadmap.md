# Roadmap
Below are the additional features that are scheduled for development. They are ordered by priority, but the ordering may change in the future.

## 1. Azure Cloud Support
This includes the required changes to enable HRI to be functional on an MS Azure cloud instance. 

Red Hat [OpenShift](https://www.openshift.com/) will be used as a standard platform on which HRI's internal services will run. External service dependencies such as Elastic, Kafka, OAuth 2.0 implementation will target either a specific MS Azure services or a generic cross-cloud solution, based on what makes the most sense for future Azure deployments. 

## 2. Archive & Replay
Because the HRI leverages [Apache Kafka](https://kafka.apache.org), it has the capability to store and replay data over a short period of time. The amount of time is configurable, but it is not designed for long term storage and replay, and it does not support [Batch](glossary.md#batch) semantics.

The plan is to develop a **long-term storage (archive) mechanism** for batches, which could then be selectively replayed at any time in the future. Replaying the data would stream it back through the HRI as if it were sent by a Data Integrator. This would enable downstream services to recover from processing errors without requiring the Data Integrator to resend the data through the HRI. It can also serve as a record of the original data sent to the cloud for data lineage purposes. 

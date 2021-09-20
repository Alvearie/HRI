# Performance & Sizing
The key performance metric for the HRI is how much Health-related data can be streamed through the system, which is highly dependent on the [Apache Kafka](https://kafka.apache.org) instance being used by the HRI. In the IBM Cloud, this is typically [Event Streams](glossary.md#event-streams). Thus, our performance testing has focused on measuring the throughput of Event Streams and not other components like the HRI [Management API](glossary.md#hri-management-api) or [Elasticsearch](glossary.md#elasticsearch).

## Without Validation
If [validation](validation.md) is not enabled, then the throughput of Event Streams is the only factor. We decided not to test the throughput of Event Streams service, as it is already in the IBM Cloud [documentation](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-kafka_quotas). Additionally, the consumption rate is usually the limiting factor and mostly dependent on what processing is done to the data. For example, a [Data Consumer](glossary.md#data-consumer) that writes the records to a database or file storage system will typically be constrained by how fast it can write the data, not how fast it can read from Event Streams. Every solution will need to test and determine the throughput of their pipeline.

## With Validation
When validation is enabled, the Flink validation jobs copy the data from an input topic to an output topic as it validates the data. In summary, our tests revealed that the Flink jobs were able to process the data as fast as it could be written to Event Streams. 

The throughput varies per run between 10 - 18 records per second and 9 - 10 MB per second normalized by the number of Kafka partitions, using a 'standard' plan Event Streams instance.

### Testing Methodology

#### Test Data
We use a static set of Synthetic Mass records for performance testing our FHIR validation. The original dataset is available [here](https://synthea.mitre.org/downloads) (the "1K sample Synthetic Patient Records FHIR R4" download.) Records larger than 5 MB were removed and 'zstd' compression was enabled in order to prevent exceeding the 1 MB maximum message size imposed by Event Streams. Any invalid records were also removed. What remains is 1135 files totaling 1.02 GB stored in a COS bucket.

#### Test Performed
The performance test runs nightly and follows these basic steps.  

1. Download the test data and sorts it by filename
1. Start a batch
1. Write all the test data to the input topic
1. Read all the messages from the output topic
1. Wait for the Batch 'completed' notification in the notification topic
1. Compute the job throughput in records and megabytes per second using the batch start and end times

The test uses two partitions for the input and output topics, and a Flink job parallelism of two. The data is written by a Kubernetes job with two pods. Tests were run against a 'standard' plan Event Streams instance.
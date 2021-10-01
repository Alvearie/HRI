# Processing Flows

This diagram depicts the "happy-path" flow through the [HRI](glossary.md#hri)  for a single [batch](glossary.md#batch). 

![core-architecture](images/processflow.png)

### Steps
1. The [Data Integrator](glossary.md#data-integrator) creates a new batch.
2. The [Management API](glossary.md#hri-management-api) writes a batch notification message to the associated notification topic.
3. The [Data Consumer](glossary.md#data-consumer) receives the batch notification message.
4. Data Integrator writes the data to the correct Kafka `*.in` topic.
5. The Data Consumer _may now_ begin reading the data from the Kafka topic but can choose to wait until step 8 to begin reading the data.
6. The Data Integrator completes writing all data contained in this batch, and it then signals to the Management API that it completed sending the data for the batch.
7. The Management API writes a batch notification message to the associated notification topic.
8. The Data Consumer receives the batch notification message.

## Alternate Flows
### Batch Termination
If the Data Integrator encounters an error after creating a batch in step 2, they may send a request to the Management API to _terminate_ the batch. The Management API will then write a batch notification message to the associated notification topic, and the Consumer will receive it.

### Interleaved Batches
The HRI does not prevent the Data Integrator from writing multiples batches into the same topic at the same time. Every record will have a header value that specifies the ["batchId"](glossary.md#batch-id), which is returned from the Management API (see [api-spec/management-api/management.yml](https://github.com/Alvearie/hri-api-spec/blob/support-1.x/management-api/management.yml)), so the Consumer can distinguish each one. 

In practice, the Data Integrator may only write one batch at a time. As necessary, additional input topics can be created to prevent the interleaving of batches or data types. However, please note that, in general, **_Kafka performs better with a small number of large topics_**.

# HRI Releases

This page lists the releases with notes for the HRI with information about how to upgrade from one version to the next. If upgrading multiple versions, check the upgrade notes of all versions in between. Note that the HRI has an overall release number, which is included here. Individual components of the HRI use the overall major and minor release number as a prefix to their release number, in order to make it easy to identify which versions of components are compatible with each other. For example, `v2.1-2.1.5` of the [Management API](https://github.com/Alvearie/hri-mgmt-api) is compatible with `v2.1-1.0.1` of [Flink validation FHIR](https://github.com/Alvearie/hri-flink-validation-fhir), because they both have the `v2.1` prefix.

Unless stated otherwise in the release notes of a specific version, upgrading the HRI should be achievable without downtime. If you are only upgrading to a new patch version, simply upgrade your existing deployment with the patched version. Otherwise, the new version can be deployed and configured separately in a different namespace while the old HRI version is still active, and the old HRI version can be deleted when migration is complete. In this case, be sure to use the same Elasticsearch and Event Streams instances for both of the HRI versions. Again, please see the upgrade notes for all versions between your current and target versions for any additional requirements.

## v3.x
Version `3.x` is the latest version focused on making the HRI a cloud-portable service. The Management API was moved from IBM Functions to a standard REST Web server and is packaged into a docker image for Kubernetes based deployments.

### v3.1.0

#### Release notes
An HRI minor release using public GitHuB Alvearie resources. There were also the following changes:

**Management API**

- Switched Kafka client library to `confluent-kafka-go` in order to support other Kafka authentication methods. This also caused the configuration options to switch to a list of Kafka connection properties.
- Upgraded several dependencies

**Validation(Flink)**

- Upgraded to Flink `1.10.3`

#### Upgrading
This release does not contain breaking changes, but there are some changes to the Management API configuration properties. `-kafka-properties` takes a list of all connection properties. See https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md for the full list.

### v3.0.0

#### Release notes
Initial open source release of `v3.x`. This **major HRI release** ports the Management API from IBM Cloud Functions to a standard REST Web server and is packaged into a docker image for Kubernetes based deployments. This release supports the goal of making the HRI a cloud-portable service. 

#### Upgrading
This release does not contain breaking changes to the API specification, but there are steps required to migrate the Management API to a Kubernetes based deployment. The same IBM Cloud services (Elasticsearch, Event Streams, AppID, etc.) can be shared between a v2.x deployment and a new v3.x deployment. Below are the migration steps:

1. Deploy v3.0.0 to Kubernetes.
    1. The same namespace of an older deployment can be used.
    1. If using validation, also update the Flink and Zookeeper deployments. They are backwards compatible with v2.x.
    1. Use the same OIDC settings, so that existing configurations are used in the new Management API Kubernetes deployment.
1. If using validation, migrate existing Flink jobs to the latest validation job jars.
    1. Stop existing validation jobs with a savepoint.
    1. Restart each job from the savepoint using the latest validation job jar and change the Management API URL to the new Kubernetes deployment. All other parameters should remain the same.
1. Have Data Integrators and Consumers migrate from the old Management API (URL) to the new Kubernetes deployment endpoints.
1. When all clients have migrated, delete the IBM Functions namespace that held the old Management API.

## v2.x
Version `2.x` uses IBM Functions to deploy the Management API and includes validation processing. It is scheduled for deprecation in Q4 of 2022. Until then security updates and bug fixes will still be made, but no new features will be added. Please upgrade to the latest version at your earliest convenience.

### v2.1.5

#### Release notes
Initial open source release of `v2.x`.

#### Upgrading
This release **does not contain** breaking changes. Data Integrators and Consumers will maintain access to old batches. However, please note that there are changes to the Elasticsearch mapping template, which must be applied to all existing indices (one for every tenant). Below is a series of upgrade tasks. 

1. The Elasticsearch index mappings need to be updated to account for the new `expectedRecordCount`, `actualRecordCount`, `invalidThreshold`, and `invalidRecordCount` fields. `recordCount` is considered deprecated as of v2.0.0 and `expectedRecordCount` should be used instead.
2. Download the new index template from [GitHub](https://github.com/Alvearie/hri-mgmt-api/blob/v2.1-2.1.5/document-store/index-templates/batches.json)
3. Follow these [instructions](troubleshooting.md#upgrade-existing-elasticsearch-indices) to upgrade all the existing Elasticsearch indices with the `batch.json` index template downloaded in the prior step.

The `expectedRecordCount`, `actualRecordCount`, `invalidThreshold`, and `invalidRecordCount` fields have also been added to the [Batch API](apispec.md#batches) and [Notification Message](apispec.md#notification-messages) model, so Data Integrators and Consumers may need to update their integration tools to prevent parsing errors. Additional Batch Notification messages and `status` values have also been added. For more information, refer to the [Batch Status Transitions](processflow.md#batch-status-transitions) documentation.

## v1.x
Version `1.x` uses IBM Functions to deploy the Management API and does not include validation processing. It is scheduled for deprecation in Q2 of 2022. Until then security updates and bug fixes will still be made, but no new features will be added. Please upgrade to the latest version at your earliest convenience.

### v1.2.6

#### Release notes
First Alvearie release using new GitHub Actions workflow. There were no substantive changes to the API or deployed code.

### v1.2.5

#### Release notes
Initial open source release of `v1.x`.
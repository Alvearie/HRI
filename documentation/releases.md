# HRI Releases

This page lists the releases with notes for the HRI with information about how to upgrade from one version to the next. If upgrading multiple versions, check the upgrade notes of all versions in between. Note that the HRI has an overall release number, which is included here.

Unless stated otherwise in the release notes of a specific version, upgrading the HRI should be achievable without downtime. If you are only upgrading to a new patch version, simply upgrade your existing deployment with the patched version. Otherwise, the new version can be deployed and configured separately in a different namespace while the old HRI version is still active, and the old HRI version can be deleted when migration is complete. In this case, be sure to use the same Elasticsearch and Event Streams instances for both of the HRI versions. Again, please see the upgrade notes for all versions between your current and target versions for any additional requirements.

## v1.x
Version `1.x` uses IBM Functions to deploy the Management API and does not include validation processing. It is scheduled for deprecation in Q2 of 2022. Until then security updates and bug fixes will still be made, but no new features will be added. Please upgrade to the latest version at your earliest convenience.

### v1.2.6

#### Release notes
First Alvearie release using new GitHub Actions workflow. There were no substantive changes to the API or deployed code.

### v1.2.5

#### Release notes
Initial open source release of `v1.x`.
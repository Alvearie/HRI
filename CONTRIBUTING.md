# Guiding Principles for Contribution
First of all, thank you for taking the time to contribute! The HRI Team values your contribution. 

In general, contributions can be made using the standard fork and pull request process. We use the GitHub Flow branching model, so branch off of and submit the pull request back to the `main` branch. If updating an older release, submit a pull request against the associated `support-<major>.x` branch.

The GitHub actions may not run successfully in your forked repository without several secrets and external resources used for integration testing. You can ignore this and rely on the actions that will run in our repository when you create the pull request, but you should be able to run local unit tests to test your changes.

Once the pull request is reviewed and approved and all the integration tests pass, we will merge it and handle releasing the updates.

If making a significant contribution, please reach out to the development team's Slack channel, [#health-record-ingestion](https://alvearie.slack.com/archives/C01GM43LFJ6), so that we can coordinate the desired changes.


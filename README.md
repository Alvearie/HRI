# Health Record Ingestion service
The Alvearie Health Record Ingestion service is an open source project designed to serve as a “front door”, receiving health data for cloud-based solutions. This repo contains the [documentation](https://alvearie.github.io/HRI/) for the project.

See the list of source code repos here: https://github.com/Alvearie?q=hri

## Communication
* Please [join](https://alvearie.io/contributions/requestSlackAccess) our Slack channel for further questions: [#health-record-ingestion](https://alvearie.slack.com/archives/C01GM43LFJ6)
* Please see recent contributors or [maintainers](MAINTAINERS.md)

## Editing the documentation
Uses mkdocs https://www.mkdocs.org/. To add links modify `mkdocs.yml`.

### How to render locally
* Prerequisites:
  * Building the docs requires the `mkdocs`, `mkdocs-material`, and `pymdown-extensions` packages. 
  * Publishing the docs to GitHub Pages requires the `mike` package. (You can likely leave this step to the GitHub action builds, see [below](#how-to-publish-to-github-pages))
  * All of these can be installed with pip (ensure you are running python 3 at least) by running `pip install -r requirements.in`.

* From the base directory of the repo, run `mkdocs serve`.
* In your browser, go to the localhost address printed in the output of the `mkdocs serve` command.

### How to publish to GitHub pages
We use a tool called [mike](https://github.com/jimporter/mike) to publish multiple versions of our documentation from different branches of the docs repo. The `mike deploy` command helps us build the docs, give that build a tag (e.g. `v3.x`) and publish that version of the documentation to the GitHub pages of the repo. Generally, you should not need to run this locally, as automated GitHub actions builds keep our published docs up to date. It will automatically build and deploy any changes to the `main` and `support-*` branches. If for some reason you need to, or you want to experiment in a private repo, you can see the actions for how we use `mike`.

### Checks
The `refCheck.sh` script is included to detect bad references and orphaned images. Just run this script from the base directory. It will print out any images in the `documentation/images/` directory that are being referenced in the markdown files and any references in the markdown files to a file or image that do not exist.

### Diagrams
The diagrams are created with `draw.io`. You can download the app from GitHub: https://github.com/jgraph/drawio-desktop/releases/. All diagrams are png images with an embedded diagram, so they can be easily updated. To create a new one use File -> Export as -> PNG..., and select 'Include a copy of my diagram'. Save the images to `documentation/images`.

## Contribution Guide
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.


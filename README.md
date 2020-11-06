# Health Record Ingestion service
The IBM Watson Health, Health Record Ingestion service is an open source project designed to serve as a “front door”, receiving health data for cloud-based solutions. This repo contains the [documentation](https://alvearie.github.io/HRI/) for the project.

Other repos include:
- [Alvearie/hri-api-spec](https://github.com/Alvearie/hri-api-spec)
- [Alvearie/hri-mgmt-api](https://github.com/Alvearie/hri-mgmt-api)

## Communication
* Please TBD
* Please see [MAINTAINERS.md](MAINTAINERS.md)

## Editing the documentation
This repo uses Jekyll https://jekyllrb.com/docs/ with the Dinky theme. The default layout was modified to include a high-level page listing on the left. To add links modify `_data/siteindex.md`.

### How to render locally
* Prerequisites:
  * Requires Ruby 2.6.3 or higher
    * Check your Ruby version at cmd line: `$ ruby --version`
    * To upgrade your Ruby version go, follow [instructions here to install & run rvm ](https://codingpad.maryspad.com/2017/04/29/update-mac-os-x-to-the-current-version-of-ruby).
    * Your rvm command will be something like: `$ rvm install ruby-2.6.3`   
    * You may also need to run `gem update --system`.
    * If you are successful with that, continue onto running the bundler in the next step

* Run the bundler: `bundle install`
* Make the template think it's running in github pages by setting the env var: `export PAGES_REPO_NWO=wffh-hri/docs`
* Start up the Jekyll server: `bundle exec jekyll serve`
* In your browser, go to `localhost:4000`

**Note**: Several IDEs (like IntelliJ) are very good at rendering `.md` files, but it can be different from Jekyll's rendering. This is probably sufficient for minor changes and additions, but significant changes should be rendered locally.

### Diagrams
The diagrams are created with `draw.io`. You can download the app from github: https://github.com/jgraph/drawio-desktop/releases/. All diagrams are png images with an embedded diagram, so they can be easily updated. To create a new one use File -> Export as -> PNG..., and select 'Include a copy of my diagram'. Also select 'Transparent Background' and set the boarder width to `10`. Save the images to `assets/img`.

## Contribution Guide
Since we have not completely moved our development into the open yet, external contributions are limited. If you would like to make contributions, please create an issue detailing the change. We will work with you to get it merged in. 
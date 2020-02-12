# fb-submitter

[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-submitter/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-submitter/tree/master)

API for services built and deployed on Form Builder to send the user data to where it ultimately needs to go.

## Running tests

Docker is a prerequisite for running the tests

```sh
make spec
```

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to master tests are executed and if green deployed to the test environment.
This build can then be promoted to production

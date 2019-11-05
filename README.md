# fb-submitter

[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-submitter/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-submitter/tree/master)
[![Build Status](https://travis-ci.org/ministryofjustice/fb-submitter.svg?branch=master)](https://travis-ci.org/ministryofjustice/fb-submitter)

API for services built &amp; deployed on Form Builder to send the user data to
where it ultimately needs to go.

## Environment Variables

The following environment variables are either needed, or read if present:

- DATABASE_URL: used to connect to the database
- FB_ENVIRONMENT_SLUG: what FormBuilder environment is this submitter for?
  Should be equal to one of the keys in config/service_environments.rb
- RAILS_ENV: 'development' or 'production'
- SERVICE_TOKEN_CACHE_ROOT_URL: protocol + hostname of the
  [service token cache](https://github.com/ministryofjustice/fb-service-token-cache)
- NOTIFY_API_KEY: an API key for the [gov.uk notify service](https://docs.notifications.service.gov.uk/ruby.html#bapi-keys)

## To deploy and run on Cloud Platforms

See [deployment instructions](DEPLOY.md)

## Running tests

```
$ make spec
... docker-compose orchestrates the building of images ...
Creating fb-submitter_db_1 ... done

Randomized with seed 1551
...................................................................................................................................................................................

Finished in 4.59 seconds (files took 24.25 seconds to load)
179 examples, 0 failures

Randomized with seed 1551

Coverage report generated for RSpec to /app/coverage. 567 / 577 LOC (98.27%) covered.

COVERAGE:  98.27% -- 567/577 lines in 41 files

+----------+--------------------------------------------------+-------+--------+-----------+
| coverage | file                                             | lines | missed | missing   |
+----------+--------------------------------------------------+-------+--------+-----------+
|  75.00%  | app/services/adapters/mock_amazon_ses_adapter.rb | 4     | 1      | 4         |
|  78.57%  | app/models/concerns/has_status_via_job.rb        | 14    | 3      | 24-26     |
|  87.80%  | app/services/download_service.rb                 | 41    | 5      | 35-38, 45 |
|  96.30%  | app/controllers/concerns/jwt_authentication.rb   | 27    | 1      | 56        |
+----------+--------------------------------------------------+-------+--------+-----------+
37 file(s) with 100% coverage not shown
```

FROM ruby:2.6.3-alpine3.9

RUN apk add build-base postgresql-contrib postgresql-dev bash libcurl

RUN addgroup -g 1001 -S appgroup && \
  adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile* .ruby-version ./

ARG BUNDLE_FLAGS
RUN bundle install --no-cache ${BUNDLE_FLAGS}

COPY . .

ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem ./rds-combined-ca-bundle.pem

RUN chown -R 1001:appgroup /app

USER 1001

ARG RAILS_ENV=production
CMD bundle exec rake jobs:work

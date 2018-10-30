ARG BASE_IMAGE=aldavidson/fb-submitter-base
FROM $BASE_IMAGE

ARG RAILS_ENV=production
CMD bundle exec rake resque:work

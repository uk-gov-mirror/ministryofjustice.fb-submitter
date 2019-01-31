# Base image
ARG BASE_IMAGE=aldavidson/fb-submitter-base
FROM $BASE_IMAGE

# allow access to port 3000
ENV APP_PORT 3000
EXPOSE $APP_PORT

# run the rails server
ARG RAILS_ENV=production
CMD bundle exec rake db:migrate && bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0

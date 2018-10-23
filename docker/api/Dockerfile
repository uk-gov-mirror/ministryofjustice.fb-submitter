# Base image
FROM aldavidson/fb-submitter-base

# allow access to port 3000
ENV APP_PORT 3000
EXPOSE $APP_PORT

# run the rails server
ARG RAILS_ENV=production
CMD bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0

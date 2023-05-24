FROM ruby:3.2.2-alpine3.18

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

WORKDIR /usr/src/app

RUN apk update && apk add --virtual build-dependencies build-base \
 gcc \
 wget\
 git\
 tzdata

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install

#COPY . .

CMD tail -F anything
FROM ruby

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1
WORKDIR /usr/src/app

COPY . .
RUN bundle install
RUN bin/rails db:migrate
RUN ./bin/rails db:migrate db:seed

CMD ./bin/rails s
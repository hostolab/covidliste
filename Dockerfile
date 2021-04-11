FROM ruby:2.7.3-slim-buster

ENV RAILS_ENV=development

RUN apt update -y && \
    apt install -y  build-essential \
                    libpq-dev \
                    git \
                    python-pip \
                    python-dev \
                    nodejs \
                    npm

WORKDIR /usr/src

COPY . .

RUN sed -i 's|port ENV.fetch("PORT", 3000)|bind "tcp://0.0.0.0:#{ENV['PORT']\|\|3000}"|g' config/puma.rb

RUN gem install bundler:2.2.15

RUN npm i -g yarn

RUN bundle install

RUN yarn

RUN bin/lefthook install

RUN echo "LOCKBOX_MASTER_KEY=0000000000000000000000000000000000000000000000000000000000000000" > .env

ENTRYPOINT ["/usr/src/entrypoint.sh"]

CMD bin/rails s
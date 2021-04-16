ARG RUBY_VERSION=2.7.3

FROM ruby:$RUBY_VERSION-slim-buster

ARG NODE_MAJOR=12
ARG YARN_VERSION=1.22.5
ARG BUNDLER_VERSION=2.2.16

# Install build packages
ARG BUILD_PACKAGES="build-essential git build-essential curl libcurl3-dev libgit2-dev git cmake gnupg2 pkg-config python-pip python-dev"
RUN apt update -yqq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends $BUILD_PACKAGES \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && truncate -s 0 /var/log/*log

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -

# Add Yarn to the sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# Install required packages
ARG REQUIRED_PACKAGES="nodejs libpq-dev yarn=$YARN_VERSION-1"
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends $REQUIRED_PACKAGES \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && truncate -s 0 /var/log/*log

ENV INSTALL_PATH=/usr/src/app

WORKDIR $INSTALL_PATH

RUN mkdir -p $INSTALL_PATH/tmp
COPY Gemfile Gemfile.lock .ruby-version ./
RUN gem install bundler \
 && bundle config build.nokogiri --use-system-libraries \
 && bundle install -j "$(getconf _NPROCESSORS_ONLN)"

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . ./

ARG RUBY_VERSION=2.7.3

FROM ruby:$RUBY_VERSION-slim-buster

ARG NODE_MAJOR=12
ARG YARN_VERSION=1.22.5
ARG BUNDLER_VERSION=2.2.16

# Install build packages
ARG BUILD_PACKAGES="build-essential git build-essential curl libcurl3-dev libgit2-dev git cmake gnupg2 pkg-config python-pip python-dev unzip"
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

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
 && mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION \
 && curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
 && unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION \
 && rm /tmp/chromedriver_linux64.zip \
 && chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver \
 && ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# # Install chromedriver for test
# ENV CHROMEDRIVER_DIR=/chromedriver
# RUN apt-get update -qq \
#  && apt-get install -y gnupg wget curl unzip --no-install-recommends \
#  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
#  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
#  && apt-get update -yqq \
#  && apt-get install -yq google-chrome-stable \
#  && CHROMEVER=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") \
#  && DRIVERVER=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROMEVER") \
#  && mkdir -p $CHROMEDRIVER_DIR \
#  && wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$DRIVERVER/chromedriver_linux64.zip" \
#  && unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR \
#  && chmod +x $CHROMEDRIVER_DIR/chromedriver

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
COPY docker/config/database.yml ./config/database.yml

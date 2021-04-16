#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

cp docker/config/database.yml config/database.yml

bin/rails s -b 0.0.0.0
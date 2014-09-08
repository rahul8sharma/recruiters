#! /bin/bash
export PATH=$PATH:/usr/local/bin
export JRUBY_OPTS="$1"

bundle exec sidekiq -C config/sidekiq.yml -e $2

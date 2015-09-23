#!/bin/sh
while read -u9 VAR ; do export $VAR; done 9< .env # could go bigger w/fd# but that's not POSIX compliant
heroku run rake db:create db:migrate db:seed assets:precompile


#!/bin/sh
if [ "$1" = "" ] || [ $# -gt 1 ]; then
        echo "no application given"
        exit 0
fi
(while read VAR ; do heroku config:set --remote $1 $VAR; done ) < ../${1}.env
#heroku pg:reset -r $1
heroku run -r $1 rake db:migrate # db:seed

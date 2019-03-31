#!/bin/sh
(while read VAR ; do heroku config:set --remote $1 $VAR; done ) < .heroku_env
#heroku pg:reset -r $1
#heroku run -r $1 rake db:migrate db:seed

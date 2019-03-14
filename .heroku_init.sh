#!/bin/sh
(while read VAR ; do heroku config:set --app alias-madness-heroku-18 $VAR; done ) < .heroku_env
heroku pg:reset --app alias-madness-heroku-18 aliasmadness_production
heroku run --app alias-madness-heroku-18 rake db:migrate db:seed
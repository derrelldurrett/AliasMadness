# Alia's Madness (A pool manager for custom scoring systems)

A simple Rails/PostgreSQL/CoffeeScript application to allow the operator to manage
a March Madness type pool. It could be further modified to accept a matching set of
HTML and CSV describing the nodes and edges to be represented in the graph. TODOS
include writing a proper installation script, creating an audit trail, and the
aforementioned HTML/CSV generalizations. In theory, it should be easy to compute
the HTML from the CSV, but I haven't solved that yet.

* Rails/Ruby/CoffeeScript version: 7.0.4/3.2.2/2.4.1

* System dependencies: PostgreSQL 14 or better. An HTTP port that is addressable
by your pool's participants, and a host for the application.

* Configuration: A commonplace Rails application. See Rails documentation for how to
initialize the app locally for development and testing. See your ISP/host for
instructions on deploying a Rails/PostgreSQL applicatiion.

* Database creation: [https://www.postgresql.org/docs/9.5/install-short.html][Database Creation]

* Database initialization: There are two ENVs to provide for operation, 
`ALIASMADNESS_DB_USER` and `ALIASMADNESS_DB_PASSWORD`. Your runtime environment will
include a way to set them. Use that. Create the user locally for testing using
`createuser` as superuser `postgres`.

* How to run the test suite: The heart of the test suite is a complete set of 
Cucumber tests that attempt to completely exercise the application's major features.
In addition to the above-named ENV variables, the system expects the following to be 
set:
  - `ALIASMADNESS_ADMIN`
  - `ALIASMADNESS_PASSWORD`
  - `ALIASMADNESS_ADMINEMAIL`
  - `ALIASMADNESS_HOST`
  - `ALIASMADNESS_SERVEREMAIL`
  - `ALIASMADNESS_SENDGRID_API_KEY`

   To execute the test suite:
   - stop the existing `delayed_jobs` process,
   - reset the database via `rake db:reset`,
   - run `rake asset:precompile` (necessary to update the chat application),
   - truncate the log,
   - start `delayed_jobs`,
   - and finally run `cucumber features:all`. 
   
   The test suite expects Firefox to be installed. The features test the pages, and
   the entire application is tested from there.

* Services: `redis` (used for the chat feature), and `delayed_jobs` (used to calculate 
the "scenarios" available in the future - once a sufficient number of games have 
concluded, the result that will occur if a given set of teams win the remaining games
is computed).

* Deployment instructions: see the instructions for your provider of an internet
connection to the server. Heroku makes it possible to simply push new code to the Git
remote for your application.


[Database Creation]: https://www.postgresql.org/docs/9.5/install-short.html
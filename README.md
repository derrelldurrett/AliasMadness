# Alias Madness (A pool manager for custom scoring systems)

A simple Rails/PostgreSQL/CoffeeScript application to allow the operator to manage a March Madness type pool. It could 
be further modified to accept a matching set of HTML and CSV describing the nodes and edges to be represented in the 
graph. TODOS include writing a proper installation script, creating an audit trail, and the aforementioned HTML/CSV
generalizations. In theory, it should be easy to compute the HTML from the CSV, but I haven't solved that yet.

* Rails/Ruby/CoffeeScript version: 5.1.1/2.4.1/2.4.1

* System dependencies: PostgreSQL 9.5.14 or better. An HTTP port that is addressable by your pool's partipants (the 
author has used Heroku to satisfaction).

* Configuration: A commonplace Rails application. See Rails documentation for how to initialize the app locally for 
development and testing. See your ISP/host for instructions on deploying a Rails/PostgreSQL applicatiion.

* Database creation: [https://www.postgresql.org/docs/9.5/install-short.html][Database Creation]

* Database initialization: There are two ENVs to provide for operation, ALIASMADNESS_DB_USER and 
ALIASMADNESS_DB_PASSWORD. Your runtime environment will include a way to set them. Use that. Create the user locally for 
testing by `createuser` as superuser `postgres`.

* How to run the test suite: `cucumber features:all`. The test suite expects Firefox to be installed. The features test 
the pages, and the entire application is tested from there.

* Services: None

* Deployment instructions


[Database Creation]: https://www.postgresql.org/docs/9.5/install-short.html
# Developing

# Stack

- [Ruby on Rails](https://rubyonrails.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [React](https://reactjs.org/)
- [Stimulus](https://stimulus.hotwire.dev/)
- Bootstrap](https://getbootstrap.com/)


# Local Development

## Installation [Method 1] Docker and Docker Compose

These instructions are designed for setting up The Rails Port using [Docker](https://www.docker.com/). This will allow you to install the application and all its dependencies in Docker images and then run them in containers, almost with a single command. You will need to install Docker and docker-compose on your development machine:

- [Install Docker](https://docs.docker.com/install/)
- [Install Docker Compose](https://docs.docker.com/compose/install/)

#### Installation

To build local Docker images run from the root directory of the repository:

```bash
docker build --no-cache -f docker/dev.Dockerfile .
```

If this is your first time running or you have removed cache this will take some time to complete. Once the Docker images have finished building you can launch the images as containers.

To launch the app run:

```bash
docker-compose up -d
```

This will launch one Docker container for each 'service' specified in `docker-compose.yml` and run them in the background. There are two options for inspecting the logs of these running containers:

- You can tail logs of a running container with a command like this: `docker-compose logs -f` or `docker-compose logs -f web` or `docker-compose logs -f db`.
- Instead of running the containers in the background with the `-d` flag, you can launch the containers in the foreground with `docker-compose up`. The downside of this is that the logs of all the 'services' defined in `docker-compose.yml` will be intermingled. If you don't want this you can mix and match - for example, you can run the database in background with `docker-compose up -d db` and then run the Rails app in the foreground via `docker-compose up web`.

#### Migrations

Run the Rails database migrations:

```bash

docker-compose run --no-deps --rm web bin/rails db:migrate
```

#### Tests

Run the test suite by running:

```bash
docker-compose run -e "RAILS_ENV=test" --no-deps --rm web bash -c "bin/rails db:create db:migrate"
docker-compose run -e "RAILS_ENV=test" --no-deps --rm web bash -c "bin/rspec"
```

#### Bash

If you want to get into a web container and run specific commands you can fire up a throwaway container to run bash in via:

```bash
docker-compose run --rm web bash
```

Alternatively, if you want to use the already-running `web` container then you can `exec` into it via:

```bash
docker-compose exec web bash
```

Similarly, if you want to `exec` in the db container use:

```bash
docker-compose exec db bash
```

## Installation [Method 2] Manual setup on local host machine

#### Prerequisites

If you don't already have them :

- Install ruby 2.7.3 `rbenv install 2.7.3 && rbenv global 2.7.3`
- Install NodeJS (version 12, you may use [nvm](https://github.com/nvm-sh/nvm) if you have several versions)
- Install yarn `npm i -g yarn`

Install Redis and PostgreSQL:

- Using your favorite package manager (e.g. `brew install redis && brew install postgresql` on macOS).
- Using docker-compose (see "Docker" section below).

#### Dependencies

Setup the project's dependencies :

```bash
bin/setup
bin/lefthook install
```

This installs bundler, runs yarn and setup the database.

Create the `.env` file:

```bash
echo "LOCKBOX_MASTER_KEY=0000000000000000000000000000000000000000000000000000000000000000" > .env
```

#### Database / Cache

- Run the migrations : `bin/rails db:migrate RAILS_ENV=development`
- Run the db services according to your installation

#### Running

```bash
bin/rails s
```

If you need Sidekiq background workers or Webpacker development server, you can
start them all using [`overmind`](https://github.com/DarthSim/overmind)

```bash
overmind s
```

### Admin development

In a rails console with `rails c`

```ruby
user = User.find_by(email: <your_email>)
user.add_role(:admin)
# user.add_role(:super_admin) # for super admin
```

# Code formatting

In order for the pipeline to be successful, you must ensure that you respect
the linting made using

You can either install lefthook who automate multiple commands:

```bash
bin/lefthook install
```

Or manually:

```bash
bin/standardrb --fix
bin/yarn prettier --write .
```

Both these commands fix errors if possible. They will print errors if they
can't.

In rubymine, please follow this procedure to add the formatter / linter
directly in the editor tabs:
https://www.jetbrains.com/help/ruby/rubocop.html#prerequisites

# Testing

To launch the tests locally, run:

```bash
bin/rspec
# On macOS you can open Code Coverage results with:
# open coverage/index.html
```

If you want to debug System Tests in the browser, add the following Ruby line
as a debugger in your `spec/system/...` file:

```ruby
page.driver.debug(binding)
```

Then launch the test with:

```bash
INSPECTOR=true bin/rspec spec/system/THE_FILE_spec.rb
```

It should automatically open **Chrome** and allow you to inspect the DOM,
queries, etc. You can `next` and `continue` in the Terminal as if you had a
`binding.pry` debugging session.

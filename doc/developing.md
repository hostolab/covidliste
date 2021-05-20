# Developing

# Stack

- [Ruby on Rails](https://rubyonrails.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [React](https://reactjs.org/)
- [Stimulus](https://stimulus.hotwire.dev/)
- [Bootstrap](https://getbootstrap.com/)

# Local Development

## Prerequisites

If you don't already have them :

- Install ruby 2.7.3 `rbenv install 2.7.3 && rbenv global 2.7.3`
- Install NodeJS (version 12, you may use [nvm](https://github.com/nvm-sh/nvm) if you have several versions)
- Install yarn `npm i -g yarn`

## Install Redis and PostgreSQL:

### Using your favorite package manager

Install redis & postgresql directly on your machine, for example with
`brew install redis && brew install postgresql` on macOS.

### Using docker compose

If you don't want to install postgres & redis on your machine, or if you already have instances running that you don't want to use, you can install them through docker.

Launch redis & postgres :

```
docker compose up -d
```

Set the adequate env variables so that the application can find postgres & redis :

```
cat docker/dotenv.example >> .env
```

#### Dependencies

Setup the project's dependencies :

```bash
bin/setup
bin/lefthook install
```

This installs bundler, runs yarn and setup the database.

Create or append to the `.env` file:

```bash
echo "LOCKBOX_MASTER_KEY=0000000000000000000000000000000000000000000000000000000000000000" >> .env
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

### Data seed

To populate fake users

```ruby
rails populate:users
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

# Covidliste

[![Test](https://github.com/hostolab/covidliste/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/hostolab/covidliste/actions/workflows/test.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=hostolab_covidliste&metric=security_rating)](https://sonarcloud.io/dashboard?id=hostolab_covidliste)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=hostolab_covidliste&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=hostolab_covidliste)
[![codecov](https://codecov.io/gh/hostolab/covidliste/branch/master/graph/badge.svg?token=Z6SM94ONW9)](https://codecov.io/gh/hostolab/covidliste)

Covidliste makes it easy to manage waiting lists for vaccination centers.

[https://www.covidliste.com](https://www.covidliste.com)

<img src='https://www.pasteur.fr/sites/default/files/styles/media-wide/public/rubrique_linstitut_pasteur/notre_histoire/alexandre-yersin-institutpasteur_46576.jpg?itok=FL2T1kf4' width='200px'> </img>

# Stack

- [Ruby on Rails](https://rubyonrails.org/)
- [Stimulus](https://stimulus.hotwire.dev/)
- [Bootstrap](https://getbootstrap.com/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)

# Local Development

## Installation

### Prerequisites

If you don't already have them :

- Install ruby 2.7.3 `rbenv install 2.7.3 && rbenv global 2.7.3`
- Install NodeJS (version 12, you may use [nvm](https://github.com/nvm-sh/nvm) if you have several versions)
- Install yarn `npm i -g yarn`

Install Redis and PostgreSQL:

- Using your favorite package manager (e.g. `brew install redis && brew install postgresql` on macOS).
- Using docker-compose (see "Docker" section below).

### Dependencies

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

### Database / Cache

- Run the migrations : `bin/rails db:migrate RAILS_ENV=development`
- Run the db services according to your installation

### Running

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

## Documentation

A handbook is available [in the `doc` directory](doc/handbook.md).

## Docker

Launch the Docker environment:

```bash
docker-compose up -d
```

# Contributing

Visit https://github.com/hostolab/covidliste/blob/master/CONTRIBUTING.md

# Thanks to all our contributors

<a href="https://github.com/hostolab/covidliste/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=hostolab/covidliste" />
</a>

# Code formatting

In order for the pipeline to be successful, you must ensure that you respect
the linting made using

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

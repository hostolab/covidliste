# Covidliste

Covidliste makes it easy to manage waiting lists for vaccination centers.

[https://www.covidliste.com](https://www.covidliste.com)

<img src='https://www.pasteur.fr/sites/default/files/styles/media-wide/public/rubrique_linstitut_pasteur/notre_histoire/alexandre-yersin-institutpasteur_46576.jpg?itok=FL2T1kf4' width='200px'> </img>

# Stack

- Ruby on Rails
- Bootstrap
- Vanilla JS w/ Webpack
- PostgreSQL
- Redis (for Sidekiq & Caching)

# Local Development

## Dependencies

You need the following software installed:

- Ruby 2.7.2
- Node 10.17
- Yarn 1.22+
- PostgreSQL & Redis **running** in the background

## Setup

After a fresh clone, go to the project folder and create an `.env` file:

```bash
echo "LOCKBOX_MASTER_KEY=8f3b0605f48bdd55e6e53e3450208be2778a8eb0ac9648e83235f3f5c4d6b6ff" > .env
```

(This key is _not_ the production one. You can generate another one with `Lockbox.generate_key` in a `rails c`)

Then:

```bash
bundle install
yarn install
bin/rails db:create RAILS_ENV=development
bin/rails db:migrate RAILS_ENV=development
```

Please note that these four steps should be done every time you fetch a new version of `master` as gems, npm packages or DB migrations might have been added.

## Running

Open two terminals. In the first, start:

```bash
bin/rails server
```

In the second:

```bash
bin/webpack-dev-server
```

# To Contribute

- Go to https://github.com/hostolab/covidliste/issues and assign yourself an issue you think you can address.
- Work in a branch
- Submit a PR

We use the [GitHub flow](https://guides.github.com/introduction/flow/)

# Testing

To launch the tests locally, run:

```bash
bin/rspec
```

If you want to debug System Tests in the browser, add the following Ruby line as a debugger in your `spec/system/...` file:

```ruby
page.driver.debug(binding)
```

Then launch the test with:

```bash
INSPECTOR=true bin/rspec spec/system/THE_FILE_spec.rb
```

It should automatically open **Chrome** and allow you to inspect the DOM, queries, etc. You can `next` and `continue` in the Terminal as if you had a `binding.pry` debugging session.


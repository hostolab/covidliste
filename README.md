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
- PostgreSQL & Redis running

## Start

After a fresh clone, go to the project folder and create an `.env` file:

```bash
echo "LOCKBOX_MASTER_KEY=dev" > .env
```

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


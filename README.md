# Covidliste

Covidliste makes it easy to manage waiting lists for vaccination centers.

[https://www.covidliste.com](https://www.covidliste.com)

<img src='https://www.pasteur.fr/sites/default/files/styles/media-wide/public/rubrique_linstitut_pasteur/notre_histoire/alexandre-yersin-institutpasteur_46576.jpg?itok=FL2T1kf4' width='200px'> </img>

# Stack

- Ruby on Rails
- Postgresql

# Local Development

## Installation

### Prerequisites

If you don't already have them :

- Install ruby 2.6.6 `rbenv install 2.6.6 && rbenv global 2.6.6`
- Install bundler 2.1.4 `gem install bundler:2.2.7`
- Install yarn `npm i -g yarn`
- Install redis `brew install redis`

### Dependencies

Setup the project's dependencies :

```bash
bundle install
yarn
```

Create the `.env` file:

```bash
echo "LOCKBOX_MASTER_KEY=0000000000000000000000000000000000000000000000000000000000000000" > .env 
```

### Database / Cache

1. Create a database called `covidliste_development` using your favorite postgresql GUI or CLI.
2. Then run the migrations : `bin/rails db:migrate RAILS_ENV=development`
3. Run redis if it's not already running : `redis-server /usr/local/etc/redis.conf`

### Running

Run :

```bash
redis-server /usr/local/etc/redis.conf # Run redis if not already running
bin/rails server
```

### Admin development

In a rails console with `rails c`

```ruby
user = User.find_by(email: <your_email>)
user.add_role(:super_admin)
```

# To Contribute

- Go to https://github.com/hostolab/covidliste/issues and assign yourself an issue you think you can address.
- Submit a PR

# Code formatting
In order for the pipeline to be successful, you must ensure that you respect the linting made using

```bash
bundle exec standardrb --fix   
```
If some errors are printed it means that some of the different issues can not be corrected automatically. 
Then you will need to correct them manually.

In rubymine, please follow this procedure to add the formatter / linter directly in the editor tabs:
https://www.jetbrains.com/help/ruby/rubocop.html#prerequisites
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

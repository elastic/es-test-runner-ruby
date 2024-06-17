# Elasticsearch Tests Runner

This gem is a runner for Elasticsearch clients to run the [Elasticsearch Clients Tests](https://github.com/elastic/elasticsearch-clients-tests). It's a test suite in the YAML format to reuse across different Elasticsearch clients in different programming languages.



## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add elasticsearch-test-runner

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install elasticsearch-test-runner

## Usage

This gem is being used in the [elasticsearch](https://github.com/elastic/elasticsearch-ruby) and [elasticsearch-serverless](https://github.com/elastic/elasticsearch-serverless-ruby/) Ruby clients.

To start using it, add this to your code:

```ruby
# Require the library
require 'elasticsearch/tests/test_runner'
# Define a path where the test files are being stored:
tests_path = File.expand_path('../../tmp', __dir__)

logger = Logger.new($stdout)
logger.level = Logger::WARN unless ENV['DEBUG']

Elasticsearch::Tests::TestRunner.new(client, tests_path, logger).run
```

You need to pass in a client, the path where the YAML files are located (optional, will default to `./tmp`) and (optionaly) an object that implements Logger. The tests are designed for the Elasticsearch REST API and the Elasticsearch Serverless REST API. If you pass in an `ElasticsearchServerless::Client`, it will only run the tests that have the `requires.serverless: true` statement. Otherwise, it will only run the ones with `requires.stack: true`.

You can download the YAML test files from [the clients tests project](https://github.com/elastic/elasticsearch-clients-tests) with the following code:

```ruby
require 'elasticsearch/tests/downloader'
Elasticsearch::Tests::Downloader::run(tests_path)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elastic/elasticsearch-tests.

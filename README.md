# Elasticsearch Tests Runner

This gem is a tool for Elasticsearch Ruby clients to run the [Elasticsearch Clients Tests](https://github.com/elastic/elasticsearch-clients-tests). The Client tests project is a test suite in the YAML format. It defines a set of actions and expectations to run against Elasticsearch. The are designed to run with Elasticsearch clients, with the goal to reuse across different Elasticsearch clients in different programming languages.

This is the Ruby version and is being used in the [elasticsearch](https://github.com/elastic/elasticsearch-ruby) and [elasticsearch-serverless](https://github.com/elastic/elasticsearch-serverless-ruby/) Ruby clients.

## Installation

Add the gem to the application's Gemfile:

```ruby
gem 'elasticsearch-test-runner', git: 'git@github.com:elastic/es-test-runner-ruby.git'
```

## Usage

To start using the library, add this to your code:

```ruby
# Require the library
require 'elasticsearch/tests/test_runner'
# Define a path where the test files are being stored:
tests_path = File.expand_path('./tmp', __dir__)
# Instantiate an Elasticsearch client
client = Elasticsearch::Client.new
# Instantiate and run the test runner:
Elasticsearch::Tests::TestRunner.new(client, tests_path).run
```

[The tests](https://github.com/elastic/elasticsearch-clients-tests) are designed for the Elasticsearch REST API and the Elasticsearch Serverless REST API. If you pass in an `ElasticsearchServerless::Client`, it will only run the tests that have the `requires.serverless: true` statement. Otherwise, it will only run the ones with `requires.stack: true`.

You can optionally pass in an object that implements Ruby's Logger to the `TestRunner` initializer. This will log more information, particularly useful in the case of errors where it'll log stacktraces for exceptions and more:

```ruby
logger = Logger.new($stdout)
logger.level = Logger::WARN unless ENV['DEBUG']

Elasticsearch::Tests::TestRunner.new(client, tests_path, logger).run
```

You can **download the YAML test files** from [the clients tests project](https://github.com/elastic/elasticsearch-clients-tests) with the following code:

```ruby
require 'elasticsearch/tests/downloader'
Elasticsearch::Tests::Downloader::run(tests_path)
```

Additionally, you can run the rake task `rake es_tests:download` included in `lib/elasticsearch/tasks`.

## Development

See [CONTRIBUTING](./CONTRIBUTING.md).

## License

This software is licensed under the [Apache 2 license](./LICENSE). See [NOTICE](./NOTICE).

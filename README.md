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


### Logging

You can optionally pass in an object that implements Ruby's Logger to the `TestRunner` initializer. This will log more information, particularly useful in the case of errors where it'll log stacktraces for exceptions and more:

```ruby
logger = Logger.new($stdout)
logger.level = Logger::WARN unless ENV['DEBUG'] == 'true'

runner = Elasticsearch::Tests::TestRunner.new(client, tests_path, logger)
runner.run
```

### Running particular tests

When you run the tests, you can pass in the name of a particular test or a whole test folder, to run only those tests. Tests in the clients project are located [in the `tests` directory](https://github.com/elastic/elasticsearch-clients-tests/tree/main/tests) either as single yaml files or inside a specific directory, referring to a specific namespace. For example [`tests/get.yml`](https://github.com/elastic/elasticsearch-clients-tests/blob/main/tests/get.yml) and [`tests/bulk/10_basic.yml`](https://github.com/elastic/elasticsearch-clients-tests/blob/main/tests/bulk/10_basic.yml). If you want to run the `get.yml` test, you can pass in the file name to `run`:

```ruby
runner.run('get.yml')
```

If you want to run the basic bulk tests, you can run:

```ruby
runner.run('bulk/10_basic.yml')
```

If you want to run all the tests in a directory, you can pass in the directory:

```ruby
runner.run('indices')
```

This will run all the tests in [`tests/indices`](https://github.com/elastic/elasticsearch-clients-tests/tree/main/tests/indices) such as `alias.yml`, `analyze.yml`, and so on.

### Skipping tests

If you want to skip any given tests, you can do it using `add_tests_to_skip` before calling `run` like this:

```ruby
runner.add_tests_to_skip(['bulk/10_basic.yml', 'get.yml'])
```

You need to pass in an Array of file or folder names, or a single test file as a String.

### Downloading the test suite

You can **download the YAML test files** from [the clients tests project](https://github.com/elastic/elasticsearch-clients-tests) with the following code:

```ruby
require 'elasticsearch/tests/downloader'
Elasticsearch::Tests::Downloader::run(tests_path)
```

Additionally, you can run the rake task `rake es_tests:download` included in `lib/elasticsearch/tasks`.

### Environment variables

You can set the following environment variables when using the test runner:

#### `DEBUG`

If you set `DEBUG` to `true`, you'll see debug messages for each tests, including the response status, body and headers sent from Elasticsearch:

```
🟢 cluster/put_settings.yml - is_true: acknowledged passed [200]
┌[DEBUG]──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│File: cluster/remote_info.yml | Action: remote_info                                                                              │
│Parameters: {}                                                                                                                   │
│                                                                                                                                 │
│Response status: 200                                                                                                             │
│Response body:                                                                                                                   │
│Response headers:                                                                                                                │
│  x-elastic-product: Elasticsearch                                                                                               │
│  content-type: application/vnd.elasticsearch+json;compatible-with=9                                                             │
│  content-length: 2                                                                                                              │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### `QUIET`

If you set `QUIET` to anything other than `false` or the String `"false"`, tests will run in quiet mode, where you'll only see the green (success) and/or red (failure) output for the tests:

```
$ QUIET=1 be rake test:yaml
🟢 🟢 🟢 🟢 🟢 🔴 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢 🟢
 ```

It will still print out the summary and information about failures and/or errors at the bottom.

## Development

See [CONTRIBUTING](./CONTRIBUTING.md).

## License

This software is licensed under the [Apache 2 license](./LICENSE). See [NOTICE](./NOTICE).

# Changelog

## [0.16.0] - 2026-02-25

- Lets Ruby handle successful exit code at the end of the test run, only uses `exit 1` if there are errors.
- Display of debug messages has been improved when `DEBUG=true` is used - [Pull Request](https://github.com/elastic/es-test-runner-ruby/pull/24).

## [0.15.1] - 2026-01-30

- Rescues invalid byte sequence for search_mvt test.

## [0.15.0] - 2026-01-29

- Bugfix: refactors response display for boolean responses (ping, exists) when in debug mode.
- Sets boxes screen size to whole screen.

## [0.14.0] - 2026-01-29

- Introduces Ruby TTY tools for better debugging when `ENV['DEBUG']` is set and general display improvements.
- Better information for actions in passing/erroring tests, showing actions instead of the test title.

## [0.13.0] - 2025-06-05

- Moves download tests file to Rakefile (namespace is unchanged).
- Updates Elasticsearch Clients Tests repo URL.

## [0.12.0] - 2025-01-14

- Check TEST_SUITE variable for `serverless`.

## [0.11.0] - 2024-12-12

- Adds skipping tests.

## [0.10.1] - 2024-11-13

- Creates directory for tests if it doesn't exist.

## [0.10.0] - 2024-11-13

- Using tar.gz file for downloaded tests instead of zip file.
- Updates logging and debug information. More information being logged for different levels of Logger.

## [0.9.0] - 2024-08-15

- Better display of action and response when `ENV['DEBUG']` is true.
- Checks for more error types when catching exceptions.
- Better matching for regular expressions.
- Refactors `set_param_variable` for better substitution.

## [0.8.0] - 2024-08-14

- Adds support for variable keys (`$`).

## [0.7.0] - 2024-08-08

- Improves test (file) name display
- Updates QUIET environment variable check

## [0.6.0] - 2024-08-07

- Adds `header` support, headers can be specified for an action.
- Show response in errors.

## [0.5.0] - 2024-07-30

- Clears `@response` before running a new action
- Fixes `expected_exception?` for failures

## [0.4.0] - 2024-07-08

- Refactors display of errors/passing tests. Adds `QUIET` environment variable parsing. If `true`, display for passing tests will be more compact (not showing file/test names).
- Updates count for better accuracy in test results.
- Rescues SystemExit, Interrupt to actually exit the script
- Adds support for catch in tests: If the arguments to `do` include `catch`, then we are expecting an error, which should be caught and tested.

## [0.3.1] - 2024-06-27

- Fixes in error handling.

## [0.3.0] - 2024-06-27

- Fixes exit code.
- Refactors error handling for more detailed information.

## [0.2.0] - 2024-06-25

- Renames gemspec from elasticsearch-tests to elasticsearch-test-runner.
- Adds ability to run individual test files or directories.

## [0.1.1] - 2024-06-20

- Require 'fileutils' in Downloader.

## [0.1.0] - 2024-06-20

- Initial release.

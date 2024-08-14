# Changelog

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

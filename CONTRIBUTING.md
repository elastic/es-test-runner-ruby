# Contributing

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

The process for contributing to any of the [Elasticsearch](https://github.com/elasticsearch) repositories is similar:

1. It is best to do your work in a separate Git branch. This makes it easier to synchronise your changes with [`rebase`](http://mislav.uniqpath.com/2013/02/merge-vs-rebase/).

2. Make sure your changes don't break any existing tests, and that you add tests for both bugfixes and new functionality. If you want to examine the test coverage, you can generate a report by running `COVERAGE=true rake test:all`.

3. **Sign the contributor license agreement.**
Please make sure you have signed the [Contributor License Agreement](https://www.elastic.co/contributor-agreement/). We are not asking you to assign copyright to us, but to give us the right to distribute your code without restriction. We ask this of all contributors in order to assure our users of the origin and continuing existence of the code. You only need to sign the CLA once.

4. Submit a pull request.
Push your local changes to your forked copy of the repository and submit a pull request. In the pull request, describe what your changes do and mention the number of the issue where discussion has taken place, eg “Closes #123″.

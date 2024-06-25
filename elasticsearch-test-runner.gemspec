# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# frozen_string_literal: true

require_relative 'lib/elasticsearch/tests/version'

Gem::Specification.new do |spec|
  spec.name = 'elasticsearch-test-runner'
  spec.email = ['client-libs@elastic.co']
  spec.version = Elasticsearch::Tests::VERSION
  spec.authors = ['Elastic Client Library Maintainers']
  spec.licenses = ['Apache-2.0']
  spec.summary = 'Tool to test Elasticsearch clients against the YAML clients test suite.'
  spec.homepage = 'https://www.elastic.co/guide/en/elasticsearch/client/ruby-api/current/index.html'
  spec.description = 'A test runner for the Elasticsearch clients YAML test suite, used in the elasticsearch and elasticsearch-serverless gems.'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/elastic/es-test-runner-ruby/blob/main/CHANGELOG.md'
  spec.metadata['source_code_uri'] = 'https://github.com/elastic/es-test-runner-ruby/tree/main'

  spec.required_ruby_version = '>= 3.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'elasticsearch'
  spec.add_development_dependency 'elasticsearch-serverless'
end

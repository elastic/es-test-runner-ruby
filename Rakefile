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

require 'bundler/gem_tasks'
require 'elasticsearch/tests/downloader'
task default: %i[]

namespace :es_tests do
  desc 'Download YAML test files'
  task :download do |_, args|
    tests_path = args[:path] || File.expand_path('./tmp', __dir__)
    Elasticsearch::Tests::Downloader::run(tests_path)
  end
end

desc 'Run unit tests'
task :test do
  sh 'bundle exec rspec'
end

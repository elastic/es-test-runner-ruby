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

require 'logger'
require 'yaml'
require_relative './test'
require_relative './printer'

module Elasticsearch
  module Tests
    # Main YAML test runner
    class TestRunner
      LOGGER = Logger.new($stdout)
      LOGGER.level = Logger::WARN unless ENV['DEBUG']

      def initialize(client, path = nil, logger = nil)
        @client = client
        @serverless = defined?(::ElasticsearchServerless) && client.is_a?(::ElasticsearchServerless::Client)
        @path = path || File.expand_path('./tmp', __dir__)
        @logger = logger || LOGGER
      end

      def run(test_files = [])
        raise 'Couldn\'t find test files. Run `Elasticsearch::Tests::Downloader::run(tests_path)` to download the tests' unless File.directory?(@path)

        @test_files = select_test_files(test_files)
        run_the_tests
        Elasticsearch::Tests::Printer::display_errors(@errors) unless @errors.empty?
        Elasticsearch::Tests::Printer::display_summary(@tests_count, @errors.count, @start_time)
        if @errors.empty?
          exit 0
        else
          exit 1
        end
      end

      def run_the_tests
        @start_time = Time.now
        @tests_count = 0
        @errors = []

        @test_files.map do |test_file|
          build_and_run_tests(test_file)
        rescue Psych::SyntaxError => e
          @errors << { error: e, file: test_file }
          @logger.warn("YAML error in #{test_file}")
          @logger.warn e
        rescue StandardError => e
          @errors << { error: e, file: test_file }
          @logger.debug e
        end
      end

      def build_and_run_tests(test_file)
        yaml = YAML.load_stream(File.read(test_file))
        requires = extract_requires!(yaml).compact.first['requires']
        return unless (requires['serverless'] == true && @serverless) ||
                      (requires['stack'] == true && !@serverless)

        test = Elasticsearch::Tests::Test.new(yaml, test_file, @client)
        test.execute
        @tests_count += test.count
      rescue StandardError => e
        raise e
      end

      def select_test_files(test_files)
        tests_path = if test_files.empty?
                       "#{@path}/**/*.yml"
                     elsif test_files.include?('yml')
                       "#{@path}/#{test_files}"
                     else
                       "#{@path}/#{test_files}/*.yml"
                     end
        Dir.glob(tests_path)
      end

      def extract_requires!(yaml)
        yaml.map.with_index do |a, i|
          yaml.delete_at(i) if a.keys.first == 'requires'
        end.compact
      end
    end
  end
end

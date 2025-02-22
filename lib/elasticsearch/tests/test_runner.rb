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
      LOGGER.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::WARN

      def initialize(client, path = nil, logger = nil)
        @client = client
        @serverless = defined?(::ElasticsearchServerless) && client.is_a?(::ElasticsearchServerless::Client) ||
                      ENV['TEST_SUITE'] == 'serverless'
        @path = path || File.expand_path('./tmp', __dir__)
        @logger = logger || LOGGER
        @tests_to_skip = []
      end

      def add_tests_to_skip(tests)
        if tests.is_a? String
          @tests_to_skip << tests
        else
          @tests_to_skip.merge!(tests)
        end
      end

      def run(test_files = [])
        raise 'Couldn\'t find test files. Run `Elasticsearch::Tests::Downloader::run(tests_path)` to download the tests' unless File.directory?(@path)

        @test_files = select_test_files(test_files)
        run_the_tests
        Elasticsearch::Tests::Printer::display_errors(@errors, @logger) unless @errors.empty?
        Elasticsearch::Tests::Printer::display_summary(@tests_count, @errors.count, @start_time, @logger)
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

        @test_files.map do |test_path|
          test_file = test_filename(test_path)
          build_and_run_tests(test_path)
        rescue Psych::SyntaxError => e
          @errors << { error: e, file: test_file }
          @logger.warn("YAML error in #{test_file}")
          @logger.warn e
        rescue ActionError => e
          @errors << { error: e, file: test_file, action: e.action }
          @logger.debug e
        rescue StandardError => e
          @errors << { error: e, file: test_file }
          @logger.debug e
        rescue SystemExit, Interrupt
          exit
        end
      end

      def build_and_run_tests(test_path)
        yaml = YAML.load_stream(File.read(test_path))
        requires = extract_requires!(yaml).compact.first['requires']
        return unless (requires['serverless'] == true && @serverless) ||
                      (requires['stack'] == true && !@serverless)

        test = Elasticsearch::Tests::Test.new(yaml, test_path, @client)
        test.execute
        @tests_count += test.count
      rescue StandardError => e
        raise e
      end

      def test_filename(file)
        name = file.split('/')
        "#{name[-2]}/#{name[-1]}"
      end

      def select_test_files(test_files)
        tests_path = if test_files.empty?
                       "#{@path}/**/*.yml"
                     elsif test_files.include?('yml')
                       return ["#{@path}/tests/#{test_files}"]
                     else
                       "#{@path}/#{test_files}/*.yml"
                     end
        tests = Dir.glob(tests_path)
        tests.each do |test|
          @tests_to_skip.each do |skip|
            tests.delete(test) if test.match?(skip)
          end
        end
        tests
      end

      def extract_requires!(yaml)
        yaml.map.with_index do |a, i|
          yaml.delete_at(i) if a.keys.first == 'requires'
        end.compact
      end
    end
  end
end

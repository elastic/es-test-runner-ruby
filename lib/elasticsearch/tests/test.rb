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

require_relative 'code_runner'
require_relative 'errors'

module Elasticsearch
  module Tests
    #
    # Represents a test, which is initialized in the test runner when iterating through the YAML
    # files. Each YAML file can have more than one test.
    # When a test is executed it runs the setup, actions (and matches) and finally the teardown stage.
    #
    class Test
      include Elasticsearch::Tests::CodeRunner

      def initialize(yaml, file, client)
        @setup = extract_setup!(yaml)
        @teardown = extract_teardown!(yaml)
        @title = yaml.first.keys.first
        @actions = yaml.first[@title]
        @file = file
        name = file.split('/')
        @short_name = "#{name[-2]}/#{name[-1]}"
        @client = client
      end

      def execute
        begin
          run_setup
          run_actions
        ensure
          run_teardown
        end
      end

      def run_actions
        return unless @actions

        @actions.map { |action| run_action(action) }
      end

      def run_action(action)
        definition = action.keys.first

        case definition
        when 'do'
          @action = action['do'].keys.first
          do_action(action['do'])
        when 'set'
          set_variable(action)
        when 'match'
          @action = "#{action.keys.first} #{format_action(action[action.keys.first])}"
          do_match(action)
        when 'length'
          @action = format_action(action)
          do_length(action)
        when 'is_true'
          @action = format_action(action)
          is_true(action)
        when 'is_false'
          @action = format_action(action)
          is_false(action)
        when 'gt', 'gte', 'lt', 'lte'
          @action = format_action(action)
          compare(action)
        end
      rescue StandardError => e
        raise ActionError.new(e.message, @file, action)
      end

      def run_setup
        return unless @setup

        @setup.map do |step|
          do_action(step['do']) if step['do']
        end
      end

      def run_teardown
        return unless @teardown

        @teardown['teardown'].map { |step| do_action(step['do']) }
      end

      def count
        @actions.select { |a| a.keys.first == 'do' }.count
      end

      def extract_setup!(yaml)
        yaml.map.with_index do |a, i|
          yaml.delete_at(i) if a.keys.first == 'setup'
        end.compact.first&.[]('setup')
      end

      def extract_teardown!(yaml)
        yaml.map.with_index do |a, i|
          yaml.delete_at(i) if a.keys.first == 'teardown'
        end.compact.first
      end

      private

      def format_action(action)
        action.to_s
              .gsub(/^{/, '')
              .gsub(' =>', ':')
              .gsub('"', '')
              .gsub('}', '')
              .gsub('{', '|')
      end
    end
  end
end

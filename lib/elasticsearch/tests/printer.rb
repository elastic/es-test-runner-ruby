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
require_relative 'errors'

module Elasticsearch
  module Tests
    #
    # Functions to print out test results, errors, summary, etc.
    #
    module Printer
      def print_success
        response = if [true, false].include? @response
                     @response
                   else
                     @response.status
                   end
        if ENV['QUIET'] == 'true'
          print '🟢 '
        else
          puts "🟢 #{@short_name} #{@title} passed. Response: #{response}"
        end
      end

      def print_failure(action, response)
        puts "🔴 #{@short_name} #{@title} failed"
        puts "Expected result: #{action}" # TODO: Show match/length differently
        if defined?(ElasticsearchServerless) &&
           response.is_a?(ElasticsearchServerless::API::Response) ||
           defined?(Elasticsearch::API) && response.is_a?(Elasticsearch::API::Response)
          puts 'Response:'
          pp response.body
        else
          pp response
        end
        raise Elasticsearch::Tests::ActionError.new(response.body, @short_name, action)
      end

      def print_match_failure(action)
        keys = action['match'].keys.first
        value = action['match'].values.first

        message = <<~MSG
          🔴 #{@short_name} #{@title} failed
          Expected: { #{keys}: #{value} }
          Actual  : { #{keys}: #{search_in_response(action['match'].keys.first)} }
          Response: #{@response}
        MSG
        raise Elasticsearch::Tests::TestFailure.new(message)
      end

      def print_error(error)
        puts "❌ ERROR: #{@short_name} #{@title} failed\n"
        logger.error error.display
        backtrace = error.backtrace.join("\n")
        logger.error "#{backtrace}\n"
        raise error
      end

      def self.display_errors(errors)
        puts "+++ ❌ Errors/Failures: #{errors.count}"
        errors.map do |error|
          puts "🧪 Test: #{error[:file]}"
          puts "▶ Action: #{error[:action].first}" if error[:action]
          puts "🔬 #{error.class} - #{error[:error].message}"
          pp error[:error].backtrace.join("$/\n") if ENV['DEBUG']
          puts
        end
      end

      def self.display_summary(tests_count, errors_count, start_time)
        puts
        puts "--- 🧪 Tests: #{tests_count} | Passed: #{tests_count - errors_count} | Failed: #{errors_count}"
        puts "--- ⏲  Elapsed time: #{Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")}"
      end
    end
  end
end

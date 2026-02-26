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
require 'tty-box'
require 'tty-screen'
require_relative 'errors'

module Elasticsearch
  module Tests
    #
    # Functions to print out test results, errors, summary, etc.
    #
    module Printer
      BOX_WIDTH = TTY::Screen.width

      def print_success
        if quiet?
          print '🟢 '
        else
          status = boolean_response? ? @response : @response.status
          puts "🟢 \e[33m#{@short_name}\e[0m - #{@action}  \e[32mpassed\e[0m [#{status}]"
        end
      end

      def quiet?
        !ENV['QUIET'].nil? && ![false, 'false'].include?(ENV['QUIET'])
      end

      def print_failure(action, response)
        if quiet?
          print '🔴 '
        else
          puts "🔴 \e[33m#{@short_name}\e[0m - #{@action}  \e[31mfailed\e[0m"
        end
        message = ["Expected result: #{action}"]
        if defined?(ElasticsearchServerless) &&
           response.is_a?(ElasticsearchServerless::API::Response) ||
           defined?(Elasticsearch::API) && response.is_a?(Elasticsearch::API::Response)
          message << 'Response:'
          message << response.body
        else
          message << response
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
        print TTY::Box.error("❌ ERROR: #{@short_name} #{@title} failed", width: BOX_WIDTH)
        logger.error error.display
        backtrace = error.backtrace.join("\n")
        logger.error "#{backtrace}\n"
        raise error
      end

      def self.display_errors(errors, logger)
        print TTY::Box.frame("❌ Errors/Failures: #{errors.count}", width: BOX_WIDTH, style: { border: { fg: :red } })
        errors.map do |error|
          message = []
          message << "🧪 Test: #{error[:file]}"
          message << "▶ Action: #{error[:action].first}" if error[:action]
          message << "🔬 #{error.class} - #{error[:error].message}"
          message << error[:error].backtrace.join("$/\n") if ENV['DEBUG']
          print TTY::Box.frame(message.join("\n"), width: BOX_WIDTH, style: { border: { fg: :red } })
          logger.error(message.join("\n"))
        end
      end

      def self.display_summary(tests_count, errors_count, start_time, logger)
        summary = "🧪 Tests: #{tests_count} | Passed: #{tests_count - errors_count} | Failed: #{errors_count}"
        logger.info summary
        duration = "⏲  Elapsed time: #{Time.at(Time.now - start_time).utc.strftime('%H:%M:%S')}"
        message = <<~MSG
                     #{summary}
                     #{duration}
        MSG
        print TTY::Box.frame(message, width: BOX_WIDTH, title: { top_left: '[SUMMARY]' }, style: { border: { fg: :cyan } })
        logger.info duration
      end

      def print_debug_message(method, params)
        begin
          message = [
            "File: #{$test_file} | Action: #{method}",
            "Parameters: #{params}",
            ''
          ]
          if boolean_response?
            message << "Response: #{@response}"
          else
            message << "Response status: #{@response.status}"
            message << 'Response body:'
            if @response.body.is_a?(String)
              message.push(@response.body.empty? ? '  ""' : @response.body)
            elsif @response.body.is_a?(Hash)
              message.push(*@response.body.map { |k, v| "  #{k}: #{v}" })
            end
            message << 'Response headers:'
            message.push(*@response.headers.map { |k, v| "  #{k}: #{v}" })
          end
          puts TTY::Box.frame(message.join("\n"), width: BOX_WIDTH, title: { top_left: '[DEBUG]' })
        rescue ArgumentError => e
          if e.message == 'invalid byte sequence in UTF-8'
            @response.body.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
            print_debug_message(method, params)
          end
        end
      end

      private

      def boolean_response?
        [true, false].include? @response
      end
    end
  end
end

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
require_relative 'printer'

module Elasticsearch
  module Tests
    #
    # The module in charge of actually running actions and matching expected results with actual response results.
    #
    module CodeRunner
      include Elasticsearch::Tests::Printer

      COMPARATORS = {
        'lt' => '<',
        'lte' => '<=',
        'gt' => '>',
        'gte' => '>='
      }.freeze

      # The main functionality in the test runner, run actions with the client from YAML `do`
      # specifications. These are function calls to the Elasticsearch clients.
      #
      def do_action(action)
        @response = nil
        catchable = action.delete('catch')
        client = @client
        if action['headers']
          client.transport.options[:transport_options][:headers].merge(
            { headers: action.delete('headers') }
          )
        end

        action = action.first if action.is_a?(Array)
        method, params = action.is_a?(String) ? [action, {}] : action.first

        # Get the namespace client if the method is namespaced
        if method.include?('.')
          arrayed_method = method.split('.')
          client = @client.send(arrayed_method.first)
          method = arrayed_method.last
        end
        @response = client.send(method.to_sym, process_params(params))
        puts "Action: #{action}\nResponse: #{@response}\n\n" if ENV['DEBUG']
        @response
      rescue StandardError => e
        if expected_exception?(catchable, e)
          puts "Catchable: #{e}\nResponse: #{@response}\n" if ENV['DEBUG']
        else
          raise e
        end
      end

      def expected_exception?(error_type, e)
        return false if error_type.nil?

        case error_type
        when 'request_timeout'
          e.is_a?(Elastic::Transport::Transport::Errors::RequestTimeout)
        when 'missing', /resource_not_found_exception/
          e.is_a?(Elastic::Transport::Transport::Errors::NotFound)
        when 'conflict'
          e.is_a?(Elastic::Transport::Transport::Errors::Conflict)
        when 'request'
          e.is_a?(Elastic::Transport::Transport::Errors::InternalServerError)
        when 'bad_request'
          e.is_a?(Elastic::Transport::Transport::Errors::BadRequest)
        when 'param'
          actual_error.is_a?(ArgumentError)
        when 'unauthorized'
          e.is_a?(Elastic::Transport::Transport::Errors::Unauthorized)
        when 'forbidden'
          e.is_a?(Elastic::Transport::Transport::Errors::Forbidden)
        when /error parsing field/, /illegal_argument_exception/
          e.message =~ /\[400\]/ ||
            e.is_a?(Elastic::Transport::Transport::Errors::BadRequest)
        when /NullPointerException/
          e.message =~ /\[400\]/
        when /status_exception/
          e.message =~ /\[409\]/
        else
          e.message =~ /#{error_type}/
        end
      end

      # Code for matching expectations and response
      #
      def do_match(action)
        k, v = action['match'].first
        v = instance_variable_get(v.gsub('$', '@')) if v.is_a?(String) && v.include?('$')
        result = search_in_response(k)

        if !result.nil? && (
             result == v ||
             (result.respond_to?(:include?) && result.include?(v)) ||
             match_regexp(v, result)
           )
          print_success
        else
          print_match_failure(action)
        end
      end

      def match_regexp(expected, result)
        expected.is_a?(String) &&
          expected.match?(/^\//) &&
          result.match?(Regexp.new(expected.gsub('/', '').strip))
      end

      def do_length(action)
        k, v = action['length'].first
        result = search_in_response(k).count
        if result && result == v
          print_success
        else
          print_failure(action, @response)
        end
      end

      #
      # The specified key exists and has a true value (ie not 0, false, undefined, null)
      # action - { 'is_true' => field } or { 'is_true' => '' }
      #
      def is_true(action)
        if @response.respond_to?(:body) && !@response&.nil? && ['', []].include?(action['is_true'])
          print_success
          return
        end

        response_value = search_in_response(action['is_true']) unless [true, false].include?(@response)
        if @response == true || !response_value.nil?
          print_success
        else
          print_failure(action, @response)
        end
      end

      def is_false(action)
        response_value = search_in_response(action['is_false']) unless [true, false].include? @response
        if @response == false || response_value.nil? || [false, 'false'].include?(response_value)
          print_success
        else
          print_failure(action, @response)
        end
      end

      #
      # Used for comparing gte (greater or equal than), gt (greater than), lte (less or equal than)
      # and lt (less than)
      # action - { 'gte' => { 'key' => value } }
      #
      def compare(action)
        operator, value = action.first
        result = search_in_response(value.keys.first)
        if result&.send(COMPARATORS[operator], value[value.keys.first])
          print_success
        else
          print_failure(action, @response)
        end
      end

      # When the yaml test has a set instruction, set an instance variable with that value coming
      # from the response.
      def set_variable(action)
        k, v = action['set'].first
        instance_variable_set("@#{v}", search_in_response(k))
      end

      private

      # Given a key coming from a test definition, search the response body for a matching value.
      #
      def search_in_response(keys)
        if keys.include?('.')
          key = split_and_parse_key(keys)
          return find_value_in_document(key, @response.body)
        elsif (match = /\$([a-z]+)/.match(keys))
          return @response.send(match[1])
        end

        @response[keys]
      end

      # Symbolizes keys and replaces parameters defined as dynamic in the yaml spec (e.g. $body)
      # with the corresponding variable set in set_variable
      #
      def process_params(params)
        params = params.transform_keys(&:to_sym)
        params.map do |key, param|
          params[key] = process_params(param) if param.is_a?(Hash)
          set_param_variable(params, key, param)
          param.map { |param| set_param_variable(params, key, param) } if param.is_a?(Array)
        end
        params
      end

      def set_param_variable(params, key, param)
        return unless param.is_a?(String) && param.include?("$")

        # Param can be a single '$value' string or '{ something: $value }'
        repleacable = param.match(/(\$[0-9a-z_-]+)/)[0]
        value = instance_variable_get(repleacable.gsub("$", "@"))
        content = param.gsub(repleacable, value)
        params[key] = content
      end

      # Given a list of keys, find the value in a recursively nested document.
      #
      # @param [ Array<String> ] chain The list of nested document keys.
      # @param [ Hash ] document The document to find the value in.
      #
      # @return [ Object ] The value at the nested key.
      #
      def find_value_in_document(chain, document)
        return document[chain] unless chain.is_a?(Array)
        return document[chain[0]] unless chain.size > 1

        # a number can be a string key in a Hash or indicate an element in a list
        if chain[0].is_a?(String) && chain[0].match?(/^\$/)
          find_value_in_document(chain[1..], instance_variable_get("@#{chain[0].gsub('$', '')}"))
        elsif document.is_a?(Hash)
          find_value_in_document(chain[1..], document[chain[0].to_s]) if document[chain[0].to_s]
        elsif document[chain[0]]
          find_value_in_document(chain[1..], document[chain[0]]) if document[chain[0]]
        end
      end

      # Given a string representing a nested document key using dot notation,
      #   split it, keeping escaped dots as part of a key name and replacing
      #   numerics with a Ruby Integer.
      #
      # For example:
      #   "joe.metadata.2.key2" => ['joe', 'metadata', 2, 'key2']
      #   "jobs.0.node.attributes.ml\\.enabled" => ["jobs", 0, "node", "attributes", "ml\\.enabled"]
      #
      # @param [ String ] chain The list of nested document keys.
      # @param [ Hash ] document The document to find the value in.
      #
      # @return [ Array<Object> ] A list of the nested keys.
      #
      def split_and_parse_key(key)
        key.split(/(?<!\\)\./).reject(&:empty?).map do |key_part|
          case key_part
          when /^\.\$/ # For keys in the form of .$key
            key_part.gsub(/^\./, '')
          when /\A[-+]?[0-9]+\z/
            key_part.to_i
          else
            key_part.gsub('\\', '')
          end
        end.reject { |k| k == '$body' }
      end
    end
  end
end

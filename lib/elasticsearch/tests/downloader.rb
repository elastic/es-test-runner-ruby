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
require 'open-uri'

module Elasticsearch
  module Tests
    # Module for downloading the test files
    module Downloader
      class << self
        # TODO: Make branch a parameter
        URL = 'https://api.github.com/repos/elastic/serverless-clients-tests/zipball/main'.freeze
        FILENAME = 'tests.zip'.freeze

        def run(path)
          delete_files(path)
          if download_tests
            puts "Successfully downloaded #{FILENAME}"
          else
            warn "[!] Couldn't download #{FILENAME}"
            return
          end
          unzip_file(path)
          File.delete(FILENAME)
        end

        def download_tests
          File.open(FILENAME, 'w') do |downloaded_file|
            URI.open(URL, 'Accept' => 'application/vnd.github+json') do |artifact_file|
              downloaded_file.write(artifact_file.read)
            end
          end
          File.exist?(FILENAME)
        end

        private

        def unzip_file(path)
          puts 'Unzipping files'
          puts path
          `unzip #{FILENAME} -d #{path}/`
          puts 'Removing zip file'
        end

        def delete_files(path)
          FileUtils.rm_rf(Dir.glob("#{path}/**/*"), secure: true)
        end
      end
    end
  end
end

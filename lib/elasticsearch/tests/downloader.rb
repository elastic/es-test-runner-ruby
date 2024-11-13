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
require 'fileutils'

module Elasticsearch
  module Tests
    # Module for downloading the test files
    module Downloader
      class << self
        FILENAME = 'tests.tar.gz'.freeze

        def run(path, branch = 'main')
          delete_files(path)
          url = "https://api.github.com/repos/elastic/serverless-clients-tests/tarball/#{branch}"
          if download_tests(url)
            puts "Successfully downloaded #{FILENAME}"
          else
            warn "[!] Couldn't download #{FILENAME}"
            return
          end
          untar_file(path)
          File.delete(FILENAME)
        end

        def download_tests(url)
          File.open(FILENAME, 'w') do |downloaded_file|
            uri = URI.parse(url)
            uri.open('Accept' => 'application/vnd.github+json') do |artifact_file|
              downloaded_file.write(artifact_file.read)
            end
          end
          File.exist?(FILENAME)
        end

        private

        def untar_file(path)
          puts 'Extracting tar files'
          puts path
          `tar -zxf #{FILENAME} --strip-components=1 -C #{path}/`
          puts 'Removing tar file'
        end

        def delete_files(path)
          FileUtils.rm_rf(Dir.glob("#{path}/**/*"), secure: true)
        end
      end
    end
  end
end

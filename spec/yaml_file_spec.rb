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

include Elasticsearch::Tests

describe 'TestRunner' do
  context 'test with one action' do
    let(:client) do
      instance_double('Elasticsearch::Client')
    end

    let(:yaml_path) { File.expand_path('./support/01_indices.create/', __dir__) }

    it 'Parses the test and calls the method' do
      # Client should receive :indices, return IndicesClient which should receive :create
      allow(client).to receive(:indices).and_return(client)
      allow(client).to receive(:create).and_return(client)
      runner = TestRunner.new(client, yaml_path)
      runner.run
    end
  end
end

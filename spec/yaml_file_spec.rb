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

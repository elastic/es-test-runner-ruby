require 'spec_helper'

describe Elasticsearch::Tests::TestRunner do
  it 'Instantiates a runner' do
    expect(
      Elasticsearch::Tests::TestRunner.new(Elasticsearch::Client.new)
    ).to be_a Elasticsearch::Tests::TestRunner
  end
end

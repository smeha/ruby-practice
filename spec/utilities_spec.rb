RSpec.describe '#aggregate_hash' do
  it 'aggregates multiple entries for the same suite' do
    result = aggregate_hash(AGGREGATE_HASH_DATA)
    expect(result['models']).to eq({ total: 2, passed: 1, failed: 1, duration: 20 })
  end

  it 'aggregates a suite with a single entry' do
    result = aggregate_hash(AGGREGATE_HASH_DATA)
    expect(result['api']).to eq({ total: 1, passed: 1, failed: 0, duration: 15 })
  end

  it 'returns an empty hash for empty input' do
    expect(aggregate_hash([])).to be_empty
  end

  it 'handles all passed results' do
    data = [
      { suite: 'ui', status: 'passed', duration: 5 },
      { suite: 'ui', status: 'passed', duration: 3 }
    ]
    result = aggregate_hash(data)
    expect(result['ui']).to eq({ total: 2, passed: 2, failed: 0, duration: 8 })
  end

  it 'handles all failed results' do
    data = [
      { suite: 'db', status: 'failed', duration: 10 },
      { suite: 'db', status: 'failed', duration: 7 }
    ]
    result = aggregate_hash(data)
    expect(result['db']).to eq({ total: 2, passed: 0, failed: 2, duration: 17 })
  end

  it 'keeps suites separate' do
    data = [
      { suite: 'a', status: 'passed', duration: 1 },
      { suite: 'b', status: 'failed', duration: 2 }
    ]
    result = aggregate_hash(data)
    expect(result.keys).to contain_exactly('a', 'b')
    expect(result['a'][:passed]).to eq(1)
    expect(result['b'][:failed]).to eq(1)
  end
end

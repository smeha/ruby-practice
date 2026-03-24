RSpec.describe '#aggregate_hash' do
  let(:sample_data_to_agg) do
    [
      { suite: 'models', status: 'passed', duration: 12 },
      { suite: 'models', status: 'failed', duration: 8 },
      { suite: 'api',    status: 'passed', duration: 15 }
    ]
  end

  it 'aggregates multiple entries for the same suite' do
    result = aggregate_hash(sample_data_to_agg)
    expect(result['models']).to eq({ total: 2, passed: 1, failed: 1, duration: 20 })
  end

  it 'aggregates a suite with a single entry' do
    result = aggregate_hash(sample_data_to_agg)
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

RSpec.describe RateLimiter do
  describe '#allow?' do
    let(:limiter) { described_class.new(3, 10) }

    it 'allows requests under the limit' do
      expect(limiter.allow?('user1', 0)).to be true
      expect(limiter.allow?('user1', 1)).to be true
      expect(limiter.allow?('user1', 2)).to be true
    end

    it 'denies requests over the limit' do
      3.times { |t| limiter.allow?('user1', t) }
      expect(limiter.allow?('user1', 3)).to be false
    end

    it 'allows again after the window expires' do
      3.times { |t| limiter.allow?('user1', t) }
      expect(limiter.allow?('user1', 11)).to be true
    end

    it 'tracks users independently' do
      3.times { |t| limiter.allow?('user1', t) }
      expect(limiter.allow?('user1', 3)).to be false
      expect(limiter.allow?('user2', 3)).to be true
    end
  end
end

RSpec.describe '#find_flaky_tests' do
  it 'returns tests that both passed and failed' do
    data = [
      { test_name: 'login', status: 'passed' },
      { test_name: 'login', status: 'failed' },
      { test_name: 'signup', status: 'passed' }
    ]
    expect(find_flaky_tests(data)).to eq(['login'])
  end

  it 'returns empty when no tests are flaky' do
    data = [
      { test_name: 'login', status: 'passed' },
      { test_name: 'signup', status: 'passed' }
    ]
    expect(find_flaky_tests(data)).to be_empty
  end

  it 'returns empty for empty input' do
    expect(find_flaky_tests([])).to be_empty
  end

  it 'ignores tests that only failed' do
    data = [
      { test_name: 'broken', status: 'failed' },
      { test_name: 'broken', status: 'failed' }
    ]
    expect(find_flaky_tests(data)).to be_empty
  end

  it 'detects multiple flaky tests' do
    data = [
      { test_name: 'a', status: 'passed' },
      { test_name: 'a', status: 'failed' },
      { test_name: 'b', status: 'passed' },
      { test_name: 'b', status: 'failed' },
      { test_name: 'c', status: 'passed' }
    ]
    expect(find_flaky_tests(data)).to contain_exactly('a', 'b')
  end
end

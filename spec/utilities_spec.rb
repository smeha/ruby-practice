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

RSpec.describe Job do
  it 'stores id, status, and attempts' do
    job = described_class.new('j1', 'pending', 0)
    expect(job.id).to eq('j1')
    expect(job.status).to eq('pending')
    expect(job.attempts).to eq(0)
  end

  it 'allows mutation of attributes' do
    job = described_class.new('j1', 'pending', 0)
    job.status = 'running'
    job.attempts += 1
    expect(job.status).to eq('running')
    expect(job.attempts).to eq(1)
  end
end

RSpec.describe JobQueue do
  let(:queue) { described_class.new(3) }

  describe '#add_job' do
    it 'adds a job with pending status' do
      queue.add_job('j1')
      expect(queue.jobs.first.id).to eq('j1')
      expect(queue.jobs.first.status).to eq('pending')
    end

    it 'raises on duplicate job id' do
      queue.add_job('j1')
      expect { queue.add_job('j1') }.to raise_error(ArgumentError, 'duplicate job id')
    end
  end

  describe '#start_next' do
    it 'starts the first pending job' do
      queue.add_job('j1')
      job = queue.start_next
      expect(job.status).to eq('running')
      expect(job.attempts).to eq(1)
    end

    it 'returns nil when no pending jobs' do
      expect(queue.start_next).to be_nil
    end

    it 'skips running jobs and picks next pending' do
      queue.add_job('j1')
      queue.add_job('j2')
      queue.start_next
      job = queue.start_next
      expect(job.id).to eq('j2')
    end
  end

  describe '#mark_completed' do
    it 'marks a running job as completed' do
      queue.add_job('j1')
      queue.start_next
      queue.mark_completed('j1')
      expect(queue.jobs.first.status).to eq('completed')
    end

    it 'raises for a non-running job' do
      queue.add_job('j1')
      expect { queue.mark_completed('j1') }.to raise_error(RuntimeError, /invalid transition/)
    end

    it 'raises for unknown job id' do
      expect { queue.mark_completed('nope') }.to raise_error(ArgumentError, 'job not found')
    end
  end

  describe '#mark_failed' do
    it 'marks a running job as failed' do
      queue.add_job('j1')
      queue.start_next
      queue.mark_failed('j1')
      expect(queue.jobs.first.status).to eq('failed')
    end

    it 'raises for a non-running job' do
      queue.add_job('j1')
      expect { queue.mark_failed('j1') }.to raise_error(RuntimeError, /invalid transition/)
    end
  end

  describe '#retry_failed' do
    it 'requeues a failed job as pending' do
      queue.add_job('j1')
      queue.start_next
      queue.mark_failed('j1')
      queue.retry_failed('j1')
      expect(queue.jobs.first.status).to eq('pending')
    end

    it 'raises when job is not failed' do
      queue.add_job('j1')
      queue.start_next
      expect { queue.retry_failed('j1') }.to raise_error(RuntimeError, 'job is not failed')
    end

    it 'raises when max attempts reached' do
      q = described_class.new(1)
      q.add_job('j1')
      q.start_next
      q.mark_failed('j1')
      expect { q.retry_failed('j1') }.to raise_error(RuntimeError, 'max attempts reached')
    end
  end
end

RSpec.describe User do
  let(:user) { described_class.new(1) }

  it 'stores a rating for a movie' do
    user.rate('Avatar', 4)
    expect(user.rating_list['Avatar']).to eq(4)
  end

  it 'overwrites a previous rating' do
    user.rate('Avatar', 3)
    user.rate('Avatar', 5)
    expect(user.rating_list['Avatar']).to eq(5)
  end

  it 'raises for rating below 1' do
    expect { user.rate('Avatar', 0) }.to raise_error(ArgumentError)
  end

  it 'raises for rating above 5' do
    expect { user.rate('Avatar', 6) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Movie do
  it 'defaults status to unwatched' do
    movie = described_class.new('Avatar')
    expect(movie.title).to eq('Avatar')
    expect(movie.status).to eq('unwatched')
  end
end

RSpec.describe MovieQueue do
  let(:queue) { described_class.new }
  let(:user1) { User.new(1) } # rubocop:disable RSpec/IndexedLet
  let(:user2) { User.new(2) } # rubocop:disable RSpec/IndexedLet

  describe '#add_movie' do
    it 'adds a movie to the queue' do
      queue.add_movie('Avatar')
      expect(queue.movies.length).to eq(1)
      expect(queue.movies.first.title).to eq('Avatar')
    end
  end

  describe '#watch_next' do
    it 'watches the first unwatched movie and rates it' do
      queue.add_movie('Avatar')
      movie = queue.watch_next(user1, 4)
      expect(movie.status).to eq('watched')
      expect(user1.rating_list['Avatar']).to eq(4)
    end

    it 'skips already watched movies' do
      queue.add_movie('Avatar')
      queue.add_movie('Avatar 2')
      queue.watch_next(user1, 3)
      movie = queue.watch_next(user2, 5)
      expect(movie.title).to eq('Avatar 2')
    end

    it 'returns nil when all movies are watched' do
      queue.add_movie('Avatar')
      queue.watch_next(user1, 3)
      expect(queue.watch_next(user2, 4)).to be_nil
    end
  end

  describe '#list_all' do
    it 'lists all movies with statuses and ratings' do
      queue.add_movie('Avatar')
      queue.add_movie('Avatar 2')
      queue.watch_next(user1, 3)

      result = queue.list_all([user1, user2])
      expect(result[0]).to eq({ title: 'Avatar', status: 'watched', ratings: { 1 => 3 } })
      expect(result[1]).to eq({ title: 'Avatar 2', status: 'unwatched', ratings: {} })
    end
  end
end

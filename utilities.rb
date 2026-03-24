require 'set' # rubocop:disable Lint/RedundantRequireStatement

# Aggregate test results by suite name. O(n) time, O(s) space where s = unique suites.
def aggregate_hash(data)
  data.each_with_object(Hash.new { |h, k| h[k] = { total: 0, passed: 0, failed: 0, duration: 0 } }) do |entry, agg|
    suite, status, duration = entry.values_at(:suite, :status, :duration)

    agg[suite][:total] += 1
    agg[suite][:duration] += duration
    agg[suite][status.to_sym] += 1
  end
end

# Find tests that both passed and failed across runs (flaky). O(n) time, O(t) space where t = unique tests.
def find_flaky_tests(data)
  seen_statuses = Hash.new { |hash, key| hash[key] = Set.new }

  data.each do |single_data|
    seen_statuses[single_data[:test_name]] << single_data[:status]
  end
  seen_statuses.select { |_test_name, statuses| statuses.include?('passed') && statuses.include?('failed') }.keys
end

# Sliding window rate limiter. allow? is O(log n) per call via binary search eviction.
# Allows at most max_requests per key within a rolling window_seconds timeframe.
class RateLimiter
  def initialize(max_requests, window_seconds)
    @max_requests = max_requests
    @window_seconds = window_seconds
    @requests = Hash.new { |hash, key| hash[key] = [] }
  end

  def allow?(key, timestamp)
    timestamps = @requests[key]

    # # Initial solution for readability
    # # Keep only timestamps inside the rolling window
    # recent_requests.shift while recent_requests.any? && recent_requests.first <= timestamp - @window_seconds

    # if recent_requests.length < @max_requests
    #   recent_requests << timestamp
    #   true
    # else
    #   false
    # end

    cutoff = timestamp - @window_seconds

    # Binary search for the first timestamp inside the window — O(log n)
    idx = timestamps.bsearch_index { |t| t > cutoff } || timestamps.length
    timestamps.slice!(0, idx)

    if timestamps.length < @max_requests
      timestamps << timestamp
      true
    else
      false
    end
  end
end

# Data object representing a single job with an id, status, and attempt count.
class Job
  attr_accessor :id, :status, :attempts

  def initialize(id, status, attempts)
    @id = id
    @status = status
    @attempts = attempts
  end
end

# Job queue with retry behavior. Jobs transition through pending => running => completed/failed.
# Failed jobs can be retried up to max_attempts before being permanently failed.
class JobQueue
  def initialize(max_attempts)
    @max_attempts = max_attempts
    @jobs = []
  end

  def add_job(id)
    raise ArgumentError, 'duplicate job id' if find_job(id)

    @jobs << Job.new(id, 'pending', 0)
  end

  def start_next
    job = @jobs.find { |j| j.status == 'pending' }
    return nil unless job

    job.status = 'running'
    job.attempts += 1
    job
  end

  def mark_completed(id)
    job = find_job!(id)
    raise_invalid_transition(job, 'running')

    job.status = 'completed'
  end

  def mark_failed(id)
    job = find_job!(id)
    raise_invalid_transition(job, 'running')

    job.status = 'failed'
  end

  def retry_failed(id)
    job = find_job!(id)
    raise 'job is not failed' unless job.status == 'failed'
    raise 'max attempts reached' if job.attempts >= @max_attempts

    job.status = 'pending'
  end

  attr_reader :jobs

  private

  def find_job(id)
    @jobs.find { |job| job.id == id }
  end

  def find_job!(id)
    find_job(id) || raise(ArgumentError, 'job not found')
  end

  def raise_invalid_transition(job, expected_status)
    return if job.status == expected_status

    raise "invalid transition from #{job.status}"
  end
end

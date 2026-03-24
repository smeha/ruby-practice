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

# Sliding window rate limiter. O(log n) per call via binary search eviction.
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

# Find tests that both passed and failed across runs (flaky). O(n) time, O(t) space where t = unique tests.
def find_flaky_tests(data)
  seen_statuses = Hash.new { |hash, key| hash[key] = Set.new }

  data.each do |single_data|
    seen_statuses[single_data[:test_name]] << single_data[:status]
  end
  seen_statuses.select { |_test_name, statuses| statuses.include?('passed') && statuses.include?('failed') }.keys
end

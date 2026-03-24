# Aggregate test results by suite name. O(n) time, O(s) space where s = unique suites.
AGGREGATE_HASH_DATA = [
  { suite: 'models', status: 'passed', duration: 12 },
  { suite: 'models', status: 'failed', duration: 8 },
  { suite: 'api',    status: 'passed', duration: 15 }
].freeze

def aggregate_hash(data)
  data.each_with_object(Hash.new { |h, k| h[k] = { total: 0, passed: 0, failed: 0, duration: 0 } }) do |entry, agg|
    suite, status, duration = entry.values_at(:suite, :status, :duration)

    agg[suite][:total] += 1
    agg[suite][:duration] += duration
    agg[suite][status.to_sym] += 1
  end
end

# Kadane's algorithm — find the contiguous subarray with the largest sum.
# Returns [max_sum, subarray]. O(n) time, O(1) space.
# Raises ArgumentError for an empty array (no valid subarray exists).
def max_subarray(nums)
  raise ArgumentError, 'array must not be empty' if nums.empty?

  max_sum     = nums[0]
  current_sum = nums[0]
  start_idx   = 0
  best_start  = 0
  best_end    = 0

  (1...nums.length).each do |i|
    if nums[i] > current_sum + nums[i]
      current_sum = nums[i]
      start_idx   = i
    else
      current_sum += nums[i]
    end

    next unless current_sum > max_sum

    max_sum    = current_sum
    best_start = start_idx
    best_end   = i
  end

  [max_sum, nums[best_start..best_end]]
end

# QuickSort — avg O(n log n), worst O(n²) on bad pivots.
# Uses three-way partitioning to handle duplicates efficiently.
def quicksort(arr)
  return arr if arr.length <= 1

  pivot = arr[arr.length / 2]
  left  = []
  mid   = []
  right = []

  arr.each do |x|
    if x < pivot
      left << x
    elsif x > pivot
      right << x
    else
      mid << x
    end
  end

  quicksort(left) + mid + quicksort(right)
end

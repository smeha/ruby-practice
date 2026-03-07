RSpec.describe "#quicksort" do
  it "sorts an unsorted array" do
    expect(quicksort([3, 6, 8, 10, 1, 2, 1])).to eq([1, 1, 2, 3, 6, 8, 10])
  end

  it "handles an already sorted array" do
    expect(quicksort([1, 2, 3, 4, 5])).to eq([1, 2, 3, 4, 5])
  end

  it "handles a reverse-sorted array" do
    expect(quicksort([5, 4, 3, 2, 1])).to eq([1, 2, 3, 4, 5])
  end

  it "handles an array with all identical elements" do
    expect(quicksort([7, 7, 7])).to eq([7, 7, 7])
  end

  it "returns a single-element array unchanged" do
    expect(quicksort([42])).to eq([42])
  end

  it "returns an empty array unchanged" do
    expect(quicksort([])).to eq([])
  end

  it "handles negative numbers" do
    expect(quicksort([-3, 0, -1, 2])).to eq([-3, -1, 0, 2])
  end
end

RSpec.describe '#max_subarray' do
  it 'finds the max subarray in a mixed array' do
    sum, sub = max_subarray([-2, 1, -3, 4, -1, 2, 1, -5, 4])
    expect(sum).to eq(6)
    expect(sub).to eq([4, -1, 2, 1])
  end

  it 'returns the only element when given a single-element array' do
    sum, sub = max_subarray([7])
    expect(sum).to eq(7)
    expect(sub).to eq([7])
  end

  it 'handles an all-negative array by returning the least negative element' do
    sum, sub = max_subarray([-3, -1, -4, -2])
    expect(sum).to eq(-1)
    expect(sub).to eq([-1])
  end

  it 'returns the full array when all elements are positive' do
    sum, sub = max_subarray([1, 2, 3, 4])
    expect(sum).to eq(10)
    expect(sub).to eq([1, 2, 3, 4])
  end

  it 'handles a subarray at the end of the array' do
    sum, sub = max_subarray([-5, -3, 2, 4])
    expect(sum).to eq(6)
    expect(sub).to eq([2, 4])
  end

  it 'handles a subarray at the start of the array' do
    sum, sub = max_subarray([5, 3, -10, 1])
    expect(sum).to eq(8)
    expect(sub).to eq([5, 3])
  end

  it 'raises ArgumentError for an empty array' do
    expect { max_subarray([]) }.to raise_error(ArgumentError)
  end
end

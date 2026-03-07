WIZARD_URL = 'https://coderbyte.com/api/challenges/json/wizard-list'

RSpec.describe '#best_wizard_per_house' do
  it 'picks the wizard with the most friends in a house' do
    data = [
      { 'name' => 'Harry', 'house' => 'Gryffindor', 'friends' => %w[Ron Hermione] },
      { 'name' => 'Draco', 'house' => 'Gryffindor', 'friends' => ['Crabbe'] }
    ]
    expect(best_wizard_per_house(data)['Gryffindor']).to eq('Harry')
  end

  it 'handles multiple houses independently' do
    data = [
      { 'name' => 'Harry', 'house' => 'Gryffindor', 'friends' => ['Ron'] },
      { 'name' => 'Luna',  'house' => 'Ravenclaw',  'friends' => %w[Neville Ginny] }
    ]
    result = best_wizard_per_house(data)
    expect(result['Gryffindor']).to eq('Harry')
    expect(result['Ravenclaw']).to  eq('Luna')
  end

  it 'breaks ties by choosing the alphabetically earlier name' do
    data = [
      { 'name' => 'Zara', 'house' => 'X', 'friends' => ['A'] },
      { 'name' => 'Anna', 'house' => 'X', 'friends' => ['B'] }
    ]
    expect(best_wizard_per_house(data)['X']).to eq('Anna')
  end

  it 'skips characters with a nil house' do
    data = [{ 'name' => 'Ghost', 'house' => nil, 'friends' => [] }]
    expect(best_wizard_per_house(data)).to be_empty
  end

  it 'skips characters with a blank house' do
    data = [{ 'name' => 'Ghost', 'house' => '  ', 'friends' => [] }]
    expect(best_wizard_per_house(data)).to be_empty
  end

  it 'returns an empty hash for empty input' do
    expect(best_wizard_per_house([])).to eq({})
  end
end

RSpec.describe '#wizard_list_challenge' do
  let(:payload) do
    [
      { 'name' => 'Harry', 'house' => 'Gryffindor', 'friends' => %w[Ron Hermione] },
      { 'name' => 'Draco', 'house' => 'Gryffindor', 'friends' => ['Crabbe'] },
      { 'name' => 'Luna',  'house' => 'Ravenclaw',  'friends' => %w[Neville Ginny Harry] }
    ].to_json
  end

  before do
    stub_request(:get, WIZARD_URL)
      .to_return(body: payload, headers: { 'Content-Type' => 'application/json' })
  end

  it 'fetches the URL and returns the correct result' do
    result = wizard_list_challenge
    expect(result['Gryffindor']).to eq('Harry')
    expect(result['Ravenclaw']).to  eq('Luna')
  end

  it 'makes exactly one HTTP GET request' do
    wizard_list_challenge
    expect(a_request(:get, WIZARD_URL)).to have_been_made.once
  end

  it 'raises an error when the network is unavailable' do
    stub_request(:get, WIZARD_URL).to_raise(SocketError)
    expect { wizard_list_challenge }.to raise_error(SocketError)
  end
end

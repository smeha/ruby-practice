require "net/http"
require "uri"
require "json"

# Fetch the wizard-list JSON, then for each house find the character
# with the most friends. Break ties by choosing the name earliest alphabetically.
# Returns a hash of { house => character_name }.
def wizard_list_challenge
  data = fetch_wizard_list
  best_wizard_per_house(data)
end

def fetch_wizard_list
  uri = URI("https://coderbyte.com/api/challenges/json/wizard-list")
  JSON.parse(Net::HTTP.get(uri))
end

# Pure function — accepts already-parsed JSON array, returns { house => name }.
def best_wizard_per_house(data)
  result = {}

  data.each do |character|
    house = character["house"]
    next if house.nil? || house.strip.empty?

    name         = character["name"]
    friend_count = character["friends"].length

    current = result[house]
    if current.nil? ||
       friend_count > current["friends"].length ||
       (friend_count == current["friends"].length && name < current["name"])
      result[house] = character
    end
  end

  result.transform_values { |c| c["name"] }
end

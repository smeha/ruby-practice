require "webmock/rspec"
require_relative "../math"
require_relative "../strings"
require_relative "../sorting"
require_relative "../http_json_practice"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

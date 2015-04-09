ENV["RACK_ENV"] = "test"

require_relative '../lib/easy-exist'
require 'rspec'
require 'rack/test'
require 'shoulda-matchers'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
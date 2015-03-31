$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yars'
require 'rack/test'

RSpec.configure do |config|
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  config.include Rack::Test::Methods

  Kernel.srand config.seed
end

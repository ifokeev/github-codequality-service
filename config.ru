ENV['RACK_ENV'] ||= 'development'

File.expand_path('../Gemfile', __FILE__)
APP_ROOT = File.dirname(File.expand_path('./', __FILE__))
$LOAD_PATH.unshift(APP_ROOT)

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

require 'dotenv/load'

require 'server'

app = Rack::Builder.new do
  map '/' do
    run App
  end
end

run app

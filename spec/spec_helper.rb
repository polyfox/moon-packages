Encoding.default_internal = Encoding.default_external = 'UTF-8'

require 'codeclimate-test-reporter'
require 'simplecov'

def fixture_pathname(*args)
  File.join(File.dirname(__FILE__), *args)
end

CodeClimate::TestReporter.start
SimpleCov.start

require 'moon/packages'
require 'moon-mock/load'
require 'moon-inflector/load'

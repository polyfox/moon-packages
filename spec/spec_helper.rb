Encoding.default_internal = Encoding.default_external = 'UTF-8'

require 'codeclimate-test-reporter'

require 'simplecov'

CodeClimate::TestReporter.start
SimpleCov.start

require 'moon/packages'

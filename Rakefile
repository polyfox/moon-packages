require 'rubocop/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new
RuboCop::RakeTask.new

task doc: :yard
task default: [:rubocop, :doc]

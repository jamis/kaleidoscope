require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.verbose = true
  t.pattern = 'test/*_test.rb'
end

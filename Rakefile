require 'rake/gempackagetask'
require 'rake/testtask'
require './lib/kaleidoscope/version'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.verbose = true
  t.pattern = 'test/*_test.rb'
end

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Generate uniform tilings of a plane using Wythoff constructions"
  s.name = 'kaleidoscope'
  s.version = Kaleidoscope::Version::STRING
  s.files = FileList["README.md", "Rakefile", "lib/**/*.rb", "examples/**/*.rb", "test/**/*.rb"].to_a
  s.description = <<-STR
Uniform tilings are tesselations of a plane. Kaleidoscope allows you to generate them easily
simply by specifying a few parameters, and specifying the region of the plane to tesselate.
STR
  s.author = "Jamis Buck"
  s.email = "jamis@jamisbuck.org"
  s.homepage = "http://github.com/jamis/kaleidoscope"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :clean do
 rm_rf ["pkg", "*.png"]
end


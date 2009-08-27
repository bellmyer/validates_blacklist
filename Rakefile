require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'rubygems'
require 'hoe'

Hoe.new("ar_fixtures", '0.0.4') do |p|
  p.summary     = "Creates test fixtures from data in the database."
  p.description = "Methods for emitting existing data as Yaml fixtures."
  p.author = 'Jaime Bellmyer'
  p.email = 'jaime@kconrails.com'
  p.url = 'http://github.com/bellmyer/validates_blacklist'
  p.test_globs = [“test/*_test.rb”]
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the validates_blacklist plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the validates_blacklist plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ValidatesBlacklist'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

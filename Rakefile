require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "flukso4r"
    gem.summary = %Q{A Ruby Library for the Flukso Webservice}
    gem.description = %Q{This gem provides a library for the Flukso API. See http://flukso.net for more information.}
    gem.email = "md@gonium.net"
    gem.homepage = "http://gonium.net/md/flukso4r"
    gem.authors = ["Mathias Dalheimer"]
    gem.bindir = 'bin'
    gem.executables = ['bin/flukso_query']
    gem.default_executable = 'bin/flukso_query'
    gem.files = FileList["[A-Z]*", "{bin,lib,test}/**/*"]
     
    gem.add_dependency('oauth', '~> 0.3.6')
    gem.add_dependency('httparty', '~> 0.4.3')
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies
task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "flukso4r #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

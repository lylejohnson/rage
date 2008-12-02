require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'rage'
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby Agent Environment"
  
  s.author = "Lyle Johnson"
  s.email = "lyle@lylejohnson.name"
  s.homepage = "http://github.com/lylejohnson/rage/tree/master/"

  s.files  = Dir["bin/*"]
  s.files += Dir["doc/*"]
  s.files += Dir["lib/rage/**/*.rb"]
  s.files += Dir["schemas/*"]
  s.files += Dir["tests/*"]
  
  s.test_files = Dir["tests/TC_*.rb"]
  
  s.require_path = 'lib'
  s.bindir = "bin"
  s.executables << "rage"
  s.has_rdoc = true

# s.add_dependency("camping")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "doc/api"
# rdoc.main = "rdoc-sources/README.rdoc"
  rdoc.rdoc_files.add("lib/rage/*.rb")
end

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.ruby_opts << "-rubygems"
  t.test_files = FileList['tests/TC_*.rb']
  t.verbose = true
end


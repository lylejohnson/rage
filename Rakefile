require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.ruby_opts << "-rubygems"
  t.test_files = FileList['tests/TC_*.rb']
  t.verbose = true
end
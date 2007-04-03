require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

SAXON = "java -jar /Users/lyle/saxon-6.5.5/saxon.jar"
HTML_STYLESHEET = "custom-html.xsl"

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

desc "Generate the user documentation"
task :doc do
  cd "doc"
  system "#{SAXON} book.xml #{HTML_STYLESHEET}"
end

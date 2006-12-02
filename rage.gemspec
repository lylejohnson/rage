require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'rage'
  s.version = "1.0.0"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby Agent Environment"
  s.files = Dir.glob("lib/rage/*.rb")
  s.require_paths = ['lib']
  s.autorequire = 'rage'
  s.author = "Lyle Johnson"
  s.email = "lyle@knology.net"
  s.rubyforge_project = "rage"
  s.homepage = "http://rage.rubyforge.org"
end

if FILE == $0
  Gem::Builder.new(spec).build
end


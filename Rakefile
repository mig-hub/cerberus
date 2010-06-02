spec = Gem::Specification.new do |s| 
  s.name = 'cerberus'
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Rack middleware for form-based authentication"
  s.files = ['cerberus.rb', 'MIT_LICENCE', 'example.ru', 'Rakefile', 'README.rdoc', 'spec.rb']
  s.test_files = ['spec.rb']
  s.require_path = '.'
  s.autorequire = 'cerberus'
  s.author = "Mickael Riga"
  s.email = "mig@mypeplum.com"
  s.homepage = "http://github.com/mig-hub/cerberus"
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end
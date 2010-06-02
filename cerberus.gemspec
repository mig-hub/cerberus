Gem::Specification.new do |s| 
  s.name = 'cerberus'
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Rack middleware for form-based authentication"
  s.description = "A Rack middleware for form-based authentication"
  s.files = `git ls-files`.split("\n").sort
  s.test_files = ['spec.rb']
  s.require_path = '.'
  s.author = "Mickael Riga"
  s.email = "mig@mypeplum.com"
  s.homepage = "http://github.com/mig-hub/cerberus"
end
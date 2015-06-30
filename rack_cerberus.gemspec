require_relative './lib/rack/cerberus/version'

Gem::Specification.new do |s| 

  s.name = 'rack-cerberus'
  s.version = Rack::Cerberus::VERSION
  s.summary = "A Rack middleware for form-based authentication"
  s.description = "A Rack middleware for form-based authentication. It works roughly like Basic HTTP Authentication except that the authentication page can be styled with the middleware options."
  s.licenses = ['MIT']

  s.files = `git ls-files`.split("\n").sort
  s.require_path = './lib'
  s.add_dependency('rack')
  s.test_files = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ }
  s.platform = Gem::Platform::RUBY

  s.author = "Mickael Riga"
  s.email = "mig@mypeplum.com"
  s.homepage = "http://github.com/mig-hub/cerberus"

end


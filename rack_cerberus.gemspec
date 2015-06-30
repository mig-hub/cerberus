Gem::Specification.new do |s| 

  s.name = 'rack-cerberus'
  s.version = "0.3.1"
  s.summary = "A Rack middleware for form-based authentication"
  s.description = "A Rack middleware for form-based authentication. Aim is a compromise between fonctionality, beauty and customization."

  s.files = `git ls-files`.split("\n").sort
  s.require_path = './lib'
  s.add_dependency('rack')
  s.test_files = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ }
  s.platform = Gem::Platform::RUBY

  s.author = "Mickael Riga"
  s.email = "mig@mypeplum.com"
  s.homepage = "http://github.com/mig-hub/cerberus"
end

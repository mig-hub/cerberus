require 'rubygems'

gemspec = Gem::Specification.new do |s| 
  s.name = 'cerberus'
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Rack middleware for form-based authentication"
  s.description = "A Rack middleware for form-based authentication"
  s.files = ['cerberus.gemspec', 'cerberus.rb', 'MIT_LICENCE', 'example.ru', 'Rakefile', 'README.rdoc', 'spec.rb']
  s.test_files = ['spec.rb']
  s.require_path = '.'
  s.author = "Mickael Riga"
  s.email = "mig@mypeplum.com"
  s.homepage = "http://github.com/mig-hub/cerberus"
end
 
namespace :gem do
  desc "Update the gemspec for GitHub's gem server"
  task :github do
    File.open("cerberus.gemspec", 'w') { |f| f << YAML.dump(gemspec) }
  end
end
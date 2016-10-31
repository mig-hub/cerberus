# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$:.unshift lib
require 'rack/cerberus/version'

Gem::Specification.new do |s| 

  s.authors = ['Mickael Riga']
  s.email = ['mig@mypeplum.com']
  s.homepage = 'http://github.com/mig-hub/cerberus'
  s.licenses = ['MIT']

  s.name = 'rack-cerberus'
  s.version = Rack::Cerberus::VERSION
  s.summary = 'A Rack middleware for form-based authentication'
  s.description = 'A Rack middleware for form-based authentication. It works roughly like Basic HTTP Authentication except that the authentication page can be styled with the middleware options.'

  s.platform = Gem::Platform::RUBY
  s.files = `git ls-files`.split("\n").sort
  s.test_files = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ }
  s.require_paths = ['lib']

  s.add_dependency 'rack', '~> 2.0'

end


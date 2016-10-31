lib = File.expand_path('../../lib', __FILE__)
$:.unshift lib
require 'rack/cerberus'

use Rack::Session::Cookie, secret: 'change_me'

map '/' do
  run lambda {|env|
    body = <<-EOB.strip
    <html>
      <head>
        <title>Rack::Cerberus</title>
      </head>
      <body>This page is public, so you can see it. But what happens if you want to see a <a href='/secret'>Secret Page</a>? Nevertheless, I can give you access:<br /><br />
        Login: <b>mario</b><br />Pass: <b>bros</b>
      </body>
    </html>
    EOB
    [200, {'Content-Type' => 'text/html'}, [body]]
  }
end

map '/secret' do
  use Rack::Cerberus, {
    company_name: 'Nintendo', 
    fg_color: 'red', 
  } do |login,pass|
    [login,pass]==['mario','bros']
  end
  run lambda {|env|
    [
      200, {'Content-Type' => 'text/plain'}, 
      ['Welcome back Mario. Your Credit Card number is: 9292']
    ]
  }
end


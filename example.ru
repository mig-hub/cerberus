require ::File.dirname(__FILE__) + '/cerberus'
use Rack::Session::Cookie, :secret => 'change_me'
F = ::File

map '/' do
  run lambda {|env|
    body = <<-EOB.strip
    <html>
      <head>
        <title>Cerberus</title>
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
  use Cerberus, {:company_name => 'Nintendo', :fg_color => 'red', :css_location => '/css'} do |login,pass|
    [login,pass]==['mario','bros']
  end
  run lambda {|env|
    [200, {'Content-Type' => 'text/plain'}, ['Welcome back Mario. Your Credit Card number is: 9292']]
  }
end

map '/css' do
  run lambda {|env|
    path = F.expand_path('./example.css')
    [200, {'Content-Type' => 'text/css', "Last-Modified"  => F.mtime(path).httpdate, "Content-Length" => F.size?(path).to_s}, [F.read(path)]]
  }
end

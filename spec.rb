require 'rubygems'
require 'bacon'
require 'rack'

require ::File.dirname(__FILE__) + '/cerberus'

Bacon.summary_on_exit

describe 'cerberus' do
  
  secret_app = lambda {|env| [200, {'Content-Type'=>'text/plain'}, env['rack.session'].inspect] }
  app = Rack::Session::Cookie.new(Cerberus.new(secret_app, {}) {|login,pass| [login,pass]==['mario','bros']})
  req = Rack::MockRequest.new(app)
  cookie = ''
  
  should 'Stop request if you are not already logged in or currently successfully logging' do
    res = req.get('/')
    res.status.should==401
    res = req.post('/', :params => {'cerberus_login' => 'fake', 'cerberus_pass' => 'fake'})
    res.status.should==401
  end
  
  should 'Give access with the appropriate login and pass' do
    res = req.post('/', :params => {'cerberus_login' => 'mario', 'cerberus_pass' => 'bros'})
    cookie = res["Set-Cookie"]
    res.status.should==200
  end
  
  should 'Use session for persistent login' do
    res = req.get('/', "HTTP_COOKIE" => cookie)
    res.status.should==200
    res.body.should=='{"cerberus_user"=>"mario"}'
    cookie = res["Set-Cookie"]
    req.get('/', "HTTP_COOKIE" => cookie).status.should==200
  end
  
  should 'Logout via /logout path' do
    res = req.get('/logout', "HTTP_COOKIE" => cookie)
    res.status.should==401
    cookie = res["Set-Cookie"]
    res = req.get('/', "HTTP_COOKIE" => cookie)
    res.status.should==401
  end
  
end
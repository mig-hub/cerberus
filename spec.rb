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
  
  should 'Raise if there is no session' do
    no_session_app = Cerberus.new(secret_app, {}) {|login,pass| [login,pass]==['mario','bros']}
    no_session_req = Rack::MockRequest.new(no_session_app)
    lambda { no_session_req.get('/') }.should.raise(Cerberus::NoSessionError).message.should=='Cerberus cannot work without Session'
  end
  
  should 'Stop request if you are not already logged in' do
    res = req.get('/')
    res.status.should==401
    res.body.class==String
    res.body.should.match(/name="cerberus_login" value="login"/)
    res.body.should.match(/name="cerberus_pass" value="pass"/)
  end
  
  should 'Stop request if you send wrong details and keep query values' do
    res = req.post('/', :params => {'cerberus_login' => 'fake_login', 'cerberus_pass' => 'fake_pass'})
    res.status.should==401
    res.body.should.match(/name="cerberus_login" value="fake_login"/)
    res.body.should.match(/name="cerberus_pass" value="fake_pass"/)
  end
  
  should 'Give access with the appropriate login and pass' do
    res = req.get('/', :params => {'cerberus_login' => 'mario', 'cerberus_pass' => 'bros'})
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
  
  should 'Not send not_found when logging after a logout (because the path is /logout)' do
    res = req.get('/logout', :params => {'cerberus_login' => 'mario', 'cerberus_pass' => 'bros'})
    res.status.should==302
    res['Location'].should=='/'
    
    req = Rack::MockRequest.new(Rack::URLMap.new({'/backend' => app}))
    res = req.get('/backend/logout', :params => {'cerberus_login' => 'mario', 'cerberus_pass' => 'bros'})
    res.status.should==302
    res['Location'].should=='/backend'
  end
  
end
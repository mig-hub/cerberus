require 'rack/cerberus'

RSpec.describe Rack::Cerberus do
  
  let(:secret_app) {
    lambda {|env| 
      [200, {'Content-Type'=>'text/plain'}, env['rack.session'].inspect] 
    }
  }

  let(:cerberus_app) {
    Rack::Cerberus.new(secret_app, cerberus_options) do |login,pass| 
      [login,pass]==['mario@nintendo.com','bros']
    end
  }

  let(:app) {
    Rack::URLMap.new({
      mount_path => Rack::Session::Cookie.new(cerberus_app, {secret: '42'})
    })
  }

  let(:cerberus_options) { {} }
  let(:mount_path) { '/' }
  
  before :each do
    clear_cookies
  end

  context 'No session is set' do
    let(:app) { cerberus_app }
    it 'Raises' do
      expect{ get('/') }.to raise_error(Rack::Cerberus::NoSessionError)
    end
  end
  
  context 'Not logged in' do
    it 'Stops requests' do
      get '/'
      expect(last_response.status).to eq 401
      body = last_response.body
      expect(body.class).to eq String
      expect(body).to match(/name="cerberus_login" value=""/)
      expect(body).to match(/name="cerberus_pass" value=""/)
    end
  end
  
  describe 'Logging in' do

    context 'Login details are incorrect' do
      it 'Stops requests' do
        post('/', {'cerberus_login' => 'fake_login', 'cerberus_pass' => 'fake_pass'})
        expect(last_response.status).to eq 401
        expect(last_response.body).to match(/Wrong login or password/)
      end
      it 'Keeps what was entered in the fields' do
        post('/', {'cerberus_login' => 'fake_login', 'cerberus_pass' => 'fake_pass'})
        expect(last_response.body).to match(/name="cerberus_login" value="fake_login"/)
        expect(last_response.body).to match(/name="cerberus_pass" value="fake_pass"/)
      end
      it 'Escapes HTML on submitted info' do
        post('/', {'cerberus_login' => '<script>bad</script>', 'cerberus_pass' => '<script>bad</script>'})
        expect(last_response.body).to match(/name="cerberus_login" value="&lt;script&gt;bad&lt;\/script&gt;"/)
        expect(last_response.body).to match(/name="cerberus_pass" value="&lt;script&gt;bad&lt;\/script&gt;"/)
      end
    end

    context 'Login details are correct' do
      it 'Gives access' do
        get('/', {'cerberus_login' => 'mario@nintendo.com', 'cerberus_pass' => 'bros'})
        expect(last_response.status).to eq 200
      end
    end

  end
  
  describe 'Already logged in' do
  
    it 'Uses session for persistent login' do
      get('/', {'cerberus_login' => 'mario@nintendo.com', 'cerberus_pass' => 'bros'})
      get('/')
      expect(last_response.status).to eq 200
      expect(last_response.body).to include('"cerberus_user"=>"mario@nintendo.com"}')
    end

  end
  
  describe 'Logout' do

    let(:mount_path) { '/admin' }

    it 'Happens via /logout path' do
      get('/admin/', {'cerberus_login' => 'mario@nintendo.com', 'cerberus_pass' => 'bros'})
      expect(last_response.status).to eq 200
      get('/admin/logout')
      expect(last_response.status).to eq 401
    end

    it 'Never redirects to the logout path' do
      get('/admin/logout', {'cerberus_login' => 'mario@nintendo.com', 'cerberus_pass' => 'bros'})
      expect(last_response.status).to eq 302
      expect(last_response['Location']).to eq '/admin'
    end

  end
  
  describe 'Options' do

    it 'Does not link CSS by default' do
      get('/')
      expect(last_response.body).not_to match(/<link/)
    end

    context 'CSS option is used' do
      let(:cerberus_options) { {:css_location=>'/main.css'} }
      it 'Links the CSS file' do
        get('/')
        expect(last_response.body).to match(/<link/)
      end
    end

    context 'Session key is different' do
      let(:cerberus_options) { {session_key: 'different_user'} }
      it 'Uses the session key of the options' do
        get('/', {'cerberus_login' => 'mario@nintendo.com', 'cerberus_pass' => 'bros'})
        get('/')
        expect(last_response.status).to eq 200
        expect(last_response.body).to include('"different_user"=>"mario@nintendo.com"}')
      end
    end

  end
  
end

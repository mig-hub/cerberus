require 'minitest/autorun'
require 'rack/test'
require 'rack/cerberus'

ENV['RACK_ENV'] = 'test'

class TestRackCerberus < Minitest::Test
  parallelize_me!
  
  include Rack::Test::Methods

  def secret_app
    lambda {|env| 
      [
        200, 
        {'Content-Type'=>'text/plain'}, 
        ["#{env['REQUEST_METHOD']} #{env['rack.session'].inspect}"]
      ] 
    }
  end

  def cerberus_app cerberus_options={}
    Rack::Cerberus.new(secret_app, cerberus_options) do |login,pass| 
      [login,pass]==['mario@nintendo.com','bros']
    end.freeze
  end

  def mounted_app mount_path='/', cerberus_options={}
    Rack::URLMap.new({
      mount_path => Rack::Session::Cookie.new(cerberus_app(cerberus_options), {secret: '42'})
    })
  end

  def app; Rack::Lint.new(@app); end

  def body
    last_response.body
  end

  def correct_logins
    {
      'cerberus_login' => 'mario@nintendo.com', 
      'cerberus_pass' => 'bros'
    }
  end

  def wrong_logins
    {
      'cerberus_login' => 'fake_login', 
      'cerberus_pass' => 'fake_pass'
    }
  end

  def setup
    @app = mounted_app
  end

  def teardown
    clear_cookies
  end

  def test_no_session_raises
    @app = cerberus_app
    assert_raises(Rack::Cerberus::NoSessionError) do
      get '/'
    end
  end
  
  def test_unauthorized_when_not_logged_in
    get '/'
    assert_equal 401, last_response.status
    assert_equal String, body.class
    assert_match 'name="cerberus_login" value=""', body
    assert_match 'name="cerberus_pass" value=""', body
  end

  def test_unauthorized_when_logins_are_incorrect
    get '/', wrong_logins
    assert_equal 401, last_response.status
    assert_match 'Wrong login or password', body
  end

  def test_fields_filled_with_previous_info
    post '/', wrong_logins
    assert_match 'name="cerberus_login" value="fake_login"', body
    assert_match 'name="cerberus_pass" value="fake_pass"', body
  end

  def test_submitted_info_is_html_escaped
    post('/', {
      'cerberus_login' => '<script>bad</script>', 
      'cerberus_pass' => '<script>bad</script>'
    })
    assert_match 'bad', body
    refute_match '<script>bad</script>', body
  end

  def test_authorized_when_logins_are_correct
    get '/', correct_logins
    assert_equal 200, last_response.status
  end

  def test_calls_final_page_with_original_method
    get '/'
    assert_match 'name="_method" value="GET"', body
    post '/', correct_logins.merge({'_method'=>'GET'})
    assert_match(/^GET/, body)
  end
  
  def test_stay_authorized_once_logged
    get '/', correct_logins
    get '/'
    assert_equal 200, last_response.status
    assert_match '"cerberus_user"=>"mario@nintendo.com"', body
  end

  def test_logout_with_logout_path
    @app = mounted_app '/admin'
    get '/admin/', correct_logins
    assert_equal 200, last_response.status
    get '/admin/logout'
    assert_equal 401, last_response.status
  end

  def test_never_redirects_to_logout_path
    @app = mounted_app '/admin'
    get '/admin/logout', correct_logins
    assert_equal 302, last_response.status
    assert_equal '/admin', last_response['Location']
  end
  
  # Options

  def test_no_css_location
    get '/'
    refute_match '<link', body 
  end

  def test_css_location
    @app = mounted_app '/', css_location: '/main.css'
    get '/'
    assert_match '<link', body
    assert_match '/main.css', body
  end
  
  def test_can_change_session_key
    @app = mounted_app '/', session_key: 'different_user'
    get '/', correct_logins
    get '/'
    assert_equal 200, last_response.status
    assert_match '"different_user"=>"mario@nintendo.com"', body
  end

  def test_forgot_password_uri_when_logins_provided
    @app = mounted_app '/', forgot_password_uri: '/forgot-password'
    post '/', wrong_logins
    assert_equal 401, last_response.status
    assert_match(/form action="\/forgot-password" method="post"/, body)
    assert_match(/type="hidden" name="cerberus_login" value="fake_login"/, body)
  end

  def test_forgot_password_uri_when_logins_not_provided
    @app = mounted_app '/', forgot_password_uri: '/forgot-password'
    post '/'
    assert_equal 401, last_response.status
    refute_match(/form action="\/forgot-password" method="post"/, body)
    refute_match(/type="hidden" name="cerberus_login" value="fake_login"/, body)
  end

  def test_no_forgot_password_form_when_no_uri
    post '/', wrong_logins
    assert_equal 401, last_response.status
    refute_match(/form action="\/forgot-password" method="post"/, body)
  end

  def test_forgot_password_submitted_info_is_html_escaped
    @app = mounted_app '/', forgot_password_uri: '/forgot-password'
    post('/', {
      'cerberus_login' => '<script>bad</script>', 
      'cerberus_pass' => '<script>bad</script>'
    })
    assert_match 'bad', body
    refute_match '<script>bad</script>', body
  end

end


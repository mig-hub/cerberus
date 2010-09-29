class Cerberus
  
  class NoSessionError < RuntimeError
  end
  
  AUTH_PAGE = <<-PAGE
  <html><head>
    <title>%s Authentication</title>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <style type='text/css'>
    body { background-color: %s; font-family: sans-serif; text-align: center; }
    h1, p { color: %s; }
    .err {
      padding: 5px;
      border-radius: 5px;
      -moz-border-radius: 5px;
      -webkit-border-radius: 5px;
      color: white;
      background-color: red;
    }
    div { 
      text-align: left;
      width: 400px;
      margin: 30px auto;
      padding: 10px;
      border-radius: 5px;
      -moz-border-radius: 5px;
      -webkit-border-radius: 5px;
      background-color: %s; }
    input { width: 400px; font-size: 20px; }
    </style>
  </head><body>
  <div>
    <h1>%s</h1>
    %s
    %s
    <p>Please Sign In</p>
    <form action="%s" method="post" accept-charset="utf-8">	
    	<input type="text" name="cerberus_login" value="login" id='login'><br />
    	<input type="password" name="cerberus_pass" value="pass" id='pass'>
    	<p><input type="submit" value="SIGN IN &rarr;"></p>
    </form>
    <script type="text/javascript" charset="utf-8">
    	var login = document.getElementById('login');
    	var pass = document.getElementById('pass');
    	focus = function() {
    		if (this.value==this.id) this.value = '';
    	}
    	blur = function() {
    		if (this.value=='') this.value = this.id;
    	}	
    	login.onfocus = focus;
    	pass.onfocus = focus;
    	login.onblur = blur;
    	pass.onblur = blur;
    </script>
  </div>
  </body></html>
PAGE
  
  def initialize(app, options={}, &block)
    @app = app
    defaults = { :company_name => 'Cerberus', :bg_color => '#333', :fg_color => '#555', :icon_url => nil}
    @options = defaults.merge(options)
    @block = block
  end
  
  def call(env)
    dup._call(env)
  end
  
  def _call(env)
    raise(NoSessionError, 'Cerberus cannot work without Session') if env['rack.session'].nil?
    req = Rack::Request.new(env)
    login = req['cerberus_login']
    pass = req['cerberus_pass']
    err = req.post? ? "<p class='err'>Wrong login or password</p>" : ''
    if ((env['rack.session']['cerberus_user']!=nil && env['PATH_INFO']!='/logout') || (login && pass && @block.call(login, pass)))
      env['rack.session']['cerberus_user'] ||= login
      if env['PATH_INFO']=='/logout'
        res = Rack::Response.new(env)
        res.redirect(env['SCRIPT_NAME']=='' ? '/' : env['SCRIPT_NAME'])
        res.finish
      else
        @app.call(env)
      end
    else
      env['rack.session'].delete('cerberus_user')
      icon = @options[:icon_url].nil? ? '' : "<img src='#{@options[:icon_url]}' /><br />"
      [401, {'Content-Type' => 'text/html'}, AUTH_PAGE % [@options[:company_name], @options[:bg_color], @options[:bg_color], @options[:fg_color], @options[:company_name], icon, err, env['REQUEST_URI']]]
    end
  end
  
end
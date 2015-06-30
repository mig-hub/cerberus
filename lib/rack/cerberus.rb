require 'rack/utils'

module Rack

  class Cerberus
    
    class NoSessionError < RuntimeError; end
    
    def initialize(app, options={}, &block)
      @app = app
      defaults = { 
        company_name: 'Cerberus', 
        bg_color: '#999', 
        fg_color: '#CCC', 
        text_color: '#FFF', 
        icon_url: nil,
        session_key: 'cerberus_user'
      }
      @options = defaults.merge(options)
      @options[:icon] = @options[:icon_url].nil? ? '' : "<img src='#{@options[:icon_url]}' /><br />"
      @options[:css] = @options[:css_location].nil? ? '' : "<link href='#{@options[:css_location]}' rel='stylesheet' type='text/css'>"
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
      if ((env['rack.session'][@options[:session_key]]!=nil && env['PATH_INFO']!='/logout') || (login && pass && @block.call(login, pass, req)))
        env['rack.session'][@options[:session_key]] ||= login
        if env['PATH_INFO']=='/logout'
          res = Rack::Response.new(env)
          res.redirect(env['SCRIPT_NAME']=='' ? '/' : env['SCRIPT_NAME'])
          res.finish
        else
          @app.call(env)
        end
      else
        env['rack.session'].delete(@options[:session_key])
        [
          401, {'Content-Type' => 'text/html'}, 
          [AUTH_PAGE % @options.merge({
            error: err, submit_path: env['REQUEST_URI'],
            login: Rack::Utils.escape_html(login), 
            pass: Rack::Utils.escape_html(pass)
          })]
        ]
      end
    end
    
    AUTH_PAGE = <<-PAGE
    <!DOCTYPE html>
    <html><head>
      <title>%{company_name} Authentication</title>
      <meta http-equiv="content-type" content="text/html; charset=utf-8" />
      <style type='text/css'>
      * {
        -moz-box-sizing: border-box;
        -ms-box-sizing: border-box;
        box-sizing: border-box;
      }
      body { background-color: %{bg_color}; font-family: sans-serif; text-align: center; margin: 0px; }
      h1, p { color: %{text_color}; }
      .err {
        padding: 1em;
        border-radius: 3px;
        -moz-border-radius: 3px;
        -webkit-border-radius: 3px;
        color: white;
        background-color: red;
      }
      div { 
        text-align: left;
        width: 500px;
        margin: 0px auto;
        padding: 2em;
        -webkit-border-bottom-left-radius: 3px;
        -moz-border-radius-bottomleft: 3px;
        border-bottom-left-radius: 3px;
        -webkit-border-bottom-right-radius: 3px;
        -moz-border-radius-bottomright: 3px;
        border-bottom-right-radius: 3px;
        -moz-box-shadow: 0px 0px 5px #333;
        -webkit-box-shadow: 0px 0px 5px #555;
        box-shadow: 0px 0px 5px #555;
        background-color: %{fg_color}; }
      input[type=text], input[type=password] { 
        display: block; width: 100%%; padding: 0.5em; 
        border: 0px; font-size: 1.25em; 
      }
      </style>
      %{css}
    </head><body>
    <div>
      <h1>%{company_name}</h1>
      %{icon}
      %{error}
      <p>Please Sign In</p>
      <form action="%{submit_path}" method="post" accept-charset="utf-8">	
        <input type="text" name="cerberus_login" value="%{login}" id='login' title='Login' placeholder='Login'><br />
        <input type="password" name="cerberus_pass" value="%{pass}" id='pass' title='Password' placeholder='Password'>
        <p><input type="submit" value="SIGN IN &rarr;"></p>
      </form>
      <script type="text/javascript" charset="utf-8">
        var login = document.getElementById('login');
        var pass = document.getElementById('pass');
        var focus = function() {
          if (this.value==this.id) this.value = '';
        }
        var blur = function() {
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
    
  end

end


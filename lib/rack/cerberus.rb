class Rack

  class Cerberus
    
    class NoSessionError < RuntimeError; end
    
    AUTH_PAGE = <<-PAGE
    <!DOCTYPE html>
    <html><head>
      <title>%s Authentication</title>
      <meta http-equiv="content-type" content="text/html; charset=utf-8" />
      <style type='text/css'>
      body { background-color: %s; font-family: sans-serif; text-align: center; margin: 0px; }
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
        margin: 0px auto;
        padding: 10px;
        -webkit-border-bottom-left-radius: 10px;
        -moz-border-radius-bottomleft: 10px;
        border-bottom-left-radius: 10px;
        -webkit-border-bottom-right-radius: 10px;
        -moz-border-radius-bottomright: 10px;
        border-bottom-right-radius: 10px;
        -moz-box-shadow: 0px 0px 5px #333;
        -webkit-box-shadow: 0px 0px 5px #333;
        box-shadow: 0px 0px 5px #333;
        background-color: %s; }
      input[type=text], input[type=password] { width: 392px; padding: 4px; border: 0px; font-size: 20px; }
      </style>
      %s
    </head><body>
    <div>
      <h1>%s</h1>
      %s
      %s
      <p>Please Sign In</p>
      <form action="%s" method="post" accept-charset="utf-8">	
        <input type="text" name="cerberus_login" value="%s" id='login'><br />
        <input type="password" name="cerberus_pass" value="%s" id='pass'>
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
    
    def initialize(app, options={}, &block)
      @app = app
      defaults = { 
        :company_name => 'Cerberus', 
        :bg_color => '#999', 
        :fg_color => '#CCC', 
        :text_color => '#FFF', 
        :icon_url => nil
      }
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
      if ((env['rack.session']['cerberus_user']!=nil && env['PATH_INFO']!='/logout') || (login && pass && @block.call(login, pass, req)))
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
        css = @options[:css_location].nil? ? '' : "<link href='#{@options[:css_location]}' rel='stylesheet' type='text/css'>"
        [
          401, {'Content-Type' => 'text/html'}, 
          [AUTH_PAGE % [
            @options[:company_name], @options[:bg_color], @options[:text_color], @options[:fg_color], css, @options[:company_name], 
            icon, err, env['REQUEST_URI'], html_escape(req['cerberus_login']||'login'), html_escape(req['cerberus_pass']||'pass')
          ]]
        ]
      end
    end
    
    private
    
    # Stolen from ERB
    def html_escape(s)
      s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end
    
  end

end

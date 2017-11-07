require 'rack/utils'
require 'rack/cerberus/version'

module Rack

  class Cerberus
    
    class NoSessionError < RuntimeError; end

    def self.new(*); ::Rack::MethodOverride.new(super); end
    
    def initialize app, options={}, &block
      @app = app
      defaults = { 
        company_name: 'Cerberus', 
        bg_color: '#93a1a1', 
        fg_color: '#002b36', 
        text_color: '#fdf6e3', 
        session_key: 'cerberus_user',
        forgot_password_uri: nil
      }
      @options = defaults.merge(options)
      @options[:icon] = @options[:icon_url].nil? ? 
        '' : 
        "<img src='#{@options[:icon_url]}' /><br />"
      @options[:css] = @options[:css_location].nil? ? 
        '' : 
        "<link href='#{@options[:css_location]}' rel='stylesheet' type='text/css'>"
      @block = block
    end
    
    def call env
      dup._call(env)
    end
    
    def _call env
      ensure_session env
      req = Rack::Request.new env
      if (logged?(req) and !logging_out?(req)) or authorized?(req)
        ensure_logged! req
        if logging_out? req
          logout_response req
        else
          @app.call env
        end
      else
        form_response req
      end
    end

    private

    def ensure_session env
      if env['rack.session'].nil?
        raise(NoSessionError, 'Cerberus cannot work without Session') 
      end
    end

    def h text
      Rack::Utils.escape_html text
    end

    def login req
      req.params['cerberus_login']
    end

    def pass req
      req.params['cerberus_pass']
    end

    def logged? req
      req.env['rack.session'][@options[:session_key]]!=nil
    end

    def provided_fields? req
      login(req) and pass(req)
    end

    def authorized? req
      provided_fields?(req) and 
      @block.call login(req), pass(req), req
    end

    def ensure_logged! req
      req.env['rack.session'][@options[:session_key]] ||= login(req)
    end

    def ensure_logged_out! req
      req.env['rack.session'].delete @options[:session_key]
    end

    def logging_out? req
      req.path_info=='/logout'
    end

    def logout_response req
      res = Rack::Response.new
      res.redirect(req.script_name=='' ? '/' : req.script_name)
      res.finish
    end

    def form_response req
      if provided_fields? req
        error = "<p class='err'>Wrong login or password</p>"
        unless @options[:forgot_password_uri].nil?
          forgot_password = FORGOT_PASSWORD % {
            action: @options[:forgot_password_uri],
            login: h(login(req))
          }
        end
      end
      ensure_logged_out! req
      [
        401, {'Content-Type' => 'text/html'}, 
        [AUTH_PAGE % @options.merge({
          error: error, submit_path: h(req.env['REQUEST_URI']),
          forgot_password: forgot_password,
          request_method: req.request_method,
          login: h(login(req)), 
          pass: h(pass(req))
        })]
      ]
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
        background-color: #dc322f;
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
        background-color: %{text_color};
      }
      input[type=submit] {
        background-color: %{bg_color};
        color: %{fg_color};
        padding: 0.5em;
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
        border: 0;
        cursor: pointer;
      }
      input[type=submit]:hover { background-color: %{text_color}; }
      ::-webkit-input-placeholder { color: %{bg_color}; }
      :-moz-placeholder { color: %{bg_color}; }
      ::-moz-placeholder { color: %{bg_color}; }
      :-ms-input-placeholder { color: %{bg_color}; }
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
        <input type="hidden" name="_method" value="%{request_method}">
        <p><input type="submit" value="SIGN IN &rarr;"></p>
      </form>
      %{forgot_password}
    </div>
    </body></html>
    PAGE
    
    FORGOT_PASSWORD = <<-FORM
    <form action="%{action}" method="post" accept-charset="utf-8">	
      <input type="hidden" name="cerberus_login" value="%{login}" />
      <p><input type="submit" value="Forgot your password? &rarr;"></p>
    </form>
    FORM

  end

end


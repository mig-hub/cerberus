>"For over a thousand generations the Jedi Knights were the guardians of peace and justice in the Old Republic. Before the dark times, before the Empire." -- Obi-Wan Kenoby

Rack::Cerberus
==============

Rack::Cerberus is a Rack middleware for form-based authentication. Its purpose is only 
to offer a nicer replacement for Basic HTTP authentication.

Install with:

    # sudo gem install rack-cerberus

You can use it almost the same way you use `Rack::Auth::Basic`:

    require 'rack/cerberus'
    use Rack::Session::Cookie, :secret => 'change_me'
    use Rack::Cerberus do |login, pass|
      pass=='secret'
    end
	
Like in that example, make sure you have a session, because Rack::Cerberus use it for
persistent login.
	
There is an optional hash you can add for customisation it. Options are:

- `:company_name`
- `:fg_color` (foreground color)
- `:bg_color` (background color)
- `:text_color`
- `:icon_url` (for a company logo or any icon)
- `:css_location`

Which is used that way:

    use Rack::Cerberus, {:company_name => 'Nintendo'} do |login, pass|
      pass=='secret'
    end
	
The purpose of Rack::Cerberus is to be basic, which is why there are enough options to have
a page fairly customized with colors and logo (`:icon_url`). The logo can even replace
the company name if you leave `:company_name` blank. But should you be fussy, this is possible
to have more control using an external CSS file with the option `:css_location`.

Just like `Rack::Auth::Basic`, Rack::Cerberus yields login and pass, and delegate authentication
to the block you send it which should return a boolean.

If you want to see a concrete example, go into the Rack::Cerberus directory and run:

    # rackup example.ru
	
It's gonna start the example at http://localhost:9292

You can also use the 3rd argument which is the request object:

use Rack::Cerberus, {:company_name => 'Nintendo'} do |login, pass, req|
  pass=='secret' && req.xhr?
end

This is more if you use it as a gateway for an API or something and you want to check other values.
Like the referer or another parameter.
But bear in mind that `cerberus_login` and `cerberus_pass` are still mandatory.

Logout
------

Any request to `/logout` on the path where the middleware is mounted will log you out.
In other words, if you put the middleware at `/admin`, query `/admin/logout` to be
logged out. Pretty simple.

Help
----

If you want to help me, don't hesitate to fork that project on Github or send patches.

Changelog
---------

	0.0.1 Changed Everything somehow
	0.1.0 Make it possible to authenticate through GET request (for restful APIs)
	0.1.1 Documentation improvement
	0.1.2 Raise message when using without session
	0.1.3 Don't go to page /logout when signing in after a logout (redirect to / instead)
	0.1.4 Fix /logout redirect so that it works with mapping
	0.1.5 Fix CSS and Javascript for IE (Yes I'm too kind)
	0.1.6 Send an Array instead of a string to Rack so that it works on Ruby 1.9
	0.2.0 External CSS file + `:text_color` option + keep details after login failure
	0.3.0 Now sends request as a 3rd argument to the block
	0.3.1 Escape HTML in fields now that they are kept

Copyright
---------

(c) 2010-2015 Mickael Riga - see MIT_LICENCE for details 

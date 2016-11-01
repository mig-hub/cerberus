Rack::Cerberus
==============

`Rack::Cerberus` is a Rack middleware for form-based authentication. 
It works roughly like Basic HTTP authentication except that you can use
options in order to style the authentication page.

Install with:

```
# gem install rack-cerberus
```

Or in your `Gemfile`:

```ruby
gem 'rack-cerberus'
```

You can use it almost the same way you use `Rack::Auth::Basic`:

```ruby
require 'rack/cerberus'
use Rack::Session::Cookie, secret: 'change_me'
use Rack::Cerberus do |login, pass|
  pass=='secret'
end
```
	
Like in that example, make sure you have a session, because 
`Rack::Cerberus` uses it for persistent login, and make sure it is encrypted.
	
Options
-------

There is an optional hash you can add for customisation it. Options are:

- `:company_name`
- `:bg_color` (Background color)
- `:fg_color` (Actually the color of the box color)
- `:text_color`
- `:icon_url` (For a company logo or any icon)
- `:css_location` (Path to a CSS file for a complete reskin)
- `:session_key` (Where login name is kept. Default is `cerberus_user`)

Which is used that way:

```ruby
use Rack::Cerberus, {company_name: 'Nintendo'} do |login, pass|
  pass=='secret'
end
```
	
The purpose of `Rack::Cerberus` is to be basic, which is why there are 
enough options to have a page fairly customized with colors and 
logo (`:icon_url`). The logo can even replace the company name if 
you leave `:company_name` blank. But should you be fussy, this is possible
to have more control using an external CSS file with the option `:css_location`.

Authentication
--------------

Just like `Rack::Auth::Basic`, `Rack::Cerberus` yields login and pass, 
and delegate authentication to the block you send it which should 
return `true` or `false`.

You can also use the 3rd argument which is the request object:

```ruby
use Rack::Cerberus, {company_name: 'Nintendo'} do |login, pass, req|
  pass=='secret' && req.xhr?
end
```

This is useful if you want to check other details of the request.
Like the referer or another parameter. But bear in mind that `cerberus_login` and `cerberus_pass` are still mandatory.

Example
-------

If you want to see a concrete example, go into the `example/` directory and run:

```
# rackup
```
	
It's gonna start the example at `http://localhost:9292`

Logout
------

Any request to `/logout` on the path where the middleware is mounted 
will log you out. In other words, if you put the middleware at `/admin`, 
query `/admin/logout` to be logged out. Pretty simple.

Help
----

If you want to help me, don't hesitate to fork that project on Github 
or send patches.

Copyright
---------

(c) 2010-2016 Mickael Riga - see `MIT_LICENSE` for details 


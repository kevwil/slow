This Ruby script is a Sinatra app (http://sinatrarb.com).
To run it, you need:
* ruby (1.8.7 is best, should work in 1.9.2, might work in jruby, etc.)
* rubygems
* sinatra gem
* rack-contrib gem

call this file like this: (you need to be root to listen on a port < 1024)
    (sudo) ruby -rubygems slow.rb -p 80 -e production

This will listen like a server but will run in the foreground.
You need to use the config.ru file to run in the background. Read that file for details.

or, to skip the port, environment, and rubygems
parts, you can uncomment the rubygems and
config variables lines below. Uncommenting the
Rack::Lint part will just slow the server down.


To call the service, any request path (URI after server and port) will work.
* curl -i http://localhost/foo/bar/baz
* curl -i http://localhost/Affinity/v1/session/create

Other HTTP verbs also work, specifically GET, POST, PUT, DELETE, and HEAD.
* curl -i -XHEAD http://localhost/foo/bar
* curl -i -XPUT http://localhost/foo/bar
* curl -i -XDELETE http://localhost/foo/bar
* curl -i -XPOST -d "post_param1=hello&post_param2=world" http://localhost/foo/bar

The script supports POST method override, too.
* curl -i -XPOST -d "_method=PUT&param1=update_me" http://localhost/my/personal/info

There are two optional querystring parameters you can provide to tweak the behavior.
* To return a specific error code, with debug info in the body:
** curl -i http://localhost/foo/bar/baz?errorcode=403
* To fail after the timeout is complete, rather than returning a successful 200 OK status.
** curl -i http://localhost/foo?fail=true
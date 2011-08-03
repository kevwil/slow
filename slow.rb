##########################
# This Ruby script is a Sinatra app (http://sinatrarb.com).
# To run it, you need:
# * ruby (1.8.7 is best, should work in 1.9.2, might work in jruby, etc.)
# * rubygems
# * sinatra gem
# * rack-contrib gem
#
# call this file like this: (you need to be root to listen on a port < 1024)
# (sudo) ruby -rubygems slow.rb -p 80 -e production
#
# This will listen like a server but will run in the foreground.
# You need to use the config.ru file to run in the background. Read that file for details.
#
# or, to skip the port, environment, and rubygems
# parts, you can uncomment the rubygems and
# config variables lines below. Uncommenting the
# Rack::Lint part will just slow the server down.
#
#
# To call the service, any request path (URI after server and port) will work.
# * curl -i http://localhost/foo/bar/baz
# * curl -i http://localhost/Affinity/v1/session/create
#
# Other HTTP verbs also work, specifically GET, POST, PUT, DELETE, and HEAD.
# * curl -i -XHEAD http://localhost/foo/bar
# * curl -i -XPUT http://localhost/foo/bar
# * curl -i -XDELETE http://localhost/foo/bar
# * curl -i -XPOST -d "post_param1=hello&post_param2=world" http://localhost/foo/bar
#
# The script supports POST method override, too.
# * curl -i -XPOST -d "_method=PUT&param1=update_me" http://localhost/my/personal/info
#
# The script supports a proxy behavior, where it will call the same URI on a remote host
# after the timeout has expired, and return the result.
# * curl -i "http://localhost/foo?proxyTo=http%3A%2F%2Flocalhost%3A8080"
#
# A default proxy can be set using the _proxy_ value below
#
# There are three optional querystring parameters you can provide to tweak the behavior.
# * To return a specific error code, with debug info in the body:
# ** curl -i http://localhost/foo/bar/baz?errorcode=403
# * To fail after the timeout is complete, rather than returning a successful 200 OK status.
# ** curl -i http://localhost/foo?fail=true
# * To timeout for a specific period other then the default of 5000 milliseconds
# ** curl -i "http://localhost/foo?timeout=10000"
##########################
 
### gems required to make this file run as a web server
# require 'rubygems'
require 'sinatra'
require 'rack/contrib'
require 'net/http'
require 'uri'
require 'cgi'

### extra Rack middleware to help this run correctly
# use Rack::Lint
use Rack::BounceFavicon
# use Rack::Lint
 
### it's tempting to add this Middleware to enable throttling
# http://datagraph.rubyforge.org/rack-throttle/
 
### config variables when run in foreground
# set :environment, :production
# set :port, 80
set :method_override, true
 
### the app itself :

# set this value to use a default target host when proxying
# (set to protocol://host or protocol://host:port)
# proxy = 'http://localhost:8080'
proxy = nil # variable must be defined, so set it to nil if not using it

# all five HTTP methods do the same thing
%w{get post put delete head}.each do |method|
  # call the method for each HTTP method, with a wildcard path
  send method.to_sym, '/*' do
    # This checks to see if the "timeout" param was included in the URL and sets the timeout
    if params[:timeout]
      timeout = params[:timeout].to_i
    else
      timeout = 5000
    end
    # define the block of behavior for each call
    # block the request (sleep the thread) for the given delay time, in seconds
    sleep(timeout/1000)
    # run proxy call and return result, if desired
    if proxy or params[:proxyTo]
      if proxy
        uri = URI.parse(proxy)
        out_path = request.fullpath
      else
        uri = URI.parse(Rack::Utils.unescape(params[:proxyTo]))
        qsHash = CGI::parse(request.query_string)
        qsHash.delete 'proxyTo'
        #qs = qsHash.map{|k,v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join("&")
        qs = qsHash.map{|k,v| "#{k}=#{v.join(',')}"}.join('&')
        out_path = "#{request.path}?#{qs}"
      end
      Net::HTTP.start(uri.host, uri.port) do |http|
        if request.post? or request.put?
          returned = http.send method.to_sym, out_path, request.body.read
        else
          returned = http.send method.to_sym, out_path
        end
        status(returned.code)
        return returned.body
      end
    end
    # return error code with message, if :errorcode parameter is given
    halt params[:errorcode].to_i, "#{request.request_method} request to #{request.path_info} failed after #{timeout} milliseconds with error code #{params[:errorcode]}\n" if params[:errorcode]
    halt 500 if params[:fail]
  end
end

##########################
# This Rack configuration script will allow the 'slow' app
# to run under any Rack-supporting Ruby app server. This enables
# you to run the 'slow' app in the background (if the app server allows it).
#
# My recommendation is Thin.
# * gem install thin
#
# To run this app in the background, install Thin and execute this way to run it:
# * thin -d (or --daemonize) -R (or --rackup) config.ru -p (or --port) 80 start
# * the default port for Thin is 3000, so if you don't specify a port then it would use 3000.
#
# You can run the same command from the same directory but use "stop" instead of "start" to
# kill the background process. Thin attempts to keep track of the PID of the
# background process it spawned.

ENV["RACK_ENV"] = 'production'

require './slow.rb'

run Sinatra::Application

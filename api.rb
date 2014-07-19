# api.rb

# Global requires
require "sinatra"
require "rubygems"
require_relative "models/models.rb"
require "redis"
require "json"

set :environment, :production

# Start sinatra
class App < Sinatra::Application

end

# Closes connection after action (without this, app times out after 2 reqeusts)
after do
  ActiveRecord::Base.connection.close
end

get '/' do
	"<h1>Tribe API</h1>"
end

require_relative 'helpers/init'
require_relative 'routes/init'












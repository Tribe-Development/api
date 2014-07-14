# api.rb
require "sinatra"
require "rubygems"
require_relative "models/models.rb"
require_relative "helpers/redis_helper.rb"
require_relative "helpers/mysql_helper.rb"
require "redis"
require "json"

set :environment, :production

class App < Sinatra::Application

end

# Closes connection after action (without this, app times out after 2 reqeusts)
after do
  ActiveRecord::Base.connection.close
end

get '/' do
	"<h1>Tribe API</h1>"
end

# Creates a new tribe using POST params
post '/tribes/new' do
	if !params[:name]
		status 400
		ret = {
			:error_message => "Parameter 'name' is empty"
		}
		body ret.to_json
		return
	end

	name = params[:name]
	if Tribe.exists?(:name => name)
		status 403
		ret = {
			:error_message => "Tribe already exists"
		}
		body ret.to_json
		return
	end
	puts name
	createTribeSQL(name)
	tribes = Tribe.where("name = ?", name)
	puts tribes.to_json
	tribe = tribes[0]
	createTribeRedis(tribe.id)
	# return "Tribe #{tribe.name} created"
	status 200
	return
end

# Create new user using POST params
post '/users/new' do
	username = params[:username]
	password = params[:password]
	first_name = params[:first_name]
	last_name = params[:last_name]
	if !params[:username] or !params[:password] or !params[:first_name] or !params[:last_name]
		status 400
		ret = {
			:error_message => "Bad Request: Empty parameter(s)"
		}
		body ret.to_json
		return
	end
	# Check that username doesn't already exist
	if User.exists?(:username => username)
		status 403
		ret = {
			:error_message => "User already exists"
		}
		body ret.to_json
		return
	end
	createUser(username, password, first_name, last_name)
	status 200
	return
end

# Deletes a tribe
get '/tribes/:tribe/delete' do |tribe_id|
	deleteTribe(tribe_id)
end

# Deletes a user
get '/users/:user/delete' do |user_id|
	user = User.find(user_id.to_i)
	# Check that user exists
	if !User.exists?(user_id)
		#return "The user with id #{user_id.to_s} does not exist"
		return 0
	end
	user.destroy()

	# Delete all relations too
	relations = TribeToUser.where("user_id = ?", user_id)
	relations.each do |relation|
		relation.destroy()
	end

	#return "Deleted user #{user.username} and deleted all relations to tribes"
	return 1
end

# Outputs tribe_id and name
get '/tribes/:tribe' do |tribe_id|
	tribe = Tribe.find(tribe_id)
	output = {:id => tribe.id, :name => tribe.name}
	return output.to_json
end

# Outputs all users in a tribe
get '/tribes/:tribe/users' do |tribe_id|
	relations = TribeToUser.where("tribe_id = ?", tribe_id)
	output = []
	relations.each do |relation|
			output.push(relation.user_id)
	end
	return output.to_json
end

# Gets all messages for a tribe
get '/tribes/:tribe/messages' do |tribe_id|
	messages = []
	length = getLength(tribe_id)
	(1..length-1).each do |i|
		message = getMessage(tribe_id, i.to_s)
		messages.push(message)
	end
	messages.to_json
end

# Gets a specific message for a tribe
get '/tribes/:tribe/messages/:message' do |tribe_id, message_id|
	response['Access-Control-Allow-Origin'] = 'http://54.191.143.176:4568'
	message_obj = getMessage(tribe_id, message_id)
	return message_obj.to_json
end

# Create new message in a specific tribe
post '/tribes/:tribe/messages/new' do |tribe_id|
	response['Access-Control-Allow-Origin'] = 'http://54.191.143.176:4568'
	# Put POST data in variables
	author_id = params[:author_id]
	content = params[:content]
	recipient_type = 0 # 0 for group chat
	recipient_id = params[:recipient_id]
	date = params[:date]
	# Create message in redis database
	sendMessage(content, author_id, recipient_type, recipient_id) # PARAMS mes_content, author_id, recipient_type, recipient_id
	return 1
end

# Add user to tribe using ids
get '/tribes/:tribe/add/users/:user' do |tribe_id, user_id|
	# Check that relation doesn't already exist
	if TribeToUser.where("tribe_id = ? AND user_id = ?", tribe_id, user_id).exists?
		#return "Relation between tribe #{tribe_id} and user #{user_id} already exists"
		status 403
		error = {
		:error_message => "User with id #{user_id} already exists"
	}
		return
	end
	addUserToTribe(user_id, tribe_id)
	status 200
	return
end

get '/tribes/:tribe/delete/users/:user' do |tribe_id, user_id|
	if !TribeToUser.where("tribe_id = ? AND user_id = ?", tribe_id.to_s, user_id.to_s).exists?
		#return "Relation between tribe #{tribe_id} and user #{user_id} does not exist"
		status 
	end
	relations = TribeToUser.where("tribe_id = ? AND user_id = ?", tribe_id, user_id)
	relation = relations[0]
	relation.destroy()
	#{}"User #{user_id} removed from tribe #{tribe_id}"
	return 1
end

# Lists all tribes that the user is a part of
get '/users/:user/tribes' do |user_id|
	tribe_ids = getUserTribes(user_id)

	output = []
	tribe_ids.each do |tribe_id|
		tribe = Tribe.find(tribe_id)
		output.push({:id => tribe.id, :name => tribe.name})
	end
	return output.to_json
end

post '/login' do
	username = params[:username]
	password = params[:password]
	if !params[:username] or !params[:password]
		status 400
		return
	end
	output = checkLogin(username, password)
	if output.to_i > 0
		status 200
	else
		status 403
	end
	return
end
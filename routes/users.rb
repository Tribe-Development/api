## USER
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
	# Create user
	createUser(username, password, first_name, last_name)
	# Log user in
	login_status = checkLogin(username, password)
	token = createSession(login_status)
		output = {
			:token => token
		}
		body output.to_json
	status 200
	return
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

# Lists all tribes that the user is a part of
get '/users/:user/tribes' do |user_id|
	if !params[:token]
		puts "ng"
	end
	# Authenticate
	auth = isAuthorizedUser(params[:token], user_id)
	if  auth == -1
		status 401
		return
	end
	# Do stuff
	tribe_ids = getUserTribes(user_id)
	tribes = []
	tribe_ids.each do |tribe_id|
		tribe = Tribe.find(tribe_id)
		tribes.push(tribe)
	end
	tribes.sort! {|a,b| b[:last_updated] <=> a[:last_updated]}
	output = {
		:tribes => tribes
	}
	return output.to_json
end

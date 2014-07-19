## TRIBE
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
	# Authenticate
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end

	name = params[:name]
    
    # Create tribe
	tribe_id = createTribeSQL(name)
	
	# Add creator to tribe
	addUserToTribe(auth, tribe_id)
    
	status 200
	return
end

# Outputs all users in a tribe
get '/tribes/:tribe/users' do |tribe_id|
	# Check if tribe exists
	if !Tribe.exists?(:id => tribe_id)
		status 404
		return
	end

	# Authenticate
	auth = isAuthorizedTribe(params[:token], tribe_id)
	if  auth == -1
		status 401
		return
	end

	relations = TribeToUser.where("tribe_id = ?", tribe_id)
	output = {
		:user_ids => Array.new
	}
	relations.each do |relation|
			output[:user_ids].push(relation.user_id)
	end
	status 200
	return output.to_json
end

# Change tribe name
post '/tribes/:tribe/edit/name' do |tribe_id|
	# Check that params exist
	if !params[:tribe_name]
		status 400
		return
	end
	# Make sure tribe exists
	if !Tribe.exists?(:id => tribe_id)
		status 404
		return
	end
	# Authenticate for tribe
	auth = isAuthorizedTribe(params[:token], tribe_id)
	if auth == -1
		status 401
		return
	end
	# Change name
	tribe = Tribe.find(tribe_id)
	tribe.name = params[:tribe_name]
	tribe.save
	status 200
	return
end

# Remove user from a tribe
post '/tribes/:tribe/remove/users/:user' do |tribe_id, user_id|
	# Check to see tribe_id and user_id exist
	if !Tribe.exists?(:id => tribe_id) or !User.exists?(:id => user_id)
		status 403
		return
	end
	# Authenticate
	auth = isAuthorizedTribe(params[:token], tribe_id)
	if  auth == -1
		status 401
		return
	end
	# Check to make sure user is a part of the tribe
	if !TribeToUser.where("tribe_id = ? AND user_id = ?", tribe_id.to_s, user_id.to_s).exists?
		#return "Relation between tribe #{tribe_id} and user #{user_id} does not exist"
		status 403
		return
	end
	# Remove the User from the Tribe
	relations = TribeToUser.where("tribe_id = ? AND user_id = ?", tribe_id, user_id)
	relation = relations[0]
	relation.destroy()
	status 200
	return
end

# Add user to tribe using ids
post '/tribes/:tribe/add/users/:user' do |tribe_id, user_id|
	# Authenticate
	auth = isAuthorizedTribe(params[:token], tribe_id)
	if  auth == -1
		status 401
		return
	end
	# Check that both user and tribe exist
	if !Tribe.exists?(:id => tribe_id) or !User.exists?(:id => user_id)
		status 404
		return
	end
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

# Deletes a tribe - for dev will be removed later
post '/tribes/:tribe/delete' do |tribe_id|
	# Check that tribe exists
	if !Tribe.exists?(:id => tribe_id)
		status 404
		return
	end
	# Delete tribe
	deleteTribeSQL(tribe_id)
	deleteTribeRedis(tribe_id)
	status 200
	return
end

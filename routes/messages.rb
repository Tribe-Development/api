##########################################
# Create new message in a specific tribe #
##########################################
post '/tribes/:tribe/messages/new' do |tribe_id|
	# Check if tribe exists
	if !Tribe.exists?(:id => tribe_id)
		status 404
		return
	end
	
	# Make sure request is valid
	if !params[:content]
		status 400
		return
	end

	# Authenticate
	auth = isAuthorizedTribe(params[:token], tribe_id)
	if  auth == -1
		status 401
		return
	end

	# Put POST data in variables
	author_id = auth
	content = params[:content]
	recipient_type = 0 # 0 for group chat
	recipient_id = tribe_id

	# Create message in redis database
	sendMessage(content, author_id, recipient_type, recipient_id) # PARAMS mes_content, author_id, recipient_type, recipient_id
	updateTribeSQL(recipient_id)
	status 200
	return
end

#################################
# Gets all messages for a tribe #
#################################
get '/tribes/:tribe/messages' do |tribe_id|
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

	# Build output
	output = {
		:messages => []
	}
	length = getLength(tribe_id)
	(1..length-1).each do |i|
		message = getMessage(tribe_id, i.to_s)
		output[:messages].push(message)
	end
	status 200
	body output.to_json
	return
end

#######################################
# Gets a specific message for a tribe #
#######################################
get '/tribes/:tribe/messages/:message' do |tribe_id, message_id|
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

	# Check if message exists
	if !messageExists(tribe_id, message_id)
		status 404
		return
	end

	message_obj = getMessage(tribe_id, message_id)
	return message_obj.to_json
end

#############################
# Outputs tribe_id and name #
#############################
get '/tribes/:tribe' do |tribe_id|
	tribe = Tribe.find(tribe_id)
	output = {:id => tribe.id, :name => tribe.name}
	return output.to_json
end

#########################
# Send a user a message #
#########################
post '/users/:user_id/messages/new' do |recipient_id|
	# Check params
	if !params[:content]
		status 400
		return
	end

	# Authenticate (is friend) ---NEEDS TO BE DONE
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end
	convo = {}
	# Check if conversation exists between users
	if !FriendConversation.where("user1_id = ? AND user2_id = ?", auth, recipient_id).exists? and !FriendConversation.where("user1_id = ? AND user2_id = ?", recipient_id, auth).exists?
		# (SQL) Create new conversation between users (need to create one for each way)
		convo = FriendConversation.new
		convo.user1_id = auth
		convo.user2_id = recipient_id
		date = Time.now
		date_str = date.strftime("%d %b %Y %H:%M:%S")
		convo.last_updated = date_str
		convo.save
		# (Redis) Create new conversation length
		$redis.set('friend:'+convo.id.to_s, 1)
	elsif !FriendConversation.where("user1_id = ? AND user2_id = ?", auth, recipient_id).exists?
		convo = FriendConversation.where("user1_id = ? AND user2_id = ?", recipient_id, auth).take
	else
		convo = FriendConversation.where("user1_id = ? AND user2_id = ?", auth, recipient_id).take
	end
	# Create new message in existing conversation
	sendMessage(params[:content], auth, 1, convo.id)
	# Last updated
	date = Time.now
	date_str = date.strftime("%d %b %Y %H:%M:%S")
	convo.last_updated = date_str
	convo.save
	status 200
	return
end

###################################################
# Get all convos for a user (both tribe and user) #
###################################################
get '/convos' do
    # Authenticate (is friend) ---NEEDS TO BE DONE
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end
    
    # Create empty output array
    output = []
    
    # Get all tribes
    tribe_ids = getUserTribes(auth)
    tribe_ids.each do |tribe_id|
        tribe = Tribe.find(tribe_id)
        entry = {
            :title          => tribe.name,
            :last_updated   => tribe.last_updated,
            :type           => 0, # 0 for tribe
            :recent_message => "needs to be implemented"
        }
        # Append tribe data to output array
        output.push(entry)
    end
    
    # Get all user convos
    convo_ids = getFriendConvos(auth)
    convo_ids.each do |convo_id|
        convo = FriendConversation.find(convo_id)
        entry = {
            :title          => getFriendConvoTitle(convo_id, auth),
            :last_updated   => convo.last_updated,
            :type           => 1,
            :recent_message => "needs to be implemented"
        }
        output.push(entry)
    end
    
    # Sort by last_updated
    output.sort! {|a,b| b[:last_updated] <=> a[:last_updated]}
    body_obj = {
           :convos => output 
    }
    return body_obj.to_json
end

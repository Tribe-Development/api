##################
# Send a message #
##################
post '/messages/new' do
    
    # Authenticate
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end
     
    # Check params
    if !params[:message_content] or !params[:chat_id]
        status 400
        return
    end
    
    # Check that chat exists
    if !Chat.exists?(:id => params[:chat_id])
        status 404
        return
    end
    
    # Check that user is authorized for that chat
    chat_subscribers = getChatSubscribers(params[:chat_id])
    if !chat_subscribers.include?(auth)
        status 401
        return
    end
    
    # Create new message in redis
    sendMessage(params[:message_content], auth, params[:chat_id])
    
    status 200
    return
end

###############################
# Get all messages for a chat #
###############################
get '/messages/all' do
    
    # Authenticate
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end
    
    # Check params
    if !params[:chat_id]
        status 400
        return
    end
    
    # Check that chat exists
    if !Chat.exists?(:id => params[:chat_id])
        status 404
        return
    end
    
    # Check that user is authorized for chat
    if !isAuthorizedChat(params[:token], params[:chat_id])
        status 401
        return
    end
    
    # Query redis for messages
    messages = getAllMessages(params[:chat_id])
    body_obj = {
        :messages => messages    
    }
    status 200
    return body_obj.to_json
end

###########################
# Gets a specific message #
###########################
get '/messages/one' do
    
    # Authenticate
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end
    
    # Check params
    if !params[:chat_id] or !params[:message_id]
        status 400
        return
    end
    
    # Check that chat exists
    if !Chat.exists?(:id => params[:chat_id])
        status 404
        return
    end
    
    # Check that user is authorized for chat
    if !isAuthorizedChat(params[:token], params[:chat_id])
        status 401
        return
    end
    
    # Query redis for message
    message = getMessage(params[:chat_id], params[:message_id])
    body_obj = {
        :message => message    
    }
    status 200
    return body_obj.to_json
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
            :recent_message => "needs to be implemented",
            :id             => tribe.id
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
            :recent_message => "needs to be implemented",
            :id             => convo.id
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



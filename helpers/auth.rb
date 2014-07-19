#########################
# Authorized for a chat #
#########################
def isAuthorizedChat(token, chat_id)
    
    # Check if session exists
    if !Session.exists?(:token => token)
		return -1
	end
    
    # Get user_id associated with session
    session = Session.where(token: token).take
	user_id = session.user_id
	
	# Check if user_id is part of given chat
	auth_users = getChatSubscribers(chat_id)
	if auth_users.include?(user_id)
		return user_id
	else
		return -1
	end
end

def isAuthorizedTribe(token, tribe_id)
	if !Session.exists?(:token => token)
		return -1
	end
	session = Session.where(token: token).take
	# Get user_id associated with session
	user_id = session.user_id
	
	# Check if user_id is part of given tribe
	auth_users = getTribeUsers(tribe_id)
	if auth_users.include?(user_id)
		return user_id
	else
		return -1
	end
end

def isAuthorizedUser(token, user_id)
	if !Session.exists?(:token => token)
		return -1
	end
	session = Session.where(token: token).take
	puts session.user_id
	puts user_id
	if session.user_id.to_i == user_id.to_i
		return session.user_id
	end
	return -1
end

def isAuthorized(token)
	if !Session.exists?(:token => token)
		return -1
	end
	session = Session.where(token: token).take
	return session.user_id
end

def checkSession(token)
	if !Session.exists?(:token => token)
		return -1
	end
	session = Session.where(token: token).take
	return session.user_id
end
require_relative "../models/models.rb"
require_relative "../helpers/mysql_helper.rb"

def isAuthorizedTribe(token, tribe_id)
	if !Session.exists?(:token => token)
		return -1
	end
	session = Session.where(token: token).take
	# Get user_id associated with session
	user_id = session.user_id
	return user_id
	# Check if user_id is part of given tribe
	auth_users = getTribeUsers(tribe_id)
	if auth_users.include?(user_id)
		return user_id
	else
		return -1
	end
end

def isAuthorizedUser(token, user_id)

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
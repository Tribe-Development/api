require_relative "../models/models.rb"
require 'digest/md5'

def createUser(username, password, first_name, last_name)
	user = User.new
	user.username = username
	user.password = Digest::MD5.hexdigest(password)
	user.first_name = first_name
	user.last_name = last_name
	user.save
	return 1
end

def createTribeSQL(name)
	tribe = Tribe.new
	tribe.name = name
	tribe.save
	return tribe.id
end

def deleteTribeSQL(tribe_id)
	tribe = Tribe.find(tribe_id)
	# Delete all relations
	relations = TribeToUser.where('tribe_id = ?', tribe_id)
	relations.each do |relation|
		relation.destroy()
	end
	# Delete all messages
	tribe.destroy()
	return "Tribe #{tribe.name} deleted"
end

def addUserToTribe(user_id, tribe_id)
	relation = TribeToUser.new
	relation.user_id = user_id
	relation.tribe_id = tribe_id
	relation.save
	return "User #{user_id} added to tribe #{tribe_id}" 
end

def getUserTribes(user_id)
	relations = TribeToUser.where(:user_id => user_id)
	tribes = []
	relations.each do |relation|
		tribes.push(relation.user_id)
	end
	return tribes
end

def getTribeUsers(tribe_id)
	relations = TribeToUser.where(:tribe_id => tribe_id)
	users = []
	relations.each do |relation|
		users.push(relation.user_id)
	end
	return users
end

def getTribeId(tribe_name)
	#! Needs to be written
end

def checkLogin(username, password)
	if User.exists?(:username => username)
		users = User.where(:username => username)
		user = users[0]
		if user["password"] == Digest::MD5.hexdigest(password)
			return user.id # 1 = Correct Login
		end
		return "0" # 0 = Incorrect Password, but correct username
	end
	return "-1" # -1 = User does not exist
end

def createSession(user_id)
	time = Time.new
	secret = "zxv8zq(fsiuu6-46lo9w)*#ei99hr3h%qy!zsl2v8_#7_p@*#q"
	token = Digest::MD5.hexdigest(time.inspect + secret + user_id.to_s)
	# Check that token does not already exist
	if Session.exists?(:token => token)
		createSession(user_id)
		return	
	end
	# Set expiration date
	expiration = time + 604800*2
	session = Session.new
	session.user_id = user_id
	session.token = token
	session.expires = expiration.strftime("%Y-%m-%d")
	session.save
	return token
end

def deleteSession(token)
	if !Session.exists?(:token => token)
		return 404
	end
	session = Session.where(:token => token).take
	session.destroy
	return 200
end

def createFriendRequest(sender_id, recipient_id)
	request = FriendRequest.new
	request.sender_id = sender_id
	request.recipient_id = recipient_id
	request.save
end
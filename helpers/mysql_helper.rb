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
end

def deleteTribe(tribe_id)
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
		tribes.push(relation.tribe_id)
	end
	return tribes
end

def getTribeId(tribe_name)
	#! Needs to be written
end

def checkLogin(username, password)
	if User.exists?(:username => username)
		users = User.where(:username => username)
		user = users[0]
		if user["password"] == Digest::MD5.hexdigest(password)
			return user.id.to_s # 1 = Correct Login
		end
		return "0" # 0 = Incorrect Password, but correct username
	end
	return "-1" # -1 = User does not exist
end
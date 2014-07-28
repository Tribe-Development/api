require_relative "../models/models.rb"
require 'digest/md5'

#####################
# Create a new user #
#####################
def createUser(username, password, first_name, last_name)
	user = User.new
	user.username = username
	user.password = Digest::MD5.hexdigest(password)
	user.first_name = first_name
	user.last_name = last_name
    user.image = 'http://www.corporatetraveller.ca/assets/images/profile-placeholder.gif'
	user.save
	return 1
end

######################
# Create a new tribe #
######################
def createTribeSQL(name)
    
    # Set date
    date = Time.now
	date_str = date.strftime("%d %b %Y %H:%M:%S")
    
    # Create chat SQL
    chat = Chat.new
    chat.last_updated = date_str
    chat.save
    
    # Create chat Redis
    createChatRedis(chat.id)
    
    # Create tribe
	tribe = Tribe.new
	tribe.name = name
    tribe.chat_id = chat.id
	tribe.last_updated = date_str
    tribe.image = 'http://www.corporatetraveller.ca/assets/images/profile-placeholder.gif'
	tribe.save
    
	return tribe.id
end

##############################
# Gets subscribers of a chat #
##############################
def getChatSubscribers(chat_id)
    # Get all relations for chat
    relations = ChatSubscriber.where("chat_id = ?", chat_id)
    
    # Create output
    output = []
    relations.each do |relation|
         output.push(relation.subscriber_id)
    end
    return output
end

#########################
# Gets chats for a user #
#########################
def getUserChats(user_id)
    # Get all relations
    relations = ChatSubscriber.where('subscriber_id = ?', user_id)
    
    # Build output
    chats = []
    relations.each do |relation|
         chats.push(relation.chat_id)
    end
    return chats
end

####################
# Add user to chat #
####################
def addChatSubscriber(chat_id, user_id)
    subscriber = ChatSubscriber.new
    subscriber.chat_id = chat_id
    subscriber.subscriber_id = user_id
    subscriber.save
end

###########################
# Last updated for a chat #
###########################
def updateChat(chat_id)
	chat = Chat.find(chat_id)
	date = Time.now
	date_str = date.strftime("%d %b %Y %H:%M:%S")
	chat.last_updated = date_str
	chat.save
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
    # Create tribe - user relation
	relation = TribeToUser.new
	relation.user_id = user_id
	relation.tribe_id = tribe_id
	relation.save
	
    # Add user to tribe chat
    tribe = Tribe.find(tribe_id)
    chat_subscriber = ChatSubscriber.new
    chat_subscriber.chat_id = tribe.chat_id
    chat_subscriber.subscriber_id = user_id
    chat_subscriber.save
end

def getUserTribes(user_id)
	relations = TribeToUser.where(:user_id => user_id)
	tribes = []
	relations.each do |relation|
		tribes.push(relation.tribe_id)
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
    puts token
	# Check that token does not already exist
	if Session.exists?(:token => token)
        sleep 0.1
		return createSession(user_id)
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

def acceptRequest(request_id)
	# Get request
	request = FriendRequest.find(request_id)
	# Add to friends table
	friend1 = Friend.new
	friend1.user_id = request.sender_id
	friend1.friend_id = request.recipient_id
	friend1.save
	friend2 = Friend.new
	friend2.user_id = request.recipient_id
	friend2.friend_id = request.sender_id
	friend2.save
	# Delete request
	request.destroy()
    # Create chat for friends
    chat = Chat.new
    # Set date
    date = Time.now
	date_str = date.strftime("%d %b %Y %H:%M:%S")
    chat.last_updated = date_str
    chat.save
    addChatSubscriber(chat.id, request.sender_id)
    addChatSubscriber(chat.id, request.recipient_id)
end

def updateTribeSQL(recipient_id)
	tribe = Tribe.find(recipient_id)
	date = Time.now
	date_str = date.strftime("%d %b %Y %H:%M:%S")
	tribe.last_updated = date_str
	tribe.save
end

def updateConversation(convo_id)
	convo = FriendConversation.new
	date = Time.now
	date_str = date.strftime("%d %b %Y %H:%M:%S")
	convo.last_updated = date_str
	convo.save
end

def getFriendConvos(user_id)
    convos = FriendConversation.where("user1_id = ? or user2_id = ?", user_id, user_id)
    convo_ids = []
    convos.each do |convo|
        convo_ids.push(convo.id) 
    end
    return convo_ids 
end

def getFriendConvoTitle(convo_id, user_id)
    convo = FriendConversation.find(convo_id)
    user = convo.user1_id
    if convo.user1_id == user_id
        user = convo.user2_id 
    end
    user_obj = User.find(user)
    return user_obj.first_name + " " + user_obj.last_name
end

def getFriendChatImage(chat_id, user_id)
    chat = Chat.find(chat_id)
    
    # Get relations
    relations = ChatSubscriber.where("chat_id = ?", chat_id)
    
    # Loop through relations and get friend id
    image = ""
    relations.each do |relation|
        if relation.subscriber_id != user_id
            friend_id = relation.subscriber_id
            user = User.find(friend_id)
            image = user.image
        end
    end
    return image
end

def getFriendChatName(chat_id, user_id)
    chat = Chat.find(chat_id)
    
    # Get relations
    relations = ChatSubscriber.where("chat_id = ?", chat_id)
    
    # Loop through relations and get friend id
    title = ""
    relations.each do |relation|
        if relation.subscriber_id != user_id
            friend_id = relation.subscriber_id
            user = User.find(friend_id)
            title = user.first_name + " " + user.last_name
        end
    end
    return title
end
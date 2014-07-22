require('redis')
$redis = Redis.new(:host => 'localhost', :port => 6379)

#################
# Get a message #
#################
def getMessage(chat_id, message_id)
    # Get message information
    last = message_id.to_i + 1.to_i
	output = $redis.zrange("chat:#{chat_id.to_s}", message_id.to_s, last.to_s)
    output = JSON.parse(output[0])
    
    # Get author username and append to output
	author_id = output["author"].to_i
    puts author_id
    puts output
	author = User.find(author_id)
	username = author.username
	output.merge!(:username => username)
    return output
end

####################
# Get all messages #
####################
def getAllMessages(chat_id)
    length = getLength(chat_id)
    
    # Loop through all messages and append to output
    message_strings = $redis.zrevrange("chat:#{chat_id}", 0, -1)
    
    # Create messages from json strings
    messages = []
    message_strings.each do |message_string|
        messages.push(JSON.parse(message_string))
    end
    return messages
end

##################################
# Get number of messages in chat # 
##################################
def getLength(chat_id)
	return $redis.zcard("chat:#{chat_id.to_s}").to_i
end

##################
# Send a message # 
##################
def sendMessage(mes_content, author_id, chat_id)
    
    # Get date and length of chat
	date = Time.new
	date_str = date.strftime("%d %b %Y %H:%M:%S.%3N")
	###length = getLength(chat_id)
    length = getLength(chat_id)
    
    # Create message and increment chat
    $redis.zadd("chat:#{chat_id}", length+1, '{"content": "'+mes_content+'", "author": "'+author_id.to_s+'", "date": "'+date_str+'"}')
    ###$redis.hmset('chat:'+chat_id.to_s+':message:'+length.to_s, 'content', mes_content, 'author', author_id, 'date', date_str)
    ###$redis.incr('chat:'+chat_id.to_s)
    
    # Create publish message (redis)
    pub_obj = {}
	pub_obj.merge!(:chat_id => chat_id)
	pub_obj.merge!(:location => length+1)
	$redis.publish("new.message", pub_obj.to_json)
	return
end

#################
# Create a chat #
#################
def createChatRedis(chat_id)
    ###$redis.set("chat:#{chat_id}", 1) 
end

def messageExists(tribe_id, message_id)
	$redis.exists('tribe:'+tribe_id+':message:'+message_id)
end

def deleteTribeMessage(tribe_id, message_id)
	length = getLength(tribe_id)
	$redis.decr("tribe:#{tribe_id.to_s}")
	$redis.del("tribe:#{tribe_id.to_s}:message:#{message_id.to_s}")
	puts "tribe:#{tribe_id.to_s}:message:#{message_id.to_s}"
end

def deleteTribeRedis(tribe_id)
	length = getLength(tribe_id)
	(1..length.to_i).step(1) do |i|
		deleteTribeMessage(tribe_id, i)
	end
end


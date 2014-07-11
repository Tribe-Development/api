require('redis')
require('json')
require_relative "../models/models.rb"
$redis = Redis.new(:host => 'localhost', :port => 6379)

def getMessage(tribe_id, message_id)
	output = $redis.hgetall('tribe:'+tribe_id+':message:'+message_id)
	author_id = output["author"].to_i
	author = User.find(author_id)
	username = author.username

	output.merge!(:username => username)
end

def getLength(tribe_id)
	return $redis.hget('tribe:'+tribe_id, 'length').to_i
end

def sendMessage(mes_content, author_id, recipient_type, recipient_id)
	length = getLength(recipient_id)
	puts length
	if recipient_type == 0 # 0 is for TRIBE
		$redis.hmset('tribe:'+recipient_id.to_s+':message:'+length.to_s, 'content', mes_content, 'author', author_id)
		$redis.hincrby('tribe:'+recipient_id.to_s, 'length', 1)
	# Need elsif recipient_type == 1
	end
	pub_obj = {:recipient_type => recipient_type}
	pub_obj.merge!(:recipient_id => recipient_id)
	pub_obj.merge!(:location => length)
	$redis.publish("new.message", pub_obj.to_json)
	return "Content: " + mes_content
end

def createTribeRedis(tribe_id)
	$redis.hmset('tribe:'+tribe_id.to_s, 'length', 1)
end

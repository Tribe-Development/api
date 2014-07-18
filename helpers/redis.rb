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

def getLength(recipient_id, recipient_type)
    if recipient_type == 1
        return $redis.get('friend:'+recipient_id.to_s).to_i
    end
	return $redis.get('tribe:'+recipient_id.to_s).to_i
end

def sendMessage(mes_content, author_id, recipient_type, recipient_id)
	date = Time.new
	date_str = date.strftime("%d %b %Y %H:%M:%S.%3N")
	puts date_str
	length = getLength(recipient_id, recipient_type)
	puts length
	if recipient_type == 0 # 0 is for TRIBE
		$redis.hmset('tribe:'+recipient_id.to_s+':message:'+length.to_s, 'content', mes_content, 'author', author_id, 'date', date_str)
		$redis.incr('tribe:'+recipient_id.to_s)
	elsif recipient_type == 1 # 1 for FRIEND convo
		$redis.hmset('friend:'+recipient_id.to_s+':message:'+length.to_s, 'content', mes_content, 'author', author_id, 'date', date_str)
		$redis.incr('friend:'+recipient_id.to_s)
	end
	pub_obj = {:recipient_type => recipient_type}
	pub_obj.merge!(:recipient_id => recipient_id)
	pub_obj.merge!(:location => length)
	$redis.publish("new.message", pub_obj.to_json)
	return "Content: " + mes_content
end

def createTribeRedis(tribe_id)
	$redis.set('tribe:'+tribe_id.to_s, 1)
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


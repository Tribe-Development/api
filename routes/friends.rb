## FRIENDSHIPS
post '/friends/request' do
	# PARAMS: token, friend_id
	# Check params
	if !params[:friend_id]
		status 400
		return
	end
	# Authenticate
	auth = isAuthorized(params[:token])
	if  auth == -1
		status 401
		return
	end
	# Make sure request or friendship doesn't already exist
	if FriendRequest.where("sender_id = ? and recipient_id = ?", auth, params[:friend_id]).exists? or Friend.where("user_id = ? and friend_id = ?", auth, params[:friend_id]).exists?
		status 403
		return
	end
	createFriendRequest(auth, params[:friend_id])
	status 200
	return
end

post '/friends/accept' do
	# PARAMS: token, request_id
	# Check params
	if !params[:request_id]
		status 400
		return
	end
	# Make sure request exists
	if !FriendRequest.exists?(:id => params[:request_id])
		status 404
		return
	end
	request = FriendRequest.find(params[:request_id])
	# Authenticate
	auth = isAuthorizedUser(params[:token], request.recipient_id)
	if  auth == -1
		status 401
		return
	end

	acceptRequest(params[:request_id])
	status 200
	return
end
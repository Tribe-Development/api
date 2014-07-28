## LOGIN
post '/login' do
	username = params[:username]
	password = params[:password]
	if !params[:username] or !params[:password]
		status 400
		return
	end
	login_status = checkLogin(username, password)
	if login_status.to_i > 0
		status 200
        puts login_status
		token = createSession(login_status)
		output = {
			:token => token
		}
        puts output
		body output.to_json
	else
		status 403
	end
	return
end

# Deletes session
post '/logout' do
	if !params[:token]
		status 400
		return
	end
	status deleteSession(params[:token])
	return
end

# Check if username exists
get '/users/:username/exists' do |username|
	# Check that username doesn't already exist
	if User.exists?(:username => username)
		status 403
		return
	end
	status 200
	return
end
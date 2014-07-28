require 'net/http'
require 'json'
require_relative '../../models/models'

Given(/^table (\w+) is empty$/) do |table_name|
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name}")
end

When(/^I submit a form called signup with username (\w+) and password (\w+)$/) do |username, password|
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new('/users/new')
    req.set_form_data({
        'username' => username,
        'password' => password,
        'first_name' => 'Cyrus',
        'last_name' => 'Forbes'
    })
    res = http.request(req)
    puts res.code
    puts res.body
    if res.code != '200'
        fail(StandardError.new("Status code: #{res.code}")) 
    end
    if !JSON.parse(res.body).has_key?("token")
        fail(StandardError.new("Return object doesn't contain token")) 
    end
end

Then(/^I can login with username (\w+) and password (\w+)$/) do |username, password|
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new('/login')
    req.set_form_data({
        'username' => username,
        'password' => password
    })
    res = http.request(req)
    puts res.code
    puts res.body
    if res.code != '200'
        fail(StandardError.new("Status code: #{res.code}")) 
    end
    if !JSON.parse(res.body).has_key?("token")
        fail(StandardError.new("Return object doesn't contain token")) 
    end
end

Given(/^the following users exist:$/) do |table|
    # Set up http request
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)
    
    # Truncate table users
    ActiveRecord::Base.connection.execute("TRUNCATE users;")
    
    # Loop through each user
    users = table.hashes()
    users.each do |user|
        req = Net::HTTP::Post.new('/users/new')
        req.set_form_data({
            'username' => user[:username],
            'password' => user[:password],
            'first_name' => user[:first_name],
            'last_name' => user[:last_name]
        })
        res = http.request(req)
        puts res.code
        puts res.body
        if res.code != '200'
            fail(StandardError.new("Status code: #{res.code}")) 
        end
    end
end

Given(/^I am logged in as user (\w+) with password (\w+)$/) do |username, password|
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)
    
    # Login
    req = Net::HTTP::Post.new('/login')
    req.set_form_data({
        'username' => username,
        'password' => password
    })
    res = http.request(req)
    puts res.code
    puts res.body
    if res.code != '200'
        fail(StandardError.new("Status code: #{res.code}")) 
    end
    body = JSON.parse(res.body)
    @token = body["token"]
end

When(/^I logout$/) do
    # Check if token is defined
    if !defined?(@token)
        fail(StandardError.new("Not logged in"))
    end
    
    # Set up http request
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)
    
    # Logout
    req = Net::HTTP::Post.new('/logout')
    req.set_form_data({
        'token' => @token
    })
    res = http.request(req)
    puts res.code
    puts res.body
    if res.code != '200'
        fail(StandardError.new("Status code: #{res.code}")) 
    end
end

Then(/^my session should not exist$/) do
    if Session.exists?(:token => @token)
        fail(StandardError.new("Session still exists")) 
    end
end
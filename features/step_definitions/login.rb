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
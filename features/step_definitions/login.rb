require 'net/http'

Given /^When I submit a form called signup with username (\w+) and password (\w+)$/ do |username, password|
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new('/users/new')
    req.add_field('Content-Type', 'application/json')
    req.body = {
        'username' => 'cyrusaf5',
        'password' => 'bugzzues'
    }.to_s
    res = http.request(req)
    puts res.body
end

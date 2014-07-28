When(/^I create a new tribe called (\w+)$/) do |tribe_name|
    
    # Set up http request
    url = URI.parse("http://localhost:4567")
    http = Net::HTTP.new(url.host, url.port)

    # Create a new tribe with given name
    req = Net::HTTP::Post.new('/tribes/new')
    req.set_form_data({
        'name' => tribe_name,
        'token' => @token
    })
    res = http.request(req)
    puts res.code
    puts res.body
    if res.code != '200'
        fail(StandardError.new("Status code: #{res.code}")) 
    end
end

Then(/^a tribe called (\w+) should exist$/) do |tribe_name|
    # Check if tribe with given name exists
    if !Tribe.exists?(:name => tribe_name)
         fail(StandardError.new("Tribe does not exist")) 
    end
end

Then(/^I should be a part of the tribe (\w+)$/) do |tribe_name|
    # Get tribe id from name
    tribe_id = Tribe.where("name = ?", tribe_name).take.id
    
    # Check if user is part of given tribe
    relations = TribeToUser.where("tribe_id = ?", tribe_id)
    if !relations.any? {|h| h[:user_id] == @user_id}
        fail(StandardError.new("User is not part of tribe")) 
    end
end
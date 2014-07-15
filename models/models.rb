# models.rb
require "active_record"

ActiveRecord::Base.establish_connection(
    :adapter => "mysql2",
    :host => "127.0.0.1",
    :username => "cyrusaf",
    :password => "bugzzues",
    :database => "tribe"
)

class User < ActiveRecord::Base

end

class Tribe < ActiveRecord::Base

end

class TribeToUser < ActiveRecord::Base
end

class Session < ActiveRecord::Base
end 

class Friend < ActiveRecord::Base
end

class FriendRequest < ActiveRecord::Base
end
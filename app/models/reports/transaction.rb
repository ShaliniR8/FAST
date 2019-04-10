class Transaction < ActiveRecord::Base
	belongs_to :user, foreign_key: "users_id",class_name:"User"
    before_create :init_stamp

    def init_stamp
    	self.stamp=Time.now
    end
end

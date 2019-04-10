class Transaction < ActiveRecord::Base
	belongs_to :user, foreign_key: "users_id",class_name:"User"
	belongs_to :report, foreign_key: "reports_id",class_name:"Report"
    before_create :init_stamp

    def init_stamp
    	self.stamp=Time.now
    end
end

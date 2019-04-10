class Assignment < ActiveRecord::Base
	belongs_to :privilege, foreign_key: "privileges_id", class_name: "Privilege"
	belongs_to :access_control, foreign_key: "access_controls_id", class_name: "AccessControl"
end

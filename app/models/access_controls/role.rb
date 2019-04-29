class Role < ActiveRecord::Base
  belongs_to :user, foreign_key: "users_id", class_name: "User"
  belongs_to :privilege, foreign_key: "privileges_id", class_name: "Privilege"
end

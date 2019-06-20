class Notice < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user, foreign_key: "users_id",class_name:"User"
end

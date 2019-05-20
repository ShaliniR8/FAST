class Participation < ActiveRecord::Base

  belongs_to :user, foreign_key: "users_id", class_name: "User"
  belongs_to :meeting, foreign_key: "meetings_id", class_name: "Meeting"
  attr_accessible :users_id
  before_create :set_status

  def set_status
    self.status = "Pending"
  end
end

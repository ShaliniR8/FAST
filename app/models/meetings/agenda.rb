class Agenda < ActiveRecord::Base

  belongs_to :user, foreign_key: "user_id", class_name: "User"

  def get_content
    "#{user.full_name} - #{discussion ? 'Yes' : 'No'}"
  end

end

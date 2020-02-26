class MessageAccess < ActiveRecord::Base
  belongs_to :message, foreign_key:"messages_id", class_name: "Message"
  belongs_to :user, foreign_key: "users_id", class_name: "User"

  def getName
    if user.present?
      if user.id == session[:user_id]
        "#{user.full_name} (Me)"
      elsif anonymous
        'Anonymous'
      else
        user.full_name
      end
    else
      'N/A'
    end
  end
end

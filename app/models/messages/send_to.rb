class SendTo < MessageAccess
  before_create :set_unread
  after_create :notify_user

  def set_unread
    self.status = "Unread"
    self.visible = true
  end

  def notify_user
    #MessageMailer.new_message(self.user)
  end
end

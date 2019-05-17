class SendTo < MessageAccess
  before_create :set_unread

  def set_unread
    self.status = "Unread"
    self.visible = true
  end

end

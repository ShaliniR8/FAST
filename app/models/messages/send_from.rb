class SendFrom < MessageAccess
  before_create :set_status

  def set_status
    self.status = "Sent"
    self.visible = true
  end
end

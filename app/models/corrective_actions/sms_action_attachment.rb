class SmsActionAttachment < Attachment
  belongs_to :sms_action, foreign_key:"owner_id", class_name: "SmsAction"

  after_create :create_transaction
  before_destroy :delete_transaction

  def create_transaction
    SmsActionTransaction.create(:users_id=>session[:user_id],:action=>"Add Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

  def delete_transaction
    SmsActionTransaction.create(:users_id=>session[:user_id],:action=>"Delete Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

end

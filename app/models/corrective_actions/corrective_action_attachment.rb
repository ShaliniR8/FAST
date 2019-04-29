class CorrectiveActionAttachment < Attachment
  belongs_to :corrective_action, foreign_key:"owner_id", class_name: "CorrectiveAction"


  # def create_transaction
  #   CorrectiveActionTransaction.create(:users_id=>session[:user_id],:action=>"Add Attachment",:owner_id=>owner_id,:content=>self.name.filename.to_s,:stamp=>Time.now)
  # end

  after_create :create_transaction
  before_destroy :delete_transaction

  def create_transaction
    CorrectiveActionTransaction.create(:users_id=>session[:user_id],:action=>"Add Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

  def delete_transaction
    CorrectiveActionTransaction.create(:users_id=>session[:user_id],:action=>"Delete Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end
end

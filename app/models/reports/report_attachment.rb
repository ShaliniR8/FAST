class ReportAttachment < Attachment
  belongs_to :report, foreign_key:"owner_id", class_name: "Report"

  after_create :create_transaction
  before_destroy :delete_transaction

  def create_transaction
    ReportTransaction.create(:users_id=>session[:user_id],:action=>"Add Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

  def delete_transaction
    ReportTransaction.create(:users_id=>session[:user_id],:action=>"Delete Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

end

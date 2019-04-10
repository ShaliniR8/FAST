class HazardAttachment < Attachment
 belongs_to :hazard,foreign_key: "owner_id",class_name: "Hazard"

  after_create :create_transaction
  before_destroy :delete_transaction

  def create_transaction
    HazardTransaction.create(:users_id=>session[:user_id],:action=>"Add Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

  def delete_transaction
    HazardTransaction.create(:users_id=>session[:user_id],:action=>"Delete Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

end
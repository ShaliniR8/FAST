class RecommendationAttachment < Attachment
  belongs_to :recommendation, foreign_key:"owner_id", class_name: "Recommendation"

  after_create :create_transaction
  before_destroy :delete_transaction

  def create_transaction
    RecommendationTransaction.create(:users_id=>session[:user_id],:action=>"Add Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

  def delete_transaction
    RecommendationTransaction.create(:users_id=>session[:user_id],:action=>"Delete Attachment",:owner_id=>owner_id,:content=>self.document_filename,:stamp=>Time.now)
  end

end

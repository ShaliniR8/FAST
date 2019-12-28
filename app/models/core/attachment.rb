class Attachment < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  mount_uploader :name, AttachmentsUploader

  after_create :create_transaction
  before_destroy :delete_transaction

  def self.image_extensions
    ['png', 'jpg', 'jpeg']
  end

  def self.audio_extensions
    ['mp3']
  end

  def self.video_extensions
    ['mp4', 'mov']
  end

  def self.pdf_extensions
    ['pdf']
  end

  def document_filename
    read_attribute(:name)
  end

  def create_transaction
    Transaction.build_for(
      self.owner,
      'Add Attachment',
      session[:simulated_id] || session[:user_id],
      self.document_filename
    )
  end


  def delete_transaction
    Transaction.build_for(
      self.owner,
      'Delete Attachment',
      (session[:simulated_id] || session[:user_id]),
      self.document_filename
    )
  end

end

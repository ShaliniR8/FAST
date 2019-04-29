class Attachment < ActiveRecord::Base
  mount_uploader :name, AttachmentsUploader

  #after_create :create_transaction



  def self.image_extensions
    ["png","jpg","jpeg"]
  end

  def self.audio_extensions
    ["mp3"]
  end

  def self.video_extensions
    ["mp4", "mov"]
  end

  def self.pdf_extensions
    ["pdf"]
  end

  def document_filename
    read_attribute(:name)
  end



end

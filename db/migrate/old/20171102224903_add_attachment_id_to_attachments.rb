class AddAttachmentIdToAttachments < ActiveRecord::Migration
  def self.up
	add_column :attachments, :attachment_id, :integer
  end

  def self.down
	remove_column :attachments, :attachment_id
  end
end

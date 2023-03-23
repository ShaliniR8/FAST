class AddUserIdsToNewsletterAttachment < ActiveRecord::Migration
  def self.up
    add_column :newsletter_attachments, :user_ids, :string
  end

  def self.down
    remove_column :newsletter_attachments, :user_ids
  end
end

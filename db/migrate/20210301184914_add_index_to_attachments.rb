class AddIndexToAttachments < ActiveRecord::Migration
  def self.up
    add_index :attachments, [:owner_id, :owner_type]
  end

  def self.down
    remove_index :attachments, [:owner_id, :owner_type]
  end
end

class AddFieldsToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :obj_id, :integer
  end

  def self.down
    remove_column :attachments, :obj_id
  end
end

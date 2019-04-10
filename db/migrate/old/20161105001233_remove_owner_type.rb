class RemoveOwnerType < ActiveRecord::Migration
  def self.up
  	remove_column :attachments, :owner_type
  end

  def self.down
  	create_column :attachments,:owner_type,:string
  end
end

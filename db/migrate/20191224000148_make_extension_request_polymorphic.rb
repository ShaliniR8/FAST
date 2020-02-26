class MakeExtensionRequestPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :extension_requests, :type, :owner_type
    change_column :extension_requests, :status, :string, :default => 'New'
  end

  def self.down
    rename_column :extension_requests, :owner_type, :type
  end
end

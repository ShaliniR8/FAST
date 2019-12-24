class MakeExtensionRequestPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :extension_requests, :type, :owner_type
  end

  def self.down
    rename_column :extension_requests, :owner_type, :type
  end
end

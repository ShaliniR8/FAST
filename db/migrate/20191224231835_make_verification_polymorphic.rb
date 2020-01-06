class MakeVerificationPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :verifications, :type, :owner_type
    change_column :verifications, :status, :string, :default => 'New'
  end

  def self.down
    rename_column :verifications, :owner_type, :type
  end
end

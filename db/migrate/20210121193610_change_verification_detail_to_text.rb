class ChangeVerificationDetailToText < ActiveRecord::Migration
  def self.up
    change_column :verifications, :detail, :text
  end

  def self.down
    change_column :verifications, :detail, :string
  end
end

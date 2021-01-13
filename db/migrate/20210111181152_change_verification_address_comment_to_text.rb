class ChangeVerificationAddressCommentToText < ActiveRecord::Migration
  def self.up
    change_column :verifications, :address_comment, :text
  end

  def self.down
    change_column :verifications, :address_comment, :string
  end
end

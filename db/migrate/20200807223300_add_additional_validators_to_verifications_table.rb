class AddAdditionalValidatorsToVerificationsTable < ActiveRecord::Migration
  def self.up
    add_column :verifications, :additional_validators, :text
  end

  def self.down
    remove_column :verifications, :additional_validators
  end
end

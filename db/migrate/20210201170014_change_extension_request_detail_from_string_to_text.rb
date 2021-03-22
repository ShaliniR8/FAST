class ChangeExtensionRequestDetailFromStringToText < ActiveRecord::Migration
  def self.up
    change_column :extension_requests, :detail, :text
  end

  def self.down
    change_column :extension_requests, :detail, :string
  end
end

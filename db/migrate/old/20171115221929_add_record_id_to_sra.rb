class AddRecordIdToSra < ActiveRecord::Migration
  def self.up
    add_column :sras, :record_id, :integer
  end

  def self.down
  	remove_column :sras, :record_id
  end
end

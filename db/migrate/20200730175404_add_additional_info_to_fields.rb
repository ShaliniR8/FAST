class AddAdditionalInfoToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :additional_info, :boolean, default: false
  end

  def self.down
    remove_column :fields, :additional_info
  end
end

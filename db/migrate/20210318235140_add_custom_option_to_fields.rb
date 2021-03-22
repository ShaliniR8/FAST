class AddCustomOptionToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :custom_option_id, :integer
  end

  def self.down
    remove_column :fields, :custom_option_id
  end
end

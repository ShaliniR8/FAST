class AddRequiredToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :required, :boolean, :default => false
  end

  def self.down
    remove_column :fields, :required
  end
end

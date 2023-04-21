class AddTypeToRecord < ActiveRecord::Migration
  def self.up
    add_column :records, :type, :string
  end

  def self.down
    remove_column :records, :type
  end
end

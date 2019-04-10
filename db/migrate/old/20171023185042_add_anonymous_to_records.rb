class AddAnonymousToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :anonymous, :boolean
  end

  def self.down
    remove_column :records, :anonymous
  end
end

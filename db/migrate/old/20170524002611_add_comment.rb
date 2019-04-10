class AddComment < ActiveRecord::Migration
  def self.up
    add_column :inspections,:comment,:text
  end

  def self.down
  end
end

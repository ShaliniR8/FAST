class AddMinutesToSras < ActiveRecord::Migration
  def self.up
    add_column :sras, :minutes, :text
  end

  def self.down
    remove_column :sras, :minutes
  end
end

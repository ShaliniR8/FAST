class AddIgnoreUpdateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :ignore_updates, :boolean, :default => false
  end

  def self.down
    remove_column :users, :ignore_updates
  end
end

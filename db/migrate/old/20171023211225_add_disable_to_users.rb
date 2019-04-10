class AddDisableToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :disable, :boolean
  end

  def self.down
    remove_column :users, :disable
  end
end

class AddMinutesToPackages < ActiveRecord::Migration
  def self.up
    add_column :packages, :minutes, :text
  end

  def self.down
    remove_column :packages, :minutes
  end
end

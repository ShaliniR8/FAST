class AddAndroidVersionToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :android_version, :integer
  end

  def self.down
    remove_column :users, :android_version
  end
end

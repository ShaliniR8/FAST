class AddPrivilegesLastUpdatedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :privileges_last_updated, :datetime
    User.update_all(privileges_last_updated: DateTime.now)
  end

  def self.down
    remove_column :users, :privileges_last_updated
  end
end

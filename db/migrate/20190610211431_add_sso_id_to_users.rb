class AddSsoIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sso_id, :string
    User.update_all 'sso_id=email'
  end

  def self.down
    remove_column :users, :sso_id
  end
end

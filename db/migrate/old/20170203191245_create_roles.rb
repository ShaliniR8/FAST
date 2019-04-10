class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.belongs_to :users
      t.belongs_to :privileges
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end

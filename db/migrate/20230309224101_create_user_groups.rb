class CreateUserGroups < ActiveRecord::Migration
  def self.up
    create_table :user_groups do |t|
      t.string :object_name
      t.text :privileges_id
      t.string :user_field

      t.timestamps
    end
  end

  def self.down
    drop_table :user_groups
  end
end

class AddExample < ActiveRecord::Migration
  def self.up
    add_column :privileges,:example,:text
  end

  def self.down
    remove_column :privileges,:example
  end
end

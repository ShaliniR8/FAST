class AddComment < ActiveRecord::Migration
  def self.up
    add_column :ims,:comment,:text
  end

  def self.down
  end
end

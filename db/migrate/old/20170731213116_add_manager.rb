class AddManager < ActiveRecord::Migration
  def self.up
    add_column :sras,:manager_id,:integer,:index=>true
  end

  def self.down
  end
end

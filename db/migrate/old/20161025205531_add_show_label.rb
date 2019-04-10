class AddShowLabel < ActiveRecord::Migration
  def self.up
    add_column :fields, :show_label,:boolean
  end

  def self.down
  	remove_column :fields,:show_label
  end
end

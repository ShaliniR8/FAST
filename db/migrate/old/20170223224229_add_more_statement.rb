class AddMoreStatement < ActiveRecord::Migration
  def self.up
	add_column :reports,:statement,:text
  end

  def self.down
	remove_column :reports,:statement
  end
end

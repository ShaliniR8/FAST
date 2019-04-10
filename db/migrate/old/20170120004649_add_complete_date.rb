class AddCompleteDate < ActiveRecord::Migration
  def self.up
	add_column :trackings,:complete_date,:date
	add_column :trackings,:status,:string
  end

  def self.down
	remove_column :trackings,:complete_date
	remove_column :trackings,:status
  end
end

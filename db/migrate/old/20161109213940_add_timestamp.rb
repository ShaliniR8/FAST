class AddTimestamp < ActiveRecord::Migration
  def self.up
    add_column :reports, :created_at, :datetime
    add_column :reports, :updated_at, :datetime
  end

  def self.down
    remove_column :reports, :created_at
    remove_column :reports, :updated_at
  end
end

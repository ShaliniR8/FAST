class AddTimeToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :time, :datetime
  end

  def self.down
    remove_column :messages, :time
  end
end

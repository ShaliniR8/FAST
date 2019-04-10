class AddNarravtive < ActiveRecord::Migration
  def self.up
    add_column :findings,:narrative,:text
  end

  def self.down
    remove_column :findings,:narrative
  end
end

class AddStatement < ActiveRecord::Migration
  def self.up
     add_column :findings,:statement,:text
  end

  def self.down
  end
end

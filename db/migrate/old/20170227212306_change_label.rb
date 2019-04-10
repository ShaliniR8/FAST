class ChangeLabel < ActiveRecord::Migration
  def self.up
    change_column :fields,:label,:text
  end

  def self.down
  end
end

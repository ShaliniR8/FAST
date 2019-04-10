class AddExtraMatrix < ActiveRecord::Migration
  def self.up
    add_column :findings,:severity_extra,:string
    add_column :findings,:probability_extra,:string
  end

  def self.down
  end
end

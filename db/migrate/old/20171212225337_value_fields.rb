class ValueFields < ActiveRecord::Migration
  def self.up
    add_column :query_conditions,:condition_value,:text
  end

  def self.down
  end
end

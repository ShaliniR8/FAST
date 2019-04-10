class MoreFieldsConditions < ActiveRecord::Migration
  def self.up
     add_column :query_conditions,:value,:text
  end

  def self.down
     remove_column :query_conditions,:value
  end
end

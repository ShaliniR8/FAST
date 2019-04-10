class AddStartdateEnddateToQueryConditions < ActiveRecord::Migration
  def self.up
    add_column :query_conditions, :start_date, :datetime
    add_column :query_conditions, :end_date, :datetime
  end

  def self.down
    remove_column :query_conditions, :start_date
    remove_column :query_conditions, :end_date
  end
end

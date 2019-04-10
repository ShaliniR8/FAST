class CreateQueryConditions < ActiveRecord::Migration
  def self.up
    create_table :query_conditions do |t|
      t.belongs_to :query_statement
      t.string :condition_type
      t.string :condition_value
      t.timestamps
    end
  end

  def self.down
    drop_table :query_conditions
  end
end

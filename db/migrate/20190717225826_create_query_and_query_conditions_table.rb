class CreateQueryAndQueryConditionsTable < ActiveRecord::Migration
  def self.up
    create_table 'queries', force: true do |t|
      t.timestamps
      t.string :title
      t.integer :created_by_id
      t.string :target
      t.text :visualizations
    end

    create_table 'query_conditions', force: true do |t|
      t.timestamps
      t.integer :query_id
      t.integer :query_condition_id
      t.string :logic
      t.string :field_name
      t.string :value
      t.string :operator
    end
  end

  def self.down
    drop_table :queries
    drop_table :query_conditions
  end
end

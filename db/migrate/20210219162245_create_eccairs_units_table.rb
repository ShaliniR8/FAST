class CreateEccairsUnitsTable < ActiveRecord::Migration
  def self.up
    create_table :eccairs_units do |t|
      t.timestamps
      t.string  :unit_synonym
      t.integer :unit_id
    end
  end

  def self.down
    drop_table :eccairs_units
  end
end

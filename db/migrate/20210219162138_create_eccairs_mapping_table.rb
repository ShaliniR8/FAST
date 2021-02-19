class CreateEccairsMappingTable < ActiveRecord::Migration
  def self.up
    create_table :eccairs_mappings do |t|
      t.integer     :field_id
      t.string      :eccairs_attribute_id
      t.timestamps
    end

    create_table :eccairs_attributes do |t|
      t.timestamps
      t.string      :attribute_synonym
      t.integer     :attribute_id
      t.string      :entity_synonym
      t.integer     :entity_id
      t.integer     :datatype_id
      t.integer     :default_unit_id
      t.string      :value_list_id
      t.integer     :attribute_sequence
    end
  end

  def self.down
    drop_table :eccairs_attributes
    drop_table :eccairs_mappings
  end
end

class AddEccairsMappingToCustomOptions < ActiveRecord::Migration
  def self.up
    add_column :custom_options, :eccairs_mapping, :text
  end

  def self.down
    remove_column :custom_options, :eccairs_mapping
  end
end

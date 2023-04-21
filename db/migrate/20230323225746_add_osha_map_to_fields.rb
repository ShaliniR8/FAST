class AddOshaMapToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :osha_map, :string

    AccessControl.create(action: 'module', entry: 'OSHA', list_type: true)
    AccessControl.create(list_type: true, action: 'index', entry: 'osha_reports', viewer_access: false)
  end

  def self.down
    remove_column :fields, :osha_map
  end
end

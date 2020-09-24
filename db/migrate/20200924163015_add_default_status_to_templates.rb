class AddDefaultStatusToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :default_status, :string
  end

  def self.down
    remove_column :templates, :default_status
  end
end

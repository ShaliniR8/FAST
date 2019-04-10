class AddArchiveToTemplates < ActiveRecord::Migration
  def self.up
	add_column :templates, :archive, :boolean, :default => false
  end

  def self.down
	remove_column :templates, :archive
  end
end

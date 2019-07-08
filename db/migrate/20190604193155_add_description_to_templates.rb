class AddDescriptionToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :description, :string
  end

  def self.down
    remove_column :templates, :description
  end
end

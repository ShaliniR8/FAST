class ChangeDescriptionTypeInTemplates < ActiveRecord::Migration
  def self.up
    change_column :templates, :description, :text
  end

  def self.down
    change_column :templates, :description, :string
  end
end

class AddAnonymousToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :allow_anonymous, :boolean, :default => false
  end

  def self.down
    remove_column :templates, :allow_anonymous
  end
end

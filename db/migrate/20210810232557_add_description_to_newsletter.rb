class AddDescriptionToNewsletter < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :description, :text
  end

  def self.down
    remove_column :newsletters, :description
  end
end

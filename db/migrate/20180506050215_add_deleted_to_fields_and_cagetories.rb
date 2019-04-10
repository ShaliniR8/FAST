class AddDeletedToFieldsAndCagetories < ActiveRecord::Migration
  def self.up
    add_column :fields, :deleted, :boolean, default: false
    add_column :categories, :deleted, :boolean, default: false
  end

  def self.down
    remove_column :fields, :deleted
    remove_column :categories, :deleted
  end
end

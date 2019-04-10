class AddImple < ActiveRecord::Migration
  def self.up
    add_column :meetings,:imp,:string
  end

  def self.downi
    remove_column :meetings,:imp
  end
end

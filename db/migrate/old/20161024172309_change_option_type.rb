class ChangeOptionType < ActiveRecord::Migration
  def self.up
  	change_column :fields, :options, :text
  end

  def self.down
  	change_column :fields, :options, :string
  end
end

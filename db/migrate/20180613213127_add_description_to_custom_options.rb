class AddDescriptionToCustomOptions < ActiveRecord::Migration
  def self.up
    add_column :custom_options, :description, :string
  end


  def self.down
  	remove_column :custom_options, :descriptions
  end
end

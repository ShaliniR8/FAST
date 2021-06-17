class AddSraTypeToSras < ActiveRecord::Migration
  def self.up
    add_column :sras, :sra_type, :string
  end

  def self.down
    remove_column :sras, :sra_type
  end
end

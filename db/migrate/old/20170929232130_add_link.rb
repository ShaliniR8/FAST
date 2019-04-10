class AddLink < ActiveRecord::Migration
  def self.up
    add_column :messages,:link,:string
  end

  def self.down 
    remove_column :messages,:link
  end
end

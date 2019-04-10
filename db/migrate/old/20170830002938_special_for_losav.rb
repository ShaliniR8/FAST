class SpecialForLosav < ActiveRecord::Migration
  def self.up
     add_column :templates,:js_link,:string
     add_column :fields,:element_id,:string,:default=>""
     add_column :fields,:element_class,:string,:default=>""
  end

  def self.down
     remove_column :templates,:js_link
     remove_column :fields,:element_id
     remove_column :fields,:element_class
  end
end

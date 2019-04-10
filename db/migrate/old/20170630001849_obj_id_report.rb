class ObjIdReport < ActiveRecord::Migration
  def self.up
    add_column :records,:object_id,:integer
    add_column :record_fields,:object_id,:integer
  end


  def self.down
  end
end

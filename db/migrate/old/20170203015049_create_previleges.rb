class CreatePrevileges < ActiveRecord::Migration
  def self.up
    create_table :previleges do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :previleges
  end
end

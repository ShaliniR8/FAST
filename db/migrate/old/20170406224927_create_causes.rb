class CreateCauses < ActiveRecord::Migration
  def self.up
    create_table :causes do |t|
      t.string :category
      t.text   :value
      t.integer :owner_id
      t.string  :type
      t.timestamps
    end
  end

  def self.down
    drop_table :causes
  end
end

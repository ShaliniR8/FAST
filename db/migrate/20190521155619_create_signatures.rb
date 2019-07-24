class CreateSignatures < ActiveRecord::Migration
  def self.up
    create_table 'signatures', force: true do |t|
      t.timestamps
      t.string :signee_name
      t.integer :user_id
      t.string :owner_id
      t.string :owner_type
      t.string :path
    end
  end

  def self.down
    drop_table :signatures
  end
end

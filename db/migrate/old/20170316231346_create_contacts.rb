class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.belongs_to :im
      t.string :location
      t.string :reference_number
      t.string :contact_name
      t.string :email
      t.string :work_phone
      t.string :mobile_phone
      t.string :add_1
      t.string :add_2
      t.string :city
      t.string :state
      t.integer :zip
      t.text   :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end

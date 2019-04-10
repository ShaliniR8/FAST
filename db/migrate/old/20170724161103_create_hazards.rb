class CreateHazards < ActiveRecord::Migration
  def self.up
    create_table :hazards do |t|
      t.string :type
      t.string :title
      t.belongs_to :sra
      t.text :description
      t.integer :severity
      t.string :likelihood
      t.string :risk_factor
      t.text   :statement
      t.timestamps
    end
  end

  def self.down
    drop_table :hazards
  end
end

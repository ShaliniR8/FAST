class CreateCosts < ActiveRecord::Migration
  def self.up
    create_table :costs do |t|
      t.belongs_to :owner
      t.string :type
      t.text   :description
      t.date   :cost_date
      t.boolean :direct_cost
      t.boolean :indirect_cost
      t.string  :work_order
      t.string  :vendor
      t.string  :amount
      t.text     :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :costs
  end
end

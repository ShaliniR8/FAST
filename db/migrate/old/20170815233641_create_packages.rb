class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.string :type
      t.string :title
      t.belongs_to :owner
      t.string :level_of_compliance
      t.text :statement
      t.text :description
      t.text :plan
      t.text :responsibility
      t.date :plan_due_date
      t.text :comment
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :packages
  end
end

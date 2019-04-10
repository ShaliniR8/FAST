class CreateSras < ActiveRecord::Migration
  def self.up
    create_table :sras do |t|
      t.string :title
      t.string :type_of_change
      t.text :current_description
      t.text :plan_description
      t.text :departments
      t.text :departments_comment
      t.text :manuals
      t.text :manuals_comment
      t.text :programs
      t.text :programs_comment
      t.date :scheduled_completion_date
      t.belongs_to :approver
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sras
  end
end

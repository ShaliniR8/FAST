class CreateInspections < ActiveRecord::Migration
  def self.up
    create_table :inspections do |t|
      t.string  :title
      t.string  :department
      t.integer :auditor_id
      t.date    :completion
      t.string  :inspection_type
      t.string  :location
      t.string  :station_code
      t.string  :vendor
      t.string  :inspection_department
      t.string  :process
      t.boolean :planned
      t.string  :supplier
      t.text    :objective
      t.text    :reference
      t.text    :instruction
      t.integer :approver_id  
      t.string  :status , :default=>"New"
      t.boolean :viewer_access,:default=>false
      t.date    :open_date
      t.date    :complete_date
      t.timestamps
      
    end
  end

  def self.down
    drop_table :inspections
  end
end

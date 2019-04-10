class CreateAudits < ActiveRecord::Migration
  def self.up
    create_table :audits do |t|
      t.string :title
      t.string :department
      t.integer :auditor_id
      t.date    :completion
      t.string  :audit_type
      t.string  :location
      t.string  :station_code
      t.string  :vendor
      t.string  :audit_department
      t.string  :process
      t.boolean :planned
      t.string  :supplier
      t.text	:objective
      t.text    :reference
      t.text    :instruction
      t.integer :approver_id    
      t.timestamps
    end
  end

  def self.down
    drop_table :audits
  end
end

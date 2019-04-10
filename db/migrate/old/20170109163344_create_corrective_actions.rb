class CreateCorrectiveActions < ActiveRecord::Migration
  def self.up
  	create_table :corrective_actions do |t|
  		t.belongs_to :reports
      t.belongs_to :records
  		t.string :status
  		t.boolean :recommendation
  		t.date :opened_date
  		t.date :assigned_date
  		t.date :decision_date
  		t.date :due_date
      t.date :revised_due_date
  		t.boolean :company
  		t.boolean :employee
  		t.string :department
  		t.belongs_to :users
  		t.boolean :bimmediate_action
  		t.text :immediate_action
  		t.boolean :bcomprehensive_action
  		t.text :comprehensive_action
  		t.string :action
  		t.text   :description
  		t.text   :response
  		t.timestamps
  	end
  end

  def self.down
  	drop_table :corrective_actions 
  end
end

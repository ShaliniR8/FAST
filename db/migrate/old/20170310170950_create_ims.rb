class CreateIms < ActiveRecord::Migration
  def self.up
    create_table :ims do |t|
      t.string :type
      t.string :title
      t.integer :lead_evaluator
      t.date 	:completion_date
      t.string	:location
      t.string  :apply_to
      t.string  :org_type
      t.text	:obj_scope
      t.text    :ref_req
      t.text    :instruction
      t.integer :pre_reviewer
      t.string  :job_aid
      t.timestamps
    end
  end

  def self.down
    drop_table :ims
  end
end
